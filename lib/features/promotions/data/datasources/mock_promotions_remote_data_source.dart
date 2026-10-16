import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../mock/mock_responses.dart';
import '../mock/mock_scenario.dart';
import '../models/promotion_model.dart';
import 'promotions_remote_data_source.dart';

class MockPromotionsRemoteDataSource implements PromotionsRemoteDataSource {
  const MockPromotionsRemoteDataSource({
    required this.scenario,
    this.delay = const Duration(milliseconds: 800),
  });

  final MockScenario scenario;
  final Duration delay;

  @override
  Future<List<PromotionModel>> fetchPromotions() async {
    await Future<void>.delayed(delay);
    final json = jsonDecode(_rawResponse) as Map<String, dynamic>;

    if (json['status'] != 'SUCCESS') {
      throw ServerException(
        code: json['errorCode'] as String? ?? 'UNKNOWN',
        message: json['message'] as String? ?? 'Something went wrong',
      );
    }

    final payload = json['payload'] as Map<String, dynamic>;
    final promotions = payload['promotions'] as List<dynamic>;
    return promotions
        .map((item) => PromotionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String get _rawResponse => switch (scenario) {
    MockScenario.success => MockResponses.success,
    MockScenario.empty => MockResponses.empty,
    MockScenario.error => MockResponses.error,
  };
}
