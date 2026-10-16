import 'package:flutter/material.dart';

import '../../domain/entities/promotion.dart';
import '../extensions/date_label.dart';
import '../extensions/promotion_category_label.dart';
import 'promotion_image.dart';

/// Presentational only: knows nothing about the Cubit. The caller decides what
/// [onCtaPressed] does.
class PromotionDetailsSheet extends StatelessWidget {
  const PromotionDetailsSheet({
    required this.promotion,
    required this.onCtaPressed,
    super.key,
  });

  final Promotion promotion;
  final VoidCallback onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('promotion_details_sheet'),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PromotionImage(url: promotion.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(promotion.title, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(promotion.category.label, style: textTheme.labelLarge),
            const SizedBox(height: 12),
            Text(promotion.description, style: textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              'Valid ${promotion.validFrom.toDateLabel()} – '
              '${promotion.validUntil.toDateLabel()}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('promotion_cta_button'),
              onPressed: onCtaPressed,
              child: Text(promotion.ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}
