import '../../../../core/result/result.dart';
import '../entities/promotion.dart';

abstract interface class PromotionsRepository {
  Future<Result<List<Promotion>>> getPromotions();
}
