import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'database/calculator_database.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(CalculatorApp(database: CalculatorDatabase()));
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key, required this.database});

  final CalculatorDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: CalculatorScreen(database: database),
    );
  }
}
