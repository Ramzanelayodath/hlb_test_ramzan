import 'package:flutter/material.dart';

import '../features/promotions/presentation/pages/promotions_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promotions',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const PromotionsPage(),
    );
  }
}
