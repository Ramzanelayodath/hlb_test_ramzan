import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/core/error/exceptions.dart';
import 'package:hlb_test/core/error/failures.dart';
import 'package:hlb_test/core/result/result.dart';
import 'package:hlb_test/features/promotions/data/datasources/promotions_remote_data_source.dart';
import 'package:hlb_test/features/promotions/data/models/promotion_model.dart';
import 'package:hlb_test/features/promotions/data/repositories/promotions_repository_impl.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/json_fixtures.dart';

class _MockRemoteDataSource extends Mock
    implements PromotionsRemoteDataSource {}

void main() {
  late _MockRemoteDataSource dataSource;
  late PromotionsRepositoryImpl repository;

  setUp(() {
    dataSource = _MockRemoteDataSource();
    repository = PromotionsRepositoryImpl(dataSource);
  });

  test('success maps models to entities', () async {
    final model = PromotionModel.fromJson(promotionJson());
    when(() => dataSource.fetchPromotions()).thenAnswer((_) async => [model]);

    final result = await repository.getPromotions();

    expect(result, isA<Success<List<Promotion>>>());
    expect((result as Success<List<Promotion>>).value, [model.toEntity()]);
  });

  test('skips items with an unknown category', () async {
    when(() => dataSource.fetchPromotions()).thenAnswer(
      (_) async => [
        PromotionModel.fromJson(promotionJson()),
        PromotionModel.fromJson(promotionJson(category: 'LOAN')),
      ],
    );

    final result = await repository.getPromotions();

    expect((result as Success<List<Promotion>>).value, hasLength(1));
  });

  test('ServerException maps to ServerFailure', () async {
    when(
      () => dataSource.fetchPromotions(),
    ).thenThrow(const ServerException(code: 'ERR_X', message: 'Unavailable'));

    final result = await repository.getPromotions();

    expect(
      (result as Err).failure,
      const ServerFailure(code: 'ERR_X', message: 'Unavailable'),
    );
  });

  test('unexpected exception maps to UnexpectedFailure', () async {
    when(
      () => dataSource.fetchPromotions(),
    ).thenThrow(const FormatException('bad json'));

    final result = await repository.getPromotions();

    expect((result as Err).failure, isA<UnexpectedFailure>());
  });
}
