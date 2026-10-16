import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/promotion.dart';
import '../repositories/promotions_repository.dart';

class GetPromotions implements UseCase<List<Promotion>, NoParams> {
  const GetPromotions(this._repository);

  final PromotionsRepository _repository;

  @override
  Future<Result<List<Promotion>>> call([NoParams params = const NoParams()]) =>
      _repository.getPromotions();
}
