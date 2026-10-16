# CLAUDE.md — Promotions Screen (Flutter Code Assessment)

## Context

This is a timed (1 hour) Flutter code assessment. Build **one screen** that lists banking promotions from a
**mocked** API. Reviewers care about architecture, data flow, state handling, rebuild scoping and tests —
not visual polish. Build it the way production code should be built, but stay within scope.

**Do not** add features that aren't asked for (no navigation to other pages, no persistence, no theming system,
no localization). Prefer clarity over cleverness.

---

## Requirements checklist

- [ ] Load promotions on open; show a loader while fetching
- [ ] Horizontal category filter at the top: `All | Deposit | Card | Transfer | Referral`
- [ ] Filtered list below the filter
- [ ] Pull-to-refresh
- [ ] Empty state (no promotions in the selected category, or none at all)
- [ ] Error state with a visible message and a Retry button
- [ ] Tap a promotion → bottom sheet with full details + CTA button
- [ ] Tap CTA → mark promotion as read, close sheet, read cards visually distinct in the list
- [ ] Everything on one screen — no second page
- [ ] Mock API switchable between **success / empty / error**
- [ ] Cubit-based state (`flutter_bloc`)
- [ ] Consistent dependency injection
- [ ] `BlocSelector` used deliberately (see "Rebuild scoping")
- [ ] Tests at every layer (data, domain, presentation)
- [ ] Small, meaningful commits on branch `candidate/<your-name>/promotions`

---

## Tech stack

| Concern            | Choice                                   | Why |
|--------------------|------------------------------------------|-----|
| State management   | `flutter_bloc` (Cubit only)              | Required by brief |
| Value equality     | `equatable`                              | No codegen → fast iteration in a 1h window |
| DI                 | `get_it` (manual registration, no codegen) | Explicit, readable, one composition root |
| Result type        | Hand-rolled sealed `Result<T>` in `core/` | Avoids pulling in `dartz`/`fpdart` for one use |
| Testing            | `flutter_test`, `bloc_test`, `mocktail`  | Standard bloc testing toolkit |
| Network images in tests | `mocktail_image_network` (dev)      | `Image.network` fails in widget tests otherwise |
| Lints              | `flutter_lints` (+ stricter rules below) | |

Add packages with `flutter pub add <pkg>` / `flutter pub add --dev <pkg>` so the latest stable versions are used.
**No `freezed`, `json_serializable` or `injectable`** — avoid build_runner for this assessment.

---

## Architecture

Clean Architecture, **feature-first**. Dependencies point inward only:

```
presentation  ──▶  domain  ◀──  data
   (UI, Cubit)     (entities,      (models, data sources,
                    repo contract,  repo implementation)
                    use cases)
```

- **domain** is pure Dart: no Flutter imports, no JSON, no `get_it`.
- **data** knows JSON shapes and the mock; converts models → entities; converts exceptions → failures.
- **presentation** knows only domain types (entities, use cases, failures). It never imports from `data/`.
- **core/di** is the only place that knows about concrete implementations.

### Folder structure

```
lib/
├── main.dart                         # configureDependencies() then runApp
├── app/
│   └── app.dart                      # MaterialApp, home: PromotionsPage
├── core/
│   ├── di/
│   │   └── injection.dart            # get_it composition root
│   ├── error/
│   │   ├── exceptions.dart           # ServerException (data layer only)
│   │   └── failures.dart             # sealed Failure (domain-facing)
│   ├── result/
│   │   └── result.dart               # sealed Result<T> = Success<T> | Err<T>
│   └── usecase/
│       └── usecase.dart              # abstract UseCase<T, Params>, NoParams
└── features/
    └── promotions/
        ├── data/
        │   ├── datasources/
        │   │   ├── promotions_remote_data_source.dart       # abstract contract
        │   │   └── mock_promotions_remote_data_source.dart  # delayed Future + scenarios
        │   ├── mock/
        │   │   ├── mock_scenario.dart                       # enum { success, empty, error }
        │   │   └── mock_responses.dart                      # the three JSON payloads from the brief
        │   ├── models/
        │   │   └── promotion_model.dart                     # fromJson + toEntity()
        │   └── repositories/
        │       └── promotions_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── promotion.dart
        │   │   └── promotion_category.dart                  # enum + fromApi()
        │   ├── repositories/
        │   │   └── promotions_repository.dart               # abstract
        │   └── usecases/
        │       └── get_promotions.dart
        └── presentation/
            ├── cubit/
            │   ├── promotions_cubit.dart
            │   └── promotions_state.dart
            ├── pages/
            │   └── promotions_page.dart                     # BlocProvider + scaffold only
            └── widgets/
                ├── category_filter_bar.dart
                ├── promotions_body.dart                     # switches on status
                ├── promotions_list.dart
                ├── promotion_card.dart
                ├── promotion_details_sheet.dart
                ├── promotions_loading_view.dart
                ├── promotions_empty_view.dart
                └── promotions_error_view.dart

test/
├── helpers/                          # fixtures, mocks, pumpApp helper
└── features/promotions/              # mirrors lib/ structure 1:1
    ├── data/...
    ├── domain/...
    └── presentation/...
```

