enum NumberBase {
  bin(2, 'BIN'),
  oct(8, 'OCT'),
  dec(10, 'DEC'),
  hex(16, 'HEX');

  const NumberBase(this.radix, this.label);
  final int radix;
  final String label;
}

enum WordSize {
  byte8(8, 'BYTE'),
  word16(16, 'WORD'),
  dword32(32, 'DWORD'),
  qword64(64, 'QWORD');

  const WordSize(this.bits, this.label);
  final int bits;
  final String label;
}

/// Integer/bitwise engine backing programmer mode. Uses BigInt throughout so
/// QWORD (64-bit unsigned) values round-trip correctly — Dart's native `int`
/// can't represent the top half of the unsigned 64-bit range.
abstract final class ProgrammerEngine {
  static BigInt mask(BigInt value, WordSize size) => value.toUnsigned(size.bits);

  static BigInt not(BigInt value, WordSize size) => mask(~value, size);

  static String format(BigInt value, NumberBase base) =>
      value.toRadixString(base.radix).toUpperCase();

  static BigInt parse(String digits, NumberBase base) =>
      digits.isEmpty ? BigInt.zero : BigInt.parse(digits, radix: base.radix);

  static BigInt evaluateBinary(BigInt a, String op, BigInt b, WordSize size) {
    final BigInt result;
    switch (op) {
      case 'AND':
        result = a & b;
      case 'OR':
        result = a | b;
      case 'XOR':
        result = a ^ b;
      case '<<':
        result = a << b.toInt();
      case '>>':
        result = a >> b.toInt();
      case '+':
        result = a + b;
      case '-':
        result = a - b;
      case '×':
        result = a * b;
      case '÷':
        if (b == BigInt.zero) throw ArgumentError('Cannot divide by zero');
        result = a ~/ b;
      default:
        throw ArgumentError.value(op, 'op', 'Unsupported operator');
    }
    return mask(result, size);
  }
}
