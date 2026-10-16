import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/promotions_cubit.dart';

/// Scrollable so pull-to-refresh still works alongside the Retry button.
class PromotionsErrorView extends StatelessWidget {
  const PromotionsErrorView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('promotions_error'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            key: const Key('promotions_retry_button'),
            onPressed: () => context.read<PromotionsCubit>().load(),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