Test files mirror `lib/` paths and end in `_test.dart`.

---

## Layer details

### Domain

```dart
enum PromotionCategory { deposit, card, transfer, referral }
```
- `PromotionCategory.fromApi(String)` maps `"DEPOSIT"` etc. Unknown values → return `null`; the model layer
  skips that item rather than crashing the whole list.
- The filter's "All" option is **not** a domain category. Represent the selected filter as
  `PromotionCategory?` where `null` means All.

`Promotion` (Equatable): `id`, `title`, `description`, `imageUrl`, `category`, `validFrom` (`DateTime`),
`validUntil` (`DateTime`), `ctaLabel`, `isFeatured`. **No `isRead` field** — read status is screen/session
state owned by the Cubit, not part of the API entity.

`PromotionsRepository`:
```dart
abstract interface class PromotionsRepository {
  Future<Result<List<Promotion>>> getPromotions();
}
```

`GetPromotions` use case: thin wrapper calling the repository. Keep it — it's the seam the Cubit depends on.

`Failure` (sealed, Equatable): `ServerFailure(code, message)`, `UnexpectedFailure(message)`.

### Data

- `PromotionsRemoteDataSource.fetchPromotions()` returns `List<PromotionModel>` or **throws**
  `ServerException(errorCode, message)`.
- `MockPromotionsRemoteDataSource(scenario, delay)`:
  - `await Future.delayed(delay)` (default ~800ms; inject `Duration.zero` in tests).
  - Pick the raw JSON for the scenario from `mock_responses.dart`, then **parse it exactly as a real
    response would be**: check `status`; `"FAIL"` → throw `ServerException(errorCode, message)`;
    `"SUCCESS"` → map `payload.promotions` through `PromotionModel.fromJson`.
  - Keep JSON as `String` constants and `jsonDecode` them, so the parsing path is genuinely exercised.
- `PromotionModel.fromJson` parses dates with `DateTime.parse`, maps category, exposes `toEntity()`.
  Malformed JSON → `FormatException`.
- `PromotionsRepositoryImpl`: calls data source, maps models → entities, catches
  `ServerException` → `ServerFailure`, anything else → `UnexpectedFailure`. **Never lets exceptions escape.**

### Switching mock scenarios

Scenario is chosen at the composition root via `--dart-define`:

```bash
flutter run --dart-define=PROMO_SCENARIO=success   # default
flutter run --dart-define=PROMO_SCENARIO=empty
flutter run --dart-define=PROMO_SCENARIO=error
```

`injection.dart` reads `const String.fromEnvironment('PROMO_SCENARIO', defaultValue: 'success')` and
passes the parsed `MockScenario` into the data source. Nothing outside DI knows the mock exists.

### Dependency injection (`core/di/injection.dart`)

Single composition root, called once from `main()` before `runApp`:

```dart
final sl = GetIt.instance;

void configureDependencies({MockScenario? scenario}) {
  sl
    ..registerLazySingleton<PromotionsRemoteDataSource>(
        () => MockPromotionsRemoteDataSource(scenario: scenario ?? _scenarioFromEnv()))
    ..registerLazySingleton<PromotionsRepository>(() => PromotionsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetPromotions(sl()))
    ..registerFactory(() => PromotionsCubit(sl()));
}
```

Rules:
- Cubits are **factories**; everything else lazy singletons.
- `sl` is used **only** in `injection.dart` and at the `BlocProvider(create: ...)` in `PromotionsPage`.
  Widgets below the page get the Cubit via `context.read/watch/select` — never from `sl`.
- All classes take dependencies via constructor (so tests construct them directly, no `get_it` in tests).

### Presentation

#### State — single class with a status enum

