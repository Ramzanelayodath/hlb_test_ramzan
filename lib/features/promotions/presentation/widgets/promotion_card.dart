import 'package:flutter/material.dart';

import '../../domain/entities/promotion.dart';
import '../extensions/date_label.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({required this.promotion, super.key});

  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PromotionImage(url: promotion.imageUrl),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (promotion.isFeatured) ...[
                  const Chip(
                    key: Key('promotion_featured_badge'),
                    label: Text('Featured'),
                    avatar: Icon(Icons.star, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(promotion.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  promotion.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Valid until ${promotion.validUntil.toDateLabel()}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Image failures fall back to a placeholder and never break the card.
class _PromotionImage extends StatelessWidget {
  const _PromotionImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.image_not_supported_outlined)),
        ),
      ),
    );
  }
}
