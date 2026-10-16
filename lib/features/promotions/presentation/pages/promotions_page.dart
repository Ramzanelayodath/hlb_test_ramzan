import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/promotions_cubit.dart';
import '../widgets/promotions_view.dart';

/// Owns the Cubit's lifecycle. Everything below reads it from context.
class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PromotionsCubit>()..load(),
      child: const PromotionsView(),
    );
  }
}