```dart
enum PromotionsStatus { initial, loading, loaded, failure }

class PromotionsState extends Equatable {
  final PromotionsStatus status;
  final List<Promotion> promotions;          // full list from API
  final PromotionCategory? selectedCategory; // null = All
  final Set<String> readIds;
  final Failure? failure;
  final bool isRefreshing;

  List<Promotion> get visiblePromotions;     // derived: filter by selectedCategory
  bool get isEmpty;                          // loaded && visiblePromotions.isEmpty
  bool isRead(String id) => readIds.contains(id);
}
```

Why one class instead of sealed subclasses: the selected filter and read IDs must **survive** across
load / refresh / error transitions. With sealed states they'd have to be copied into every subclass.
Document this choice in a short comment — reviewers will ask.

"Empty" is a **derived** UI state (`status == loaded && visiblePromotions.isEmpty`), not a separate status.
Distinguish copy: "No promotions right now" (API returned none) vs "No Card promotions" (filter returned none).

#### Cubit API

```dart
Future<void> load();                         // initial load + Retry. Emits loading → loaded|failure
Future<void> refresh();                      // pull-to-refresh. Keeps list visible; isRefreshing true→false
void selectCategory(PromotionCategory? c);   // pure state change, no fetch
void markAsRead(String id);                  // adds to readIds (immutable copy of the Set)
```

Behaviour rules:
- `refresh()` failure **while data exists** → keep the existing list, keep status `loaded`, set `failure`
  so a `BlocListener` can show a SnackBar. Refresh failure with no data → status `failure`.
- `readIds` and `selectedCategory` are **preserved** across refresh and retry.
- Always emit new collections (`{...readIds, id}`), never mutate.
- Guard against emitting after close (`if (isClosed) return;`) after awaits.

#### Rebuild scoping — use each helper deliberately

| Widget | Helper | Reason |
|---|---|---|
| `CategoryFilterBar` | **`BlocSelector<…, PromotionCategory?>`** | Only cares about the selected chip; must not rebuild when the list loads or a card is read |
| `PromotionCard` | **`BlocSelector<…, bool>`** selecting `state.isRead(promotion.id)` | Marking one card read rebuilds **only that card**, not the list. This is the headline `BlocSelector` usage — leave a comment explaining it |
| `PromotionsBody` | `BlocBuilder` with `buildWhen` on `status`, `visiblePromotions`, `failure` (when no data) | Switches between loading / error / empty / list |
| `PromotionsPage` | `BlocListener` with `listenWhen` (refresh failure with data present) | Side effect only: SnackBar. No rebuild |
| CTA / chip taps / Retry | `context.read<PromotionsCubit>()` | Calls methods; never `watch` in callbacks |

Do not wrap the whole Scaffold in a `BlocBuilder`.

#### Bottom sheet data flow

Keep `PromotionDetailsSheet` **dumb**: it takes a `Promotion` and an `onCtaPressed` callback; it does not
know the Cubit exists. The page/card owns the wiring:

```dart
final cubit = context.read<PromotionsCubit>();
await showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => PromotionDetailsSheet(
    promotion: promotion,
    onCtaPressed: () {
      cubit.markAsRead(promotion.id);
      Navigator.of(context).pop();
    },
  ),
);
```

