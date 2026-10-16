import 'package:get_it/get_it.dart';

import '../../features/promotions/data/datasources/mock_promotions_remote_data_source.dart';
import '../../features/promotions/data/datasources/promotions_remote_data_source.dart';
import '../../features/promotions/data/mock/mock_scenario.dart';
import '../../features/promotions/data/repositories/promotions_repository_impl.dart';
import '../../features/promotions/domain/repositories/promotions_repository.dart';
import '../../features/promotions/domain/usecases/get_promotions.dart';

final sl = GetIt.instance;

/// Composition root. The only place that knows about concrete implementations.
void configureDependencies({MockScenario? scenario}) {
  sl
    ..registerLazySingleton<PromotionsRemoteDataSource>(
      () => MockPromotionsRemoteDataSource(
        scenario: scenario ?? _scenarioFromEnv(),
      ),
    )
    ..registerLazySingleton<PromotionsRepository>(
      () => PromotionsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetPromotions(sl()));
}

MockScenario _scenarioFromEnv() => MockScenario.fromName(
  const String.fromEnvironment('PROMO_SCENARIO', defaultValue: 'success'),
);
