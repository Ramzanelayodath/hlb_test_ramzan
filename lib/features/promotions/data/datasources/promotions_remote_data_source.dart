import '../models/promotion_model.dart';

abstract interface class PromotionsRemoteDataSource {
  /// Throws `ServerException` when the API reports a failure.
  Future<List<PromotionModel>> fetchPromotions();
}
