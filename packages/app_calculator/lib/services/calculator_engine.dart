import 'dart:math' as math;

import 'package:math_expressions/math_expressions.dart';

/// Evaluates binary operations via math_expressions, and applies scientific
/// unary functions directly. Kept free of any UI/state concerns so it can be
/// unit tested on its own.
class CalculatorEngine {
  CalculatorEngine({this.degreeMode = true});

  bool degreeMode;

  static const Map<String, String> _mathExpressionsOperators = {
    '+': '+',
    '-': '-',
    '×': '*',
    '÷': '/',
    '^': '^',
  };

  /// Evaluates `a <op> b` where op is one of +, -, ×, ÷, ^.
  double evaluateBinary(double a, String op, double b) {
    final symbol = _mathExpressionsOperators[op];
    if (symbol == null) {
      throw ArgumentError.value(op, 'op', 'Unsupported operator');
    }
    final parser = ShuntingYardParser();
    final expression = parser.parse('($a) $symbol ($b)');
    final result = expression.evaluate(EvaluationType.REAL, ContextModel());
    return (result as num).toDouble();
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  double sin(double x) => math.sin(degreeMode ? _toRadians(x) : x);
  double cos(double x) => math.cos(degreeMode ? _toRadians(x) : x);
  double tan(double x) => math.tan(degreeMode ? _toRadians(x) : x);

  double sqrt(double x) {
    if (x < 0) throw ArgumentError('Cannot take the square root of a negative number');
    return math.sqrt(x);
  }

  double square(double x) => x * x;

  double reciprocal(double x) {
    if (x == 0) throw ArgumentError('Cannot divide by zero');
    return 1 / x;
  }

  double log10(double x) {
    if (x <= 0) throw ArgumentError('Cannot take the log of a non-positive number');
    return math.log(x) / math.ln10;
  }

  double ln(double x) {
    if (x <= 0) throw ArgumentError('Cannot take the log of a non-positive number');
    return math.log(x);
  }

  double percent(double x) => x / 100;

  /// Formats a double for display: whole numbers show without a trailing
  /// ".0", others are trimmed of insignificant trailing zeros.
  static String format(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    var text = value.toStringAsFixed(10);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }
}
