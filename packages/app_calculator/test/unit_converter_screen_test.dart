import 'package:app_calculator/database/calculator_database.dart';
import 'package:app_calculator/screens/unit_converter_screen.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('converts 1 mm to cm by default', (tester) async {
    final database = CalculatorDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: UnitConverterScreen(database: database),
      ),
    );

    // Default category is Length: mm -> cm, input defaults to "1".
    expect(find.text('0.1'), findsOneWidget);
  });
}
