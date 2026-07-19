import 'package:app_calculator/database/calculator_database.dart';
import 'package:app_calculator/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drawer navigates Standard -> Programmer -> Unit Converter -> Standard', (
    tester,
  ) async {
    final database = CalculatorDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(CalculatorApp(database: database));
    expect(find.text('Calculator'), findsOneWidget);

    // Open drawer and go to Programmer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Programmer'));
    await tester.pumpAndSettle();
    expect(find.text('Programmer'), findsWidgets);

    // From Programmer, go to Unit Converter.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unit Converter'));
    await tester.pumpAndSettle();
    expect(find.text('Unit Converter'), findsWidgets);

    // Back to Standard.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    expect(find.text('Calculator'), findsOneWidget);
  });
}
