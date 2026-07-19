import 'package:app_calculator/services/unit_converter.dart';
import 'package:flutter_test/flutter_test.dart';

Unit _unit(UnitCategory category, String symbol) =>
    unitsByCategory[category]!.firstWhere((u) => u.symbol == symbol);

void main() {
  group('Length', () {
    test('meters to kilometers', () {
      final m = _unit(UnitCategory.length, 'm');
      final km = _unit(UnitCategory.length, 'km');
      expect(convertUnit(1500, m, km), closeTo(1.5, 1e-9));
    });

    test('inches to centimeters', () {
      final inch = _unit(UnitCategory.length, 'in');
      final cm = _unit(UnitCategory.length, 'cm');
      expect(convertUnit(1, inch, cm), closeTo(2.54, 1e-9));
    });
  });

  group('Temperature', () {
    test('celsius to fahrenheit and back', () {
      final c = _unit(UnitCategory.temperature, '°C');
      final f = _unit(UnitCategory.temperature, '°F');
      expect(convertUnit(100, c, f), closeTo(212, 1e-9));
      expect(convertUnit(212, f, c), closeTo(100, 1e-9));
    });

    test('celsius to kelvin', () {
      final c = _unit(UnitCategory.temperature, '°C');
      final k = _unit(UnitCategory.temperature, 'K');
      expect(convertUnit(0, c, k), closeTo(273.15, 1e-9));
    });
  });

  group('Digital storage', () {
    test('kilobytes to bytes', () {
      final kb = _unit(UnitCategory.digitalStorage, 'KB');
      final b = _unit(UnitCategory.digitalStorage, 'B');
      expect(convertUnit(1, kb, b), 1024);
    });

    test('gigabytes to megabytes', () {
      final gb = _unit(UnitCategory.digitalStorage, 'GB');
      final mb = _unit(UnitCategory.digitalStorage, 'MB');
      expect(convertUnit(1, gb, mb), 1024);
    });
  });
}
