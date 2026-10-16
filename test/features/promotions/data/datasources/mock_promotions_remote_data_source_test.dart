import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/core/error/exceptions.dart';
import 'package:hlb_test/features/promotions/data/datasources/mock_promotions_remote_data_source.dart';
import 'package:hlb_test/features/promotions/data/mock/mock_scenario.dart';

void main() {
  MockPromotionsRemoteDataSource build(MockScenario scenario) =>
      MockPromotionsRemoteDataSource(scenario: scenario, delay: Duration.zero);

  test('success returns the 4 promotions from the payload', () async {
    final models = await build(MockScenario.success).fetchPromotions();

    expect(models, hasLength(4));
    expect(models.map((m) => m.id), [
      'promo-001',
      'promo-002',
      'promo-003',
      'promo-004',
    ]);
    expect(models[1].title, r'S$30 Grab voucher');
  });

  test('empty returns an empty list', () async {
    final models = await build(MockScenario.empty).fetchPromotions();
    expect(models, isEmpty);
  });

  test('error throws ServerException with code and message', () async {
    await expectLater(
      build(MockScenario.error).fetchPromotions(),
      throwsA(
        isA<ServerException>()
            .having((e) => e.code, 'code', 'ERR_PROMOTIONS_UNAVAILABLE')
            .having(
              (e) => e.message,
              'message',
              'Promotions are temporarily unavailable',
            ),
      ),
    );
  });

  test('MockScenario.fromName parses names and defaults to success', () {
    expect(MockScenario.fromName('empty'), MockScenario.empty);
    expect(MockScenario.fromName('ERROR'), MockScenario.error);
    expect(MockScenario.fromName('nonsense'), MockScenario.success);
  });
}
