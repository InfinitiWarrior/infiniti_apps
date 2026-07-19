import 'package:flutter/material.dart';

/// A single convertible unit. Values move through a per-category base unit:
/// `toBase` converts this unit's value into the base, `fromBase` converts a
/// base value back into this unit. Linear units (everything but temperature)
/// use [Unit.linear], which derives both from a single conversion factor.
class Unit {
  const Unit(this.symbol, this.name, this.toBase, this.fromBase);

  factory Unit.linear(String symbol, String name, double factor) {
    return Unit(symbol, name, (v) => v * factor, (v) => v / factor);
  }

  final String symbol;
  final String name;
  final double Function(double value) toBase;
  final double Function(double value) fromBase;
}

enum UnitCategory {
  length('Length', Icons.straighten),
  mass('Mass', Icons.scale),
  temperature('Temperature', Icons.thermostat),
  volume('Volume', Icons.local_drink),
  area('Area', Icons.crop_square),
  speed('Speed', Icons.speed),
  time('Time', Icons.schedule),
  digitalStorage('Digital Storage', Icons.storage);

  const UnitCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Converts [value] from [from] to [to] via their shared category base unit.
double convertUnit(double value, Unit from, Unit to) => to.fromBase(from.toBase(value));

final Map<UnitCategory, List<Unit>> unitsByCategory = {
  UnitCategory.length: [
    Unit.linear('mm', 'Millimeters', 0.001),
    Unit.linear('cm', 'Centimeters', 0.01),
    Unit.linear('m', 'Meters', 1),
    Unit.linear('km', 'Kilometers', 1000),
    Unit.linear('in', 'Inches', 0.0254),
    Unit.linear('ft', 'Feet', 0.3048),
    Unit.linear('yd', 'Yards', 0.9144),
    Unit.linear('mi', 'Miles', 1609.344),
  ],
  UnitCategory.mass: [
    Unit.linear('mg', 'Milligrams', 0.000001),
    Unit.linear('g', 'Grams', 0.001),
    Unit.linear('kg', 'Kilograms', 1),
    Unit.linear('t', 'Tonnes', 1000),
    Unit.linear('oz', 'Ounces', 0.0283495),
    Unit.linear('lb', 'Pounds', 0.453592),
  ],
  UnitCategory.temperature: [
    Unit('°C', 'Celsius', _identity, _identity),
    Unit('°F', 'Fahrenheit', (f) => (f - 32) * 5 / 9, (c) => c * 9 / 5 + 32),
    Unit('K', 'Kelvin', (k) => k - 273.15, (c) => c + 273.15),
  ],
  UnitCategory.volume: [
    Unit.linear('ml', 'Milliliters', 0.001),
    Unit.linear('l', 'Liters', 1),
    Unit.linear('m³', 'Cubic meters', 1000),
    Unit.linear('gal', 'Gallons (US)', 3.78541),
    Unit.linear('qt', 'Quarts', 0.946353),
    Unit.linear('cup', 'Cups', 0.24),
    Unit.linear('fl oz', 'Fluid ounces', 0.0295735),
  ],
  UnitCategory.area: [
    Unit.linear('mm²', 'Sq. millimeters', 0.000001),
    Unit.linear('cm²', 'Sq. centimeters', 0.0001),
    Unit.linear('m²', 'Sq. meters', 1),
    Unit.linear('ha', 'Hectares', 10000),
    Unit.linear('km²', 'Sq. kilometers', 1000000),
    Unit.linear('ft²', 'Sq. feet', 0.092903),
    Unit.linear('ac', 'Acres', 4046.86),
  ],
  UnitCategory.speed: [
    Unit.linear('m/s', 'Meters/second', 1),
    Unit.linear('km/h', 'Kilometers/hour', 0.277778),
    Unit.linear('mph', 'Miles/hour', 0.44704),
    Unit.linear('kn', 'Knots', 0.514444),
    Unit.linear('ft/s', 'Feet/second', 0.3048),
  ],
  UnitCategory.time: [
    Unit.linear('ms', 'Milliseconds', 0.001),
    Unit.linear('s', 'Seconds', 1),
    Unit.linear('min', 'Minutes', 60),
    Unit.linear('hr', 'Hours', 3600),
    Unit.linear('day', 'Days', 86400),
    Unit.linear('week', 'Weeks', 604800),
  ],
  UnitCategory.digitalStorage: [
    Unit.linear('bit', 'Bits', 0.125),
    Unit.linear('B', 'Bytes', 1),
    Unit.linear('KB', 'Kilobytes', 1024),
    Unit.linear('MB', 'Megabytes', 1048576),
    Unit.linear('GB', 'Gigabytes', 1073741824),
    Unit.linear('TB', 'Terabytes', 1099511627776),
  ],
};

double _identity(double v) => v;
