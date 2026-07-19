import 'package:app_calculator/database/calculator_database.dart';
import 'package:app_calculator/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('2 + 3 = 5', (WidgetTester tester) async {
    final database = CalculatorDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(CalculatorApp(database: database));

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    final display = tester.widget<Text>(
      find.byKey(const Key('calculator-display-value')),
    );
    expect(display.data, '5');
  });
}
