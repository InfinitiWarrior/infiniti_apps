import 'package:app_calculator/services/programmer_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgrammerEngine.format/parse', () {
    test('round-trips across bases', () {
      final value = BigInt.from(255);
      expect(ProgrammerEngine.format(value, NumberBase.hex), 'FF');
      expect(ProgrammerEngine.format(value, NumberBase.bin), '11111111');
      expect(ProgrammerEngine.format(value, NumberBase.oct), '377');
      expect(ProgrammerEngine.format(value, NumberBase.dec), '255');

      expect(ProgrammerEngine.parse('FF', NumberBase.hex), value);
      expect(ProgrammerEngine.parse('11111111', NumberBase.bin), value);
    });
  });

  group('ProgrammerEngine bitwise ops', () {
    test('AND/OR/XOR', () {
      final a = BigInt.from(0xF0);
      final b = BigInt.from(0x0F);
      expect(
        ProgrammerEngine.evaluateBinary(a, 'AND', b, WordSize.byte8),
        BigInt.zero,
      );
      expect(
        ProgrammerEngine.evaluateBinary(a, 'OR', b, WordSize.byte8),
        BigInt.from(0xFF),
      );
      expect(
        ProgrammerEngine.evaluateBinary(a, 'XOR', b, WordSize.byte8),
        BigInt.from(0xFF),
      );
    });

    test('NOT respects word size', () {
      expect(
        ProgrammerEngine.not(BigInt.zero, WordSize.byte8),
        BigInt.from(0xFF),
      );
      expect(
        ProgrammerEngine.not(BigInt.zero, WordSize.word16),
        BigInt.from(0xFFFF),
      );
    });

    test('shifts', () {
      expect(
        ProgrammerEngine.evaluateBinary(
          BigInt.one,
          '<<',
          BigInt.from(4),
          WordSize.byte8,
        ),
        BigInt.from(16),
      );
      expect(
        ProgrammerEngine.evaluateBinary(
          BigInt.from(16),
          '>>',
          BigInt.from(4),
          WordSize.byte8,
        ),
        BigInt.one,
      );
    });

    test('values wrap at the selected word size', () {
      expect(
        ProgrammerEngine.evaluateBinary(
          BigInt.from(200),
          '+',
          BigInt.from(100),
          WordSize.byte8,
        ),
        BigInt.from(44),
      );
    });

    test('division by zero throws', () {
      expect(
        () => ProgrammerEngine.evaluateBinary(
          BigInt.one,
          '÷',
          BigInt.zero,
          WordSize.byte8,
        ),
        throwsArgumentError,
      );
    });
  });
}