Grab the Cubit **before** opening the sheet (the sheet's route context is not under the `BlocProvider`).
This keeps the sheet widget-testable without bloc and makes data flow one-directional:
UI event → Cubit method → new state → `BlocSelector` on the card rebuilds.

#### Read card styling

Read cards: reduced opacity (e.g. 0.6) + a small "Read" chip / check icon. Don't rely on colour alone.
Featured promotions get a "Featured" badge.

#### Pull-to-refresh

`RefreshIndicator(onRefresh: cubit.refresh)` around the list. The empty and error views must also be
scrollable (`ListView` / `CustomScrollView` with `AlwaysScrollableScrollPhysics`) so pull-to-refresh works
when there's nothing to show.

#### Images

`Image.network` with `loadingBuilder` and `errorBuilder` (placeholder icon). Never let an image failure
break the card.

---

## Testing

Meaningful coverage over count. Every layer gets tests. Use `mocktail`; no `get_it` inside tests.

**Data**
- `PromotionModel.fromJson` — parses all fields; dates; each category; unknown category handled.
- `MockPromotionsRemoteDataSource` — success returns 4 models; empty returns `[]`; error throws
  `ServerException` with `ERR_PROMOTIONS_UNAVAILABLE` and the message. Use `delay: Duration.zero`.
- `PromotionsRepositoryImpl` — success maps to entities; `ServerException` → `ServerFailure`;
  unexpected exception → `UnexpectedFailure`.

**Domain**
- `GetPromotions` delegates to the repository and returns its result unchanged.

**Presentation — Cubit (`bloc_test`)**
- `load` success → `[loading, loaded]`
- `load` empty → `loaded` with empty list (`isEmpty == true`)
- `load` error → `[loading, failure]` with the failure
- Retry after failure → `[loading, loaded]`
- `selectCategory` filters `visiblePromotions`; `null` shows all; empty-for-category case
- `markAsRead` adds id; idempotent
- `refresh` keeps list visible, toggles `isRefreshing`, **preserves `readIds` and `selectedCategory`**
- `refresh` failure with existing data keeps list and sets failure

**Presentation — Widgets** (use `MockCubit` from `bloc_test` + `whenListen`, wrap in `mockNetworkImages`)
- Loading → shows progress indicator
- Failure → shows message + Retry; tapping Retry calls `load()`
- Empty → shows empty view
- Loaded → shows cards
- Tapping a chip calls `selectCategory`
- Tapping a card opens the sheet; tapping CTA calls `markAsRead(id)` and closes the sheet
- `PromotionCard` renders read styling when `isRead` is true
- `PromotionDetailsSheet` in isolation: shows details, CTA invokes callback

Shared fixtures (a list of `Promotion` entities and the raw JSON strings) live in `test/helpers/`.

---

## Commands

```bash
flutter pub get
flutter analyze                                       # must be clean before each commit
dart format .
flutter test
flutter test --coverage
flutter run --dart-define=PROMO_SCENARIO=error        # demo a path
```

---

## Code conventions

- `analysis_options.yaml`: include `flutter_lints`, plus `prefer_const_constructors`,
  `prefer_final_locals`, `always_declare_return_types`, `avoid_print`, `require_trailing_commas`,
  `sort_constructors_first`.
- One public widget per file. Prefer small `StatelessWidget` classes over helper methods returning widgets
  (enables `const` and scoped rebuilds).
- `const` constructors wherever possible.
- Entities/state are immutable (`final` fields, `copyWith`, Equatable `props`).
- Widgets show `Failure.message`; never surface raw exceptions.
- Add `Key`s to things tests find (`Key('promotions_retry_button')`, `ValueKey(promotion.id)` on cards).
- No `print`; no commented-out code; no TODOs left in the submission.

---

## Git workflow

```bash
git checkout -b candidate/<your-name>/promotions
```

Small, meaningful commits — commit after each step below, with analyze + tests green. Suggested sequence:

1. `chore: scaffold project, add deps and lint rules`
2. `feat(core): add Result, Failure, UseCase and DI root`
3. `feat(promotions): add domain entities, repository contract and use case` (+ tests)
4. `feat(promotions): add mock data source with switchable scenarios` (+ tests)
5. `feat(promotions): add model and repository implementation` (+ tests)
6. `feat(promotions): add PromotionsCubit and state` (+ bloc tests)
7. `feat(promotions): add promotions page with loading/error/empty/list states` (+ widget tests)
8. `feat(promotions): add category filter with BlocSelector` (+ tests)
9. `feat(promotions): add details sheet and mark-as-read` (+ tests)
10. `feat(promotions): add pull-to-refresh`
11. `docs: add README with run instructions and design notes`

**Never push to a remote.** Submission: zip the project including `.git/`, excluding `build/`,
`.dart_tool/`, `ios/Pods/`:

```bash
zip -r promotions.zip . -x "build/*" ".dart_tool/*" "ios/Pods/*"
```

---

## Time budget (60 min)

| Min | Work |
|---|---|
| 0–5 | Scaffold, deps, lints, branch |
| 5–15 | Core + domain + data (with tests) |
| 15–25 | Cubit + bloc tests |
| 25–45 | UI: page, states, filter, cards, sheet, refresh |
| 45–55 | Widget tests |
| 55–60 | README, analyze, format, final commit, zip |

If running short, cut in this order: visual polish → featured badge → widget test breadth.
**Never cut**: the four states, mark-as-read flow, the `BlocSelector` usage, or Cubit tests.

---

## README (write at the end)

Short sections: how to run each scenario, architecture diagram (the arrow sketch above), key decisions
(single state class vs sealed states; read state in Cubit not entity; where `BlocSelector` is used and why;
manual `get_it` over `injectable`), and what you'd do with more time (persist read IDs via a local data
source, pagination, analytics on CTA, golden tests).
