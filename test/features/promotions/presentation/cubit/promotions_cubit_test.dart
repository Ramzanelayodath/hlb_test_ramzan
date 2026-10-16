import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/core/error/failures.dart';
import 'package:hlb_test/core/result/result.dart';
import 'package:hlb_test/core/usecase/usecase.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion_category.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/promotion_fixtures.dart';

void main() {
  const failure = ServerFailure(
    code: 'ERR_PROMOTIONS_UNAVAILABLE',
    message: 'Promotions are temporarily unavailable',
  );
  final loaded = PromotionsState(
    status: PromotionsStatus.loaded,
    promotions: tPromotions,
  );

  late MockGetPromotions getPromotions;

  void stubResult(Result<List<Promotion>> result) {
    when(() => getPromotions(const NoParams())).thenAnswer((_) async => result);
  }

  setUp(() {
    getPromotions = MockGetPromotions();
  });

  PromotionsCubit build() => PromotionsCubit(getPromotions);

  test('initial state is initial with no data', () {
    expect(build().state, const PromotionsState());
  });

  group('load', () {
    blocTest<PromotionsCubit, PromotionsState>(
      'success emits [loading, loaded]',
      setUp: () => stubResult(Success(tPromotions)),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PromotionsState(status: PromotionsStatus.loading),
        loaded,
      ],
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'empty emits loaded with an empty list',
      setUp: () => stubResult(const Success([])),
      build: build,
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [const PromotionsState(status: PromotionsStatus.loaded)],
      verify: (cubit) => expect(cubit.state.isEmpty, isTrue),
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'error emits [loading, failure] with the failure',
      setUp: () => stubResult(const Err(failure)),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PromotionsState(status: PromotionsStatus.loading),
        const PromotionsState(
          status: PromotionsStatus.failure,
          failure: failure,
        ),
      ],
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'retry after failure emits [loading, loaded] and clears the failure',
      setUp: () => stubResult(Success(tPromotions)),
      build: build,
      seed: () => const PromotionsState(
        status: PromotionsStatus.failure,
        failure: failure,
        selectedCategory: PromotionCategory.card,
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        const PromotionsState(
          status: PromotionsStatus.loading,
          selectedCategory: PromotionCategory.card,
        ),
        loaded.copyWith(selectedCategory: () => PromotionCategory.card),
      ],
    );
  });

  group('selectCategory', () {
    blocTest<PromotionsCubit, PromotionsState>(
      'filters visiblePromotions by category',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.selectCategory(PromotionCategory.card),
      verify: (cubit) {
        expect(cubit.state.visiblePromotions, [tCardPromotion]);
        verifyNever(() => getPromotions(const NoParams()));
      },
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'null shows all promotions',
      build: build,
      seed: () =>
          loaded.copyWith(selectedCategory: () => PromotionCategory.card),
      act: (cubit) => cubit.selectCategory(null),
      verify: (cubit) => expect(cubit.state.visiblePromotions, tPromotions),
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'category with no promotions is empty',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.selectCategory(PromotionCategory.referral),
      verify: (cubit) {
        expect(cubit.state.visiblePromotions, isEmpty);
        expect(cubit.state.isEmpty, isTrue);
      },
    );
  });

  group('markAsRead', () {
    blocTest<PromotionsCubit, PromotionsState>(
      'adds the id to readIds',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.markAsRead('p1'),
      expect: () => [
        loaded.copyWith(readIds: {'p1'}),
      ],
      verify: (cubit) => expect(cubit.state.isRead('p1'), isTrue),
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'is idempotent',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit
        ..markAsRead('p1')
        ..markAsRead('p1'),
      expect: () => [
        loaded.copyWith(readIds: {'p1'}),
      ],
    );
  });

  group('refresh', () {
    final seeded = loaded.copyWith(
      readIds: {'p1'},
      selectedCategory: () => PromotionCategory.deposit,
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'keeps the list visible, toggles isRefreshing and preserves '
      'readIds and selectedCategory',
      setUp: () => stubResult(Success([tDepositPromotion, tCardPromotion])),
      build: build,
      seed: () => seeded,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        seeded.copyWith(isRefreshing: true),
        seeded.copyWith(promotions: [tDepositPromotion, tCardPromotion]),
      ],
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'failure with existing data keeps the list and sets the failure',
      setUp: () => stubResult(const Err(failure)),
      build: build,
      seed: () => seeded,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        seeded.copyWith(isRefreshing: true),
        seeded.copyWith(failure: () => failure),
      ],
    );

    blocTest<PromotionsCubit, PromotionsState>(
      'failure without data emits failure status',
      setUp: () => stubResult(const Err(failure)),
      build: build,
      seed: () => const PromotionsState(status: PromotionsStatus.loaded),
      act: (cubit) => cubit.refresh(),
      skip: 1,
      expect: () => [
        const PromotionsState(
          status: PromotionsStatus.failure,
          failure: failure,
        ),
      ],
    );
  });
}
