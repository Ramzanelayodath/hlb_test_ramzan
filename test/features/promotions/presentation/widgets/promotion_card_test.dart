import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_state.dart';
import 'package:hlb_test/features/promotions/presentation/widgets/promotion_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/promotion_fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockPromotionsCubit cubit;

  setUp(() {
    cubit = MockPromotionsCubit();
  });

  Future<void> pumpCard(WidgetTester tester, PromotionsState state) {
    when(() => cubit.state).thenReturn(state);
    return mockNetworkImages(
      () => tester.pumpApp(
        SingleChildScrollView(
          child: PromotionCard(promotion: tDepositPromotion),
        ),
        cubit: cubit,
      ),
    );
  }

  double opacityOf(WidgetTester tester) => tester
      .widget<Opacity>(
        find.descendant(
          of: find.byType(PromotionCard),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  testWidgets('unread card is fully opaque without a Read badge', (
    tester,
  ) async {
    await pumpCard(tester, const PromotionsState());

    expect(opacityOf(tester), 1);
    expect(find.byKey(const Key('promotion_read_badge')), findsNothing);
    expect(find.byKey(const Key('promotion_featured_badge')), findsOneWidget);
  });

  testWidgets('read card is dimmed and shows a Read badge', (tester) async {
    await pumpCard(tester, PromotionsState(readIds: {tDepositPromotion.id}));

    expect(opacityOf(tester), 0.6);
    expect(find.byKey(const Key('promotion_read_badge')), findsOneWidget);
  });

  testWidgets('tap opens the sheet; CTA marks as read and closes it', (
    tester,
  ) async {
    // Fixed pumps instead of pumpAndSettle: the image loading spinner keeps
    // animating because images never finish decoding under fake async.
    await mockNetworkImages(() async {
      await pumpCard(tester, const PromotionsState());

      await tester.tap(find.byType(PromotionCard));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('promotion_details_sheet')), findsOneWidget);

      await tester.tap(find.byKey(const Key('promotion_cta_button')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    });

    verify(() => cubit.markAsRead(tDepositPromotion.id)).called(1);
    expect(find.byKey(const Key('promotion_details_sheet')), findsNothing);
  });
}
