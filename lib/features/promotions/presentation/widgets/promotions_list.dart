import 'package:flutter/material.dart';

import '../../domain/entities/promotion.dart';
import 'promotion_card.dart';

class PromotionsList extends StatelessWidget {
  const PromotionsList({required this.promotions, super.key});

  final List<Promotion> promotions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('promotions_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: promotions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final promotion = promotions[index];
        return PromotionCard(key: ValueKey(promotion.id), promotion: promotion);
      },
    );
  }
}
