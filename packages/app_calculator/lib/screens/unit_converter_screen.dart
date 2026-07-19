import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/calculator_database.dart';
import '../services/calculator_engine.dart';
import '../services/unit_converter.dart';
import '../widgets/mode_drawer.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key, required this.database});

  final CalculatorDatabase database;

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  UnitCategory _category = UnitCategory.length;
  late Unit _fromUnit = unitsByCategory[_category]![0];
  late Unit _toUnit = unitsByCategory[_category]![1];
  final _inputController = TextEditingController(text: '1');
  String _result = '';

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _recompute() {
    final input = double.tryParse(_inputController.text) ?? 0;
    setState(() {
      _result = CalculatorEngine.format(convertUnit(input, _fromUnit, _toUnit));
    });
  }

  void _onCategoryChanged(UnitCategory category) {
    final units = unitsByCategory[category]!;
    setState(() {
      _category = category;
      _fromUnit = units[0];
      _toUnit = units.length > 1 ? units[1] : units[0];
    });
    _recompute();
  }

  void _swapUnits() {
    setState(() {
      final previousFrom = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = previousFrom;
    });
    _recompute();
  }

  @override
  Widget build(BuildContext context) {
    final units = unitsByCategory[_category]!;

    return Scaffold(
      drawer: ModeDrawer(
        currentMode: CalculatorMode.unitConverter,
        database: widget.database,
      ),
      appBar: const InfinitiAppBar(title: 'Unit Converter'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                itemCount: UnitCategory.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final category = UnitCategory.values[index];
                  return ChoiceChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: category == _category,
                    onSelected: (_) => _onCategoryChanged(category),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: AppTextStyles.headline,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) => _recompute(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _UnitDropdown(
                          value: _fromUnit,
                          units: units,
                          onChanged: (unit) {
                            setState(() => _fromUnit = unit);
                            _recompute();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.swap_vert, color: AppColors.primary),
                        tooltip: 'Swap units',
                        onPressed: _swapUnits,
                      ),
                    ),
                  ),
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _result,
                            style: AppTextStyles.headline,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _UnitDropdown(
                          value: _toUnit,
                          units: units,
                          onChanged: (unit) {
                            setState(() => _toUnit = unit);
                            _recompute();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.onChanged,
  });

  final Unit value;
  final List<Unit> units;
  final ValueChanged<Unit> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Unit>(
        value: value,
        dropdownColor: AppColors.surface1,
        style: AppTextStyles.body,
        items: [
          for (final unit in units)
            DropdownMenuItem(value: unit, child: Text('${unit.symbol} · ${unit.name}')),
        ],
        onChanged: (unit) {
          if (unit != null) onChanged(unit);
        },
      ),
    );
  }
}
