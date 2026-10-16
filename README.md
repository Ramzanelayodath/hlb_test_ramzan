# Promotions

A single screen that lists banking promotions from a mocked API. It has a category filter,
pull-to-refresh, loading / empty / error states, a details bottom sheet, and mark-as-read.

## Running

```bash
flutter pub get
flutter run                                         # success (default)
flutter run --dart-define=PROMO_SCENARIO=empty
flutter run --dart-define=PROMO_SCENARIO=error
```

The mock waits about 800 ms before responding, so you can see the loader.

```bash
flutter analyze
flutter test
flutter test --coverage
```

## Architecture

Clean Architecture, organised by feature. Dependencies point inward only:

```
presentation  ──▶  domain  ◀──  data
   (UI, Cubit)     (entities,      (models, data sources,
                    repo contract,  repo implementation)
                    use cases)
```

- **domain** is pure Dart: `Promotion`, `PromotionCategory`, the `PromotionsRepository` contract and
  the `GetPromotions` use case.
- **data** parses JSON. `MockPromotionsRemoteDataSource` decodes the raw payloads from the brief the
  same way it would decode a real response: `status: "FAIL"` throws a `ServerException`.
  `PromotionsRepositoryImpl` turns models into entities and every exception into a `Failure`, so
  nothing throws past it. Items with an unknown category are skipped rather than failing the list.
- **presentation** only knows domain types. `PromotionsCubit` holds the state and widgets read it
  from context.
- **core/di/injection.dart** is the only composition root. It is the only file that knows about the
  mock, and it picks the scenario from `PROMO_SCENARIO`.

## Key decisions

- **Single state class with a status enum, not sealed states.** The selected filter and the read
  IDs have to survive load, refresh and error transitions. With sealed subclasses, every subclass
  would have to copy them. "Empty" is derived (`loaded` + no visible promotions), not a status of its own.
- **Read status lives in the Cubit, not the entity.** `isRead` is session state for this screen,
  not API data, so `Promotion` has no `isRead` field. The Cubit keeps an immutable `Set<String> readIds`.
- **Rebuild scoping:**
  - `PromotionCard` uses `BlocSelector<…, bool>` on `state.isRead(id)`. Marking one promotion as read
    rebuilds only that card, not the list.
  - `CategoryFilterBar` uses `BlocSelector<…, PromotionCategory?>`, so it does not rebuild when data
    loads or a card is read.
  - `PromotionsBody` uses `BlocBuilder` with `buildWhen` on status, list, filter and failure.
    Read-status changes are ignored here.
  - `PromotionsView` uses `BlocListener` to show a SnackBar when a refresh fails while data is on
    screen. The list stays visible.
- **The details sheet is presentational.** It takes a `Promotion` and an `onCtaPressed` callback. The
  card reads the Cubit before it opens the sheet and handles the wiring, so data flows one way:
  tap → `markAsRead` → new state → that card's `BlocSelector` rebuilds.
- **Manual `get_it` instead of `injectable`, and `equatable` instead of `freezed`.** This avoids
  build_runner, and one composition root is easy to read. Cubits are registered as factories and
  everything else as lazy singletons. Classes take their dependencies through the constructor, so
  tests build them directly without `get_it`.
- **Hand-written `Result<T>`** (`Success` / `Err`) in `core/` instead of pulling in `dartz`/`fpdart`
  for a single use.

## Tests

Every layer has tests: model parsing, mock data source scenarios, repository error mapping, use
case delegation, Cubit behaviour (`bloc_test`), and widgets (`MockCubit` + `mockNetworkImages`).
Test files mirror the folders under `lib/`.

## With more time

- Persist read IDs through a local data source, so they survive restarts.
- Pagination.
- Analytics events on CTA taps.
- Golden tests for the card and sheet.
