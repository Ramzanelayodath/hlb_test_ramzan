import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/features/promotions/presentation/widgets/promotion_details_sheet.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../../helpers/promotion_fixtures.dart';

void main() {
  testWidgets('shows the full details and CTA invokes the callback', (
    tester,
  ) async {
    var ctaPressed = 0;
    await mockNetworkImages(
      () => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromotionDetailsSheet(
              promotion: tDepositPromotion,
              onCtaPressed: () => ctaPressed++,
            ),
          ),
        ),
      ),
    );

    expect(find.text(tDepositPromotion.title), findsOneWidget);
    expect(find.text(tDepositPromotion.description), findsOneWidget);
    expect(find.text('Deposit'), findsOneWidget);
    expect(find.text('Valid 1 Jan 2026 – 31 Dec 2026'), findsOneWidget);

    await tester.tap(find.text(tDepositPromotion.ctaLabel));
    expect(ctaPressed, 1);
  });
}
