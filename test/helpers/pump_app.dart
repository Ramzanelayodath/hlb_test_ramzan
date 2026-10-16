import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlb_test/features/promotions/presentation/cubit/promotions_cubit.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a MaterialApp with [cubit] provided above it.
  Future<void> pumpApp(Widget widget, {required PromotionsCubit cubit}) {
    return pumpWidget(
      BlocProvider<PromotionsCubit>.value(
        value: cubit,
        child: MaterialApp(home: Scaffold(body: widget)),
      ),
    );
  }
}
