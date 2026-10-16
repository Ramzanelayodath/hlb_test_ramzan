import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/core/error/failures.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion_category.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_state.dart';
import 'package:hlb_test/features/promotions/presentation/widgets/promotions_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/promotion_fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  const failure = ServerFailure(
    code: 'ERR_PROMOTIONS_UNAVAILABLE',
    message: 'Promotions are temporarily unavailable',
  );
  final loaded = PromotionsState(
    status: PromotionsStatus.loaded,
    promotions: tPromotions,
  );

  late MockPromotionsCubit cubit;

  setUp(() {
    cubit = MockPromotionsCubit();
  });

  Future<void> pumpWithState(WidgetTester tester, PromotionsState state) {
    when(() => cubit.state).thenReturn(state);
    return mockNetworkImages(
      () => tester.pumpApp(const PromotionsView(), cubit: cubit),
    );
  }

  testWidgets('loading shows a progress indicator', (tester) async {
    await pumpWithState(
      tester,
      const PromotionsState(status: PromotionsStatus.loading),
    );

    expect(find.byKey(const Key('promotions_loading')), findsOneWidget);
  });

  testWidgets('failure shows the message and Retry calls load', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpWithState(
      tester,
      const PromotionsState(status: PromotionsStatus.failure, failure: failure),
    );

    expect(find.text(failure.message), findsOneWidget);
    await tester.tap(find.byKey(const Key('promotions_retry_button')));
    verify(() => cubit.load()).called(1);
  });

  testWidgets('API returned nothing shows the generic empty copy', (
    tester,
  ) async {
    await pumpWithState(
      tester,
      const PromotionsState(status: PromotionsStatus.loaded),
    );

    expect(find.byKey(const Key('promotions_empty')), findsOneWidget);
    expect(find.text('No promotions right now'), findsOneWidget);
  });

  testWidgets('filter returned nothing shows category empty copy', (
    tester,
  ) async {
    await pumpWithState(
      tester,
      loaded.copyWith(selectedCategory: () => PromotionCategory.referral),
    );

    expect(find.text('No Referral promotions'), findsOneWidget);
  });

  testWidgets('loaded shows a card per visible promotion', (tester) async {
    tester.view
      ..physicalSize = const Size(800, 3000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpWithState(tester, loaded);

    expect(find.byKey(ValueKey(tDepositPromotion.id)), findsOneWidget);
    expect(find.byKey(ValueKey(tCardPromotion.id)), findsOneWidget);
    expect(find.text(tDepositPromotion.title), findsOneWidget);
    expect(find.byKey(const Key('promotion_featured_badge')), findsOneWidget);
  });

  testWidgets('pulling the list down calls refresh', (tester) async {
    when(() => cubit.refresh()).thenAnswer((_) async {});
    await pumpWithState(tester, loaded);

    await tester.fling(
      find.byKey(const Key('promotions_list')),
      const Offset(0, 400),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('pulling the empty view down calls refresh', (tester) async {
    when(() => cubit.refresh()).thenAnswer((_) async {});
    await pumpWithState(
      tester,
      const PromotionsState(status: PromotionsStatus.loaded),
    );

    await tester.fling(
      find.byKey(const Key('promotions_empty')),
      const Offset(0, 400),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('refresh failure with data shows a SnackBar', (tester) async {
    whenListen(
      cubit,
      Stream.value(loaded.copyWith(failure: () => failure)),
      initialState: loaded,
    );
    await mockNetworkImages(
      () => tester.pumpApp(const PromotionsView(), cubit: cubit),
    );
    await tester.pump();

    expect(find.widgetWithText(SnackBar, failure.message), findsOneWidget);
    expect(find.byKey(ValueKey(tDepositPromotion.id)), findsOneWidget);
  });
}
