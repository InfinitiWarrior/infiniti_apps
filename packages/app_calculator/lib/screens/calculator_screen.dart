import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/calculator_database.dart';
import '../services/calculator_engine.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';
import '../widgets/mode_drawer.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.database});

  final CalculatorDatabase database;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _engine = CalculatorEngine();

  String _display = '0';
  double? _accumulator;
  String? _pendingOp;
  bool _startNewEntry = true;
  bool _scientificMode = false;

  String get _expressionLabel {
    if (_accumulator == null || _pendingOp == null) return '';
    return '${CalculatorEngine.format(_accumulator!)} $_pendingOp';
  }

  void _onDigit(String digit) {
    setState(() {
      if (_startNewEntry) {
        _display = digit;
        _startNewEntry = false;
      } else {
        _display = _display == '0' ? digit : _display + digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_startNewEntry) {
        _display = '0.';
        _startNewEntry = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      final current = double.tryParse(_display) ?? 0;
      if (_accumulator != null && _pendingOp != null && !_startNewEntry) {
        _accumulator = _safeEvaluate(_accumulator!, _pendingOp!, current);
        _display = CalculatorEngine.format(_accumulator!);
      } else {
        _accumulator = current;
      }
      _pendingOp = op;
      _startNewEntry = true;
    });
  }

  double _safeEvaluate(double a, String op, double b) {
    try {
      return _engine.evaluateBinary(a, op, b);
    } catch (_) {
      return double.nan;
    }
  }

  Future<void> _onEquals() async {
    if (_accumulator == null || _pendingOp == null) return;

    final a = _accumulator!;
    final op = _pendingOp!;
    final b = double.tryParse(_display) ?? 0;
    final aLabel = CalculatorEngine.format(a);
    final bLabel = _display;

    final result = _safeEvaluate(a, op, b);
    final resultLabel = CalculatorEngine.format(result);

    setState(() {
      _display = resultLabel;
      _accumulator = null;
      _pendingOp = null;
      _startNewEntry = true;
    });

    if (!result.isNaN) {
      await widget.database.addHistoryEntry('$aLabel $op $bLabel', resultLabel);
    }
  }

  void _onUnary(double Function(double) fn) {
    setState(() {
      final current = double.tryParse(_display) ?? 0;
      try {
        _display = CalculatorEngine.format(fn(current));
      } catch (_) {
        _display = 'Error';
      }
      _startNewEntry = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _accumulator = null;
      _pendingOp = null;
      _startNewEntry = true;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_startNewEntry || _display.length <= 1 || _display == 'Error') {
        _display = '0';
        _startNewEntry = true;
        return;
      }
      _display = _display.substring(0, _display.length - 1);
    });
  }

  void _onToggleSign() {
    setState(() {
      final current = double.tryParse(_display) ?? 0;
      _display = CalculatorEngine.format(current * -1);
    });
  }

  Future<void> _openHistory() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => HistoryScreen(database: widget.database)),
    );
    if (selected != null) {
      setState(() {
        _display = selected;
        _accumulator = null;
        _pendingOp = null;
        _startNewEntry = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ModeDrawer(currentMode: CalculatorMode.standard, database: widget.database),
      appBar: InfinitiAppBar(
        title: 'Calculator',
        actions: [
          IconButton(
            icon: Icon(
              _scientificMode ? Icons.functions : Icons.functions_outlined,
            ),
            tooltip: 'Scientific mode',
            onPressed: () => setState(() => _scientificMode = !_scientificMode),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: _openHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CalculatorDisplay(
                expression: _expressionLabel,
                value: _display,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                children: [
                  if (_scientificMode) _buildScientificRow(),
                  _buildRow(['C', '⌫', '%', '÷']),
                  _buildRow(['7', '8', '9', '×']),
                  _buildRow(['4', '5', '6', '-']),
                  _buildRow(['1', '2', '3', '+']),
                  _buildRow(['±', '0', '.', '=']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScientificRow() {
    return Row(
      children: [
        CalculatorButton(
          label: 'sin',
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.sin),
        ),
        CalculatorButton(
          label: 'cos',
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.cos),
        ),
        CalculatorButton(
          label: 'tan',
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.tan),
        ),
        CalculatorButton(
          label: '√x',
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.sqrt),
        ),
        CalculatorButton(
          label: 'x²',
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.square),
        ),
        CalculatorButton(
          label: 'ln',
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.ln),
        ),
        CalculatorButton(
          label: '^',
          style: CalculatorButtonStyle.operatorKey,
          isActive: _pendingOp == '^',
          onPressed: () => _onOperator('^'),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(children: keys.map(_buildButton).toList());
  }

  Widget _buildButton(String key) {
    switch (key) {
      case 'C':
        return CalculatorButton(
          label: key,
          style: CalculatorButtonStyle.function,
          onPressed: _onClear,
        );
      case '⌫':
        return CalculatorButton(
          label: key,
          style: CalculatorButtonStyle.function,
          onPressed: _onBackspace,
        );
      case '±':
        return CalculatorButton(
          label: key,
          style: CalculatorButtonStyle.function,
          onPressed: _onToggleSign,
        );
      case '%':
        return CalculatorButton(
          label: key,
          style: CalculatorButtonStyle.function,
          onPressed: () => _onUnary(_engine.percent),
        );
      case '.':
        return CalculatorButton(label: key, onPressed: _onDecimal);
      case '=':
        return CalculatorButton(
          label: key,
          style: CalculatorButtonStyle.equals,
          onPressed: _onEquals,
        );
      case '÷':
      case '×':
      case '-':
      case '+':
        return CalculatorButton(
          label: key,
          style: CalculatorButtonStyle.operatorKey,
          isActive: _pendingOp == key,
          onPressed: () => _onOperator(key),
        );
      default:
        return CalculatorButton(label: key, onPressed: () => _onDigit(key));
    }
  }
}
