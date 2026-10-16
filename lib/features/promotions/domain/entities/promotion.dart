import 'package:equatable/equatable.dart';

import 'promotion_category.dart';

/// A promotion as returned by the API. Read status is session state owned by
/// the Cubit, so it is intentionally not part of this entity.
class Promotion extends Equatable {
  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.validFrom,
    required this.validUntil,
    required this.ctaLabel,
    required this.isFeatured,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final PromotionCategory category;
  final DateTime validFrom;
  final DateTime validUntil;
  final String ctaLabel;
  final bool isFeatured;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    category,
    validFrom,
    validUntil,
    ctaLabel,
    isFeatured,
  ];
}
