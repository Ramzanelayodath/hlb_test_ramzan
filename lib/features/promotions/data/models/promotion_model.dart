import '../../domain/entities/promotion.dart';
import '../../domain/entities/promotion_category.dart';

class PromotionModel {
  const PromotionModel({
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

  /// Throws [FormatException] when a field is missing or has the wrong type.
  /// An unknown category is not an error: it yields a `null` [category].
  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    try {
      return PromotionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        category: PromotionCategory.fromApi(json['category'] as String),
        validFrom: DateTime.parse(json['validFrom'] as String),
        validUntil: DateTime.parse(json['validUntil'] as String),
        ctaLabel: json['ctaLabel'] as String,
        isFeatured: json['isFeatured'] as bool,
      );
    } on TypeError catch (e) {
      throw FormatException('Malformed promotion JSON: $e');
    }
  }

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final PromotionCategory? category;
  final DateTime validFrom;
  final DateTime validUntil;
  final String ctaLabel;
  final bool isFeatured;

  /// Returns `null` for an unknown category so callers can skip the item
  /// instead of failing the whole list.
  Promotion? toEntity() {
    final category = this.category;
    if (category == null) return null;
    return Promotion(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      category: category,
      validFrom: validFrom,
      validUntil: validUntil,
      ctaLabel: ctaLabel,
      isFeatured: isFeatured,
    );
  }
}
