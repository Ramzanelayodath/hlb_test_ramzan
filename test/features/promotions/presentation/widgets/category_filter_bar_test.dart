import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/features/promotions/domain/entities/promotion_category.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_state.dart';
import 'package:hlb_test/features/promotions/presentation/widgets/category_filter_bar.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockPromotionsCubit cubit;

  setUp(() {
    cubit = MockPromotionsCubit();
  });

  ChoiceChip chip(WidgetTester tester, String name) =>
      tester.widget<ChoiceChip>(find.byKey(Key('category_chip_$name')));

  testWidgets('shows All plus every category, All selected by default', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const PromotionsState());
    await tester.pumpApp(const CategoryFilterBar(), cubit: cubit);

    for (final label in ['All', 'Deposit', 'Card', 'Transfer', 'Referral']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(chip(tester, 'all').selected, isTrue);
    expect(chip(tester, 'card').selected, isFalse);
  });

  testWidgets('highlights the selected category', (tester) async {
    when(() => cubit.state).thenReturn(
      const PromotionsState(selectedCategory: PromotionCategory.card),
    );
    await tester.pumpApp(const CategoryFilterBar(), cubit: cubit);

    expect(chip(tester, 'card').selected, isTrue);
    expect(chip(tester, 'all').selected, isFalse);
  });

  testWidgets('tapping a chip calls selectCategory', (tester) async {
    when(() => cubit.state).thenReturn(const PromotionsState());
    await tester.pumpApp(const CategoryFilterBar(), cubit: cubit);

    await tester.tap(find.byKey(const Key('category_chip_card')));
    verify(() => cubit.selectCategory(PromotionCategory.card)).called(1);

    await tester.tap(find.byKey(const Key('category_chip_all')));
    verify(() => cubit.selectCategory(null)).called(1);
  });
}
