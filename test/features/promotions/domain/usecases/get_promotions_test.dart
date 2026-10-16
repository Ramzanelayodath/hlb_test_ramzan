import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/core/error/failures.dart';
import 'package:hlb_test/core/result/result.dart';
import 'package:hlb_test/features/promotions/domain/repositories/promotions_repository.dart';
import 'package:hlb_test/features/promotions/domain/usecases/get_promotions.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/promotion_fixtures.dart';

class _MockPromotionsRepository extends Mock implements PromotionsRepository {}

void main() {
  late _MockPromotionsRepository repository;
  late GetPromotions useCase;

  setUp(() {
    repository = _MockPromotionsRepository();
    useCase = GetPromotions(repository);
  });

  test('returns the repository success result unchanged', () async {
    final expected = Success(tPromotions);
    when(() => repository.getPromotions()).thenAnswer((_) async => expected);

    final result = await useCase();

    expect(result, same(expected));
    verify(() => repository.getPromotions()).called(1);
  });

  test('returns the repository failure result unchanged', () async {
    const failure = ServerFailure(code: 'X', message: 'boom');
    when(
      () => repository.getPromotions(),
    ).thenAnswer((_) async => const Err(failure));

    final result = await useCase();

    expect(result, isA<Err<dynamic>>());
    expect((result as Err).failure, failure);
  });
}
