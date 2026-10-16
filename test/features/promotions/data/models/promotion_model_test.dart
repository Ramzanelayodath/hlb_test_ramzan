import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/features/promotions/data/models/promotion_model.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion_category.dart';

import '../../../../helpers/json_fixtures.dart';

void main() {
  group('fromJson', () {
    test('parses all fields including dates', () {
      final model = PromotionModel.fromJson(promotionJson());

      expect(model.id, 'promo-001');
      expect(model.title, '2.88% p.a. Fixed Deposit');
      expect(model.description, 'Lock in SGD 10,000 for 6 months.');
      expect(model.imageUrl, 'https://picsum.photos/seed/promo1/400/200');
      expect(model.category, PromotionCategory.deposit);
      expect(model.validFrom, DateTime(2026, 10, 1));
      expect(model.validUntil, DateTime(2026, 12, 31));
      expect(model.ctaLabel, 'Apply now');
      expect(model.isFeatured, isTrue);
    });

    test('maps each category', () {
      const expected = {
        'DEPOSIT': PromotionCategory.deposit,
        'CARD': PromotionCategory.card,
        'TRANSFER': PromotionCategory.transfer,
        'REFERRAL': PromotionCategory.referral,
      };
      expected.forEach((raw, category) {
        expect(
          PromotionModel.fromJson(promotionJson(category: raw)).category,
          category,
        );
      });
    });

    test('unknown category yields null category instead of throwing', () {
      final model = PromotionModel.fromJson(promotionJson(category: 'LOAN'));
      expect(model.category, isNull);
    });

    test('missing field throws FormatException', () {
      final json = promotionJson()..remove('title');
      expect(() => PromotionModel.fromJson(json), throwsFormatException);
    });

    test('invalid date throws FormatException', () {
      final json = promotionJson()..['validFrom'] = 'not-a-date';
      expect(() => PromotionModel.fromJson(json), throwsFormatException);
    });
  });

  group('toEntity', () {
    test('maps to an equal Promotion', () {
      final entity = PromotionModel.fromJson(promotionJson()).toEntity();

      expect(
        entity,
        Promotion(
          id: 'promo-001',
          title: '2.88% p.a. Fixed Deposit',
          description: 'Lock in SGD 10,000 for 6 months.',
          imageUrl: 'https://picsum.photos/seed/promo1/400/200',
          category: PromotionCategory.deposit,
          validFrom: DateTime(2026, 10, 1),
          validUntil: DateTime(2026, 12, 31),
          ctaLabel: 'Apply now',
          isFeatured: true,
        ),
      );
    });

    test('returns null for an unknown category', () {
      final model = PromotionModel.fromJson(promotionJson(category: 'LOAN'));
      expect(model.toEntity(), isNull);
    });
  });
}
