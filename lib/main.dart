import 'package:flutter/material.dart';

import 'core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const MaterialApp(home: Scaffold()));
}
