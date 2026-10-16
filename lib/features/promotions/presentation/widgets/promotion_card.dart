import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/promotion.dart';
import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';
import '../extensions/date_label.dart';
import 'promotion_details_sheet.dart';
import 'promotion_image.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({required this.promotion, super.key});

  final Promotion promotion;

  Future<void> _openDetails(BuildContext context) {
    // Grab the Cubit before opening: the sheet's route is not under the
    // BlocProvider, and the sheet itself stays unaware of the Cubit.
    final cubit = context.read<PromotionsCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PromotionDetailsSheet(
        promotion: promotion,
        onCtaPressed: () {
          cubit.markAsRead(promotion.id);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Each card selects only its own read flag. Marking one promotion as read
    // rebuilds just that card; the list and the other cards are untouched.
    return BlocSelector<PromotionsCubit, PromotionsState, bool>(
      selector: (state) => state.isRead(promotion.id),
      builder: (context, isRead) {
        return Opacity(
          opacity: isRead ? 0.6 : 1,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openDetails(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PromotionImage(url: promotion.imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            if (promotion.isFeatured)
                              const Chip(
                                key: Key('promotion_featured_badge'),
                                label: Text('Featured'),
                                avatar: Icon(Icons.star, size: 16),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (isRead)
                              const Chip(
                                key: Key('promotion_read_badge'),
                                label: Text('Read'),
                                avatar: Icon(Icons.check, size: 16),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
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
            ),
          ),
        );
      },
    );
  }
}
