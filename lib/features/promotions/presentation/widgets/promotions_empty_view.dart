import 'package:flutter/material.dart';

/// Scrollable so pull-to-refresh still works when there is nothing to show.
class PromotionsEmptyView extends StatelessWidget {
  const PromotionsEmptyView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('promotions_empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.local_offer_outlined, size: 48),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
