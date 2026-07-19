import 'package:app_calculator/services/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorEngine.evaluateBinary', () {
    final engine = CalculatorEngine();

    test('adds, subtracts, multiplies, divides', () {
      expect(engine.evaluateBinary(2, '+', 3), 5);
      expect(engine.evaluateBinary(5, '-', 3), 2);
      expect(engine.evaluateBinary(4, '×', 3), 12);
      expect(engine.evaluateBinary(9, '÷', 3), 3);
    });

    test('raises to a power', () {
      expect(engine.evaluateBinary(2, '^', 10), 1024);
    });
  });

  group('CalculatorEngine scientific functions', () {
    test('sin/cos in degree mode', () {
      final engine = CalculatorEngine(degreeMode: true);
      expect(engine.sin(90), closeTo(1, 1e-9));
      expect(engine.cos(0), closeTo(1, 1e-9));
    });

    test('sqrt and square', () {
      final engine = CalculatorEngine();
      expect(engine.sqrt(16), 4);
      expect(engine.square(4), 16);
    });
  });

  group('CalculatorEngine.format', () {
    test('formats whole numbers without a trailing decimal', () {
      expect(CalculatorEngine.format(5), '5');
      expect(CalculatorEngine.format(-2), '-2');
    });

    test('trims trailing zeros from decimals', () {
      expect(CalculatorEngine.format(1.5), '1.5');
    });
  });
}
