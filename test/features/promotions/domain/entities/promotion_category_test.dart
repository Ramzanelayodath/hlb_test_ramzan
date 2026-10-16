import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion_category.dart';

void main() {
  test('fromApi maps every known API value', () {
    expect(PromotionCategory.fromApi('DEPOSIT'), PromotionCategory.deposit);
    expect(PromotionCategory.fromApi('CARD'), PromotionCategory.card);
    expect(PromotionCategory.fromApi('TRANSFER'), PromotionCategory.transfer);
    expect(PromotionCategory.fromApi('REFERRAL'), PromotionCategory.referral);
  });

  test('fromApi returns null for unknown values', () {
    expect(PromotionCategory.fromApi('LOAN'), isNull);
  });
}
