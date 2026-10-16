import '../../domain/entities/promotion_category.dart';

extension PromotionCategoryLabel on PromotionCategory {
  String get label => switch (this) {
    PromotionCategory.deposit => 'Deposit',
    PromotionCategory.card => 'Card',
    PromotionCategory.transfer => 'Transfer',
    PromotionCategory.referral => 'Referral',
  };
}
