import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';
import 'promotions_body.dart';

class PromotionsView extends StatelessWidget {
  const PromotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Side effect only: a refresh that fails while data is on screen keeps
    // the list and reports the failure in a SnackBar. Never rebuilds.
    return BlocListener<PromotionsCubit, PromotionsState>(
      listenWhen: (previous, current) =>
          current.status == PromotionsStatus.loaded &&
          current.failure != null &&
          previous.failure != current.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Promotions')),
        body: const PromotionsBody(),
      ),
    );
  }
}
