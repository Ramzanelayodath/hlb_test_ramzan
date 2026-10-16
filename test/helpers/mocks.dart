import 'package:bloc_test/bloc_test.dart';
import 'package:hlb_test/features/promotions/domain/usecases/get_promotions.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_cubit.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPromotions extends Mock implements GetPromotions {}

class MockPromotionsCubit extends MockCubit<PromotionsState>
    implements PromotionsCubit {}
