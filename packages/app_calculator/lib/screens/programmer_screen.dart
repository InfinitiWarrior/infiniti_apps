import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/calculator_database.dart';
import '../services/programmer_engine.dart';
import '../widgets/base_value_row.dart';
import '../widgets/calculator_button.dart';
import '../widgets/mode_drawer.dart';

class ProgrammerScreen extends StatefulWidget {
  const ProgrammerScreen({super.key, required this.database});

  final CalculatorDatabase database;

  @override
  State<ProgrammerScreen> createState() => _ProgrammerScreenState();
}

class _ProgrammerScreenState extends State<ProgrammerScreen> {
  NumberBase _inputBase = NumberBase.dec;
  WordSize _wordSize = WordSize.dword32;

  BigInt _value = BigInt.zero;
  BigInt? _accumulator;
  String? _pendingOp;
  bool _startNewEntry = true;
  bool _error = false;

  void _onDigit(int digitValue) {
    if (digitValue >= _inputBase.radix) return;
    setState(() {
      _error = false;
      final digit = BigInt.from(digitValue);
      if (_startNewEntry) {
        _value = digit;
        _startNewEntry = false;
      } else {
        _value = ProgrammerEngine.mask(
          _value * BigInt.from(_inputBase.radix) + digit,
          _wordSize,
        );
      }
    });
  }

  void _onBaseSelected(NumberBase base) {
    setState(() => _inputBase = base);
  }

  void _onWordSizeSelected(WordSize size) {
    setState(() {
      _wordSize = size;
      _value = ProgrammerEngine.mask(_value, size);
      if (_accumulator != null) {
        _accumulator = ProgrammerEngine.mask(_accumulator!, size);
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      _error = false;
      if (_accumulator != null && _pendingOp != null && !_startNewEntry) {
        _accumulator = _safeEvaluate(_accumulator!, _pendingOp!, _value);
      } else {
        _accumulator = _value;
      }
      _pendingOp = op;
      _startNewEntry = true;
    });
  }

  BigInt _safeEvaluate(BigInt a, String op, BigInt b) {
    try {
      return ProgrammerEngine.evaluateBinary(a, op, b, _wordSize);
    } catch (_) {
      _error = true;
      return BigInt.zero;
    }
  }

  void _onEquals() {
    if (_accumulator == null || _pendingOp == null) return;
    setState(() {
      _value = _safeEvaluate(_accumulator!, _pendingOp!, _value);
      _accumulator = null;
      _pendingOp = null;
      _startNewEntry = true;
    });
  }

  void _onNot() {
    setState(() {
      _value = ProgrammerEngine.not(_value, _wordSize);
      _startNewEntry = true;
    });
  }

  void _onClear() {
    setState(() {
      _value = BigInt.zero;
      _accumulator = null;
      _pendingOp = null;
      _startNewEntry = true;
      _error = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_startNewEntry) {
        _value = BigInt.zero;
        return;
      }
      _value = _value ~/ BigInt.from(_inputBase.radix);
    });
  }

  String _formatFor(NumberBase base) =>
      _error ? 'Error' : ProgrammerEngine.format(_value, base);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ModeDrawer(
        currentMode: CalculatorMode.programmer,
        database: widget.database,
      ),
      appBar: const InfinitiAppBar(title: 'Programmer'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final base in NumberBase.values)
                BaseValueRow(
                  label: base.label,
                  value: _formatFor(base),
                  isActive: base == _inputBase,
                  onTap: () => _onBaseSelected(base),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    for (final size in WordSize.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          child: ChoiceChip(
                            label: Text(size.label),
                            selected: size == _wordSize,
                            onSelected: (_) => _onWordSizeSelected(size),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CalculatorButton(
                          label: 'A',
                          enabled: _inputBase.radix > 10,
                          onPressed: () => _onDigit(10),
                        ),
                        CalculatorButton(
                          label: 'B',
                          enabled: _inputBase.radix > 11,
                          onPressed: () => _onDigit(11),
                        ),
                        CalculatorButton(
                          label: 'C',
                          enabled: _inputBase.radix > 12,
                          onPressed: () => _onDigit(12),
                        ),
                        CalculatorButton(
                          label: '⌫',
                          style: CalculatorButtonStyle.function,
                          onPressed: _onBackspace,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: 'D',
                          enabled: _inputBase.radix > 13,
                          onPressed: () => _onDigit(13),
                        ),
                        CalculatorButton(
                          label: 'E',
                          enabled: _inputBase.radix > 14,
                          onPressed: () => _onDigit(14),
                        ),
                        CalculatorButton(
                          label: 'F',
                          enabled: _inputBase.radix > 15,
                          onPressed: () => _onDigit(15),
                        ),
                        CalculatorButton(
                          label: 'C',
                          style: CalculatorButtonStyle.function,
                          onPressed: _onClear,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: 'AND',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == 'AND',
                          onPressed: () => _onOperator('AND'),
                        ),
                        CalculatorButton(
                          label: 'OR',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == 'OR',
                          onPressed: () => _onOperator('OR'),
                        ),
                        CalculatorButton(
                          label: 'XOR',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == 'XOR',
                          onPressed: () => _onOperator('XOR'),
                        ),
                        CalculatorButton(
                          label: 'NOT',
                          style: CalculatorButtonStyle.operatorKey,
                          onPressed: _onNot,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: '<<',
                          flex: 2,
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == '<<',
                          onPressed: () => _onOperator('<<'),
                        ),
                        CalculatorButton(
                          label: '>>',
                          flex: 2,
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == '>>',
                          onPressed: () => _onOperator('>>'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: '7',
                          onPressed: () => _onDigit(7),
                        ),
                        CalculatorButton(
                          label: '8',
                          onPressed: () => _onDigit(8),
                        ),
                        CalculatorButton(
                          label: '9',
                          onPressed: () => _onDigit(9),
                        ),
                        CalculatorButton(
                          label: '÷',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == '÷',
                          onPressed: () => _onOperator('÷'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: '4',
                          onPressed: () => _onDigit(4),
                        ),
                        CalculatorButton(
                          label: '5',
                          onPressed: () => _onDigit(5),
                        ),
                        CalculatorButton(
                          label: '6',
                          onPressed: () => _onDigit(6),
                        ),
                        CalculatorButton(
                          label: '×',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == '×',
                          onPressed: () => _onOperator('×'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: '1',
                          onPressed: () => _onDigit(1),
                        ),
                        CalculatorButton(
                          label: '2',
                          onPressed: () => _onDigit(2),
                        ),
                        CalculatorButton(
                          label: '3',
                          onPressed: () => _onDigit(3),
                        ),
                        CalculatorButton(
                          label: '-',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == '-',
                          onPressed: () => _onOperator('-'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CalculatorButton(
                          label: '0',
                          flex: 2,
                          onPressed: () => _onDigit(0),
                        ),
                        CalculatorButton(
                          label: '+',
                          style: CalculatorButtonStyle.operatorKey,
                          isActive: _pendingOp == '+',
                          onPressed: () => _onOperator('+'),
                        ),
                        CalculatorButton(
                          label: '=',
                          style: CalculatorButtonStyle.equals,
                          onPressed: _onEquals,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
