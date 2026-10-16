import 'package:hlb_test/features/promotions/domain/entities/promotion.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion_category.dart';

final tDepositPromotion = Promotion(
  id: 'p1',
  title: 'Deposit bonus',
  description: 'Earn extra interest on new deposits.',
  imageUrl: 'https://example.com/deposit.png',
  category: PromotionCategory.deposit,
  validFrom: DateTime.utc(2026, 1, 1),
  validUntil: DateTime.utc(2026, 12, 31),
  ctaLabel: 'Deposit now',
  isFeatured: true,
);

final tCardPromotion = Promotion(
  id: 'p2',
  title: 'Card cashback',
  description: 'Get cashback on card spend.',
  imageUrl: 'https://example.com/card.png',
  category: PromotionCategory.card,
  validFrom: DateTime.utc(2026, 2, 1),
  validUntil: DateTime.utc(2026, 6, 30),
  ctaLabel: 'Apply',
  isFeatured: false,
);

final tTransferPromotion = Promotion(
  id: 'p3',
  title: 'Free transfers',
  description: 'Zero fees on overseas transfers.',
  imageUrl: 'https://example.com/transfer.png',
  category: PromotionCategory.transfer,
  validFrom: DateTime.utc(2026, 3, 1),
  validUntil: DateTime.utc(2026, 9, 30),
  ctaLabel: 'Transfer',
  isFeatured: false,
);

/// No referral promotion on purpose, so "empty for category" can be tested.
final tPromotions = [tDepositPromotion, tCardPromotion, tTransferPromotion];
