import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/repositories/promotions_repository.dart';
import '../datasources/promotions_remote_data_source.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  const PromotionsRepositoryImpl(this._remoteDataSource);

  final PromotionsRemoteDataSource _remoteDataSource;

  /// Never throws: every exception is converted into a [Failure].
  @override
  Future<Result<List<Promotion>>> getPromotions() async {
    try {
      final models = await _remoteDataSource.fetchPromotions();
      // Items with an unknown category map to null and are skipped.
      return Success(models.map((m) => m.toEntity()).nonNulls.toList());
    } on ServerException catch (e) {
      return Err(ServerFailure(code: e.code, message: e.message));
    } catch (_) {
      return const Err(
        UnexpectedFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
