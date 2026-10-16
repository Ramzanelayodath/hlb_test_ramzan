import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/promotion_category.dart';
import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';
import '../extensions/promotion_category_label.dart';

/// Horizontal `All | Deposit | Card | Transfer | Referral` filter.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  // `null` represents "All"; it is a UI choice, not a domain category.
  static const _options = <PromotionCategory?>[
    null,
    ...PromotionCategory.values,
  ];

  @override
  Widget build(BuildContext context) {
    // Selects only the chosen category, so loading data or marking a card as
    // read never rebuilds the filter bar.
    return BlocSelector<PromotionsCubit, PromotionsState, PromotionCategory?>(
      selector: (state) => state.selectedCategory,
      builder: (context, selected) {
        return SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _options[index];
              return ChoiceChip(
                key: Key('category_chip_${category?.name ?? 'all'}'),
                label: Text(category?.label ?? 'All'),
                selected: category == selected,
                onSelected: (_) =>
                    context.read<PromotionsCubit>().selectCategory(category),
              );
            },
          ),
        );
      },
    );
  }
}
