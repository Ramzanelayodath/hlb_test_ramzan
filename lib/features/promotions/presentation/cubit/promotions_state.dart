import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/entities/promotion_category.dart';

enum PromotionsStatus { initial, loading, loaded, failure }

/// A single state class with a [status] enum rather than sealed subclasses:
/// [selectedCategory] and [readIds] must survive load, refresh and error
/// transitions, and sealed states would have to copy them into every subclass.
class PromotionsState extends Equatable {
  const PromotionsState({
    this.status = PromotionsStatus.initial,
    this.promotions = const [],
    this.selectedCategory,
    this.readIds = const {},
    this.failure,
    this.isRefreshing = false,
  });

  /// Full list from the API, unfiltered.
  final List<Promotion> promotions;
  final PromotionsStatus status;

  /// `null` means "All".
  final PromotionCategory? selectedCategory;
  final Set<String> readIds;
  final Failure? failure;
  final bool isRefreshing;

  List<Promotion> get visiblePromotions {
    final category = selectedCategory;
    if (category == null) return promotions;
    return promotions.where((p) => p.category == category).toList();
  }

  /// Derived UI state, not a separate status.
  bool get isEmpty =>
      status == PromotionsStatus.loaded && visiblePromotions.isEmpty;

  bool isRead(String id) => readIds.contains(id);

  /// Nullable fields take a getter so they can be explicitly set to `null`.
  PromotionsState copyWith({
    PromotionsStatus? status,
    List<Promotion>? promotions,
    PromotionCategory? Function()? selectedCategory,
    Set<String>? readIds,
    Failure? Function()? failure,
    bool? isRefreshing,
  }) {
    return PromotionsState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      readIds: readIds ?? this.readIds,
      failure: failure != null ? failure() : this.failure,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    promotions,
    selectedCategory,
    readIds,
    failure,
    isRefreshing,
  ];
}
