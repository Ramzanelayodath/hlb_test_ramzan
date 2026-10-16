import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';
import '../extensions/promotion_category_label.dart';
import 'promotions_empty_view.dart';
import 'promotions_error_view.dart';
import 'promotions_list.dart';
import 'promotions_loading_view.dart';

/// Switches between loading / error / empty / list. Read-status changes are
/// excluded from [BlocBuilder.buildWhen]; cards handle those themselves.
class PromotionsBody extends StatelessWidget {
  const PromotionsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionsCubit, PromotionsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.promotions != current.promotions ||
          previous.selectedCategory != current.selectedCategory ||
          (current.status == PromotionsStatus.failure &&
              previous.failure != current.failure),
      builder: (context, state) {
        switch (state.status) {
          case PromotionsStatus.initial:
          case PromotionsStatus.loading:
            return const PromotionsLoadingView();
          case PromotionsStatus.failure:
            return PromotionsErrorView(
              message: state.failure?.message ?? 'Something went wrong.',
            );
          case PromotionsStatus.loaded:
            if (state.isEmpty) {
              final category = state.selectedCategory;
              return PromotionsEmptyView(
                message: state.promotions.isEmpty || category == null
                    ? 'No promotions right now'
                    : 'No ${category.label} promotions',
              );
            }
            return PromotionsList(promotions: state.visiblePromotions);
        }
      },
    );
  }
}
