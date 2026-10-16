import 'package:flutter/material.dart';

class PromotionsLoadingView extends StatelessWidget {
  const PromotionsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(key: Key('promotions_loading')),
    );
  }
}
