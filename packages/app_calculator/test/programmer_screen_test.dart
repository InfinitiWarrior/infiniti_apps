import 'package:app_calculator/database/calculator_database.dart';
import 'package:app_calculator/screens/programmer_screen.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('15 in hex reads as F, and as 1111 in binary', (tester) async {
    final database = CalculatorDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ProgrammerScreen(database: database),
      ),
    );

    // Switch to hex input, enter F (=15).
    await tester.tap(find.text('HEX'));
    await tester.pump();
    await tester.tap(find.text('F'));
    await tester.pump();

    expect(find.text('F'), findsWidgets);
    expect(find.text('1111'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('17'), findsOneWidget); // octal
  });
}
