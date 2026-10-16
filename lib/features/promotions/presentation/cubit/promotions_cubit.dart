import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/promotion_category.dart';
import '../../domain/usecases/get_promotions.dart';
import 'promotions_state.dart';

class PromotionsCubit extends Cubit<PromotionsState> {
  PromotionsCubit(this._getPromotions) : super(const PromotionsState());

  final GetPromotions _getPromotions;

  /// Initial load and Retry. Emits loading, then loaded or failure.
  Future<void> load() async {
    emit(state.copyWith(status: PromotionsStatus.loading, failure: () => null));
    final result = await _getPromotions(const NoParams());
    if (isClosed) return;

    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            status: PromotionsStatus.loaded,
            promotions: value,
            failure: () => null,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: PromotionsStatus.failure,
            failure: () => failure,
          ),
        );
    }
  }

  /// Pull-to-refresh. Keeps the current list visible while fetching.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true, failure: () => null));
    final result = await _getPromotions(const NoParams());
    if (isClosed) return;

    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            status: PromotionsStatus.loaded,
            promotions: value,
            isRefreshing: false,
          ),
        );
      case Err(:final failure):
        // With data on screen, keep showing it and surface the failure as a
        // side effect (SnackBar). Without data, fall back to the error view.
        emit(
          state.copyWith(
            status: state.promotions.isNotEmpty
                ? PromotionsStatus.loaded
                : PromotionsStatus.failure,
            failure: () => failure,
            isRefreshing: false,
          ),
        );
    }
  }

  void selectCategory(PromotionCategory? category) {
    if (category == state.selectedCategory) return;
    emit(state.copyWith(selectedCategory: () => category));
  }

  void markAsRead(String id) {
    if (state.isRead(id)) return;
    emit(state.copyWith(readIds: {...state.readIds, id}));
  }
}
