import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/calculator_database.dart';
import '../screens/calculator_screen.dart';
import '../screens/programmer_screen.dart';
import '../screens/unit_converter_screen.dart';

enum CalculatorMode {
  standard('Standard', Icons.calculate_outlined),
  programmer('Programmer', Icons.memory_outlined),
  unitConverter('Unit Converter', Icons.swap_horiz);

  const CalculatorMode(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Drawer shared by every calculator mode screen so any mode can jump to
/// any other without stacking redundant routes.
class ModeDrawer extends StatelessWidget {
  const ModeDrawer({super.key, required this.currentMode, required this.database});

  final CalculatorMode currentMode;
  final CalculatorDatabase database;

  WidgetBuilder _builderFor(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.standard:
        return (_) => CalculatorScreen(database: database);
      case CalculatorMode.programmer:
        return (_) => ProgrammerScreen(database: database);
      case CalculatorMode.unitConverter:
        return (_) => UnitConverterScreen(database: database);
    }
  }

  void _navigate(BuildContext context, CalculatorMode mode) {
    Navigator.of(context).pop();
    if (mode == currentMode) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: _builderFor(mode)));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.mantle,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text('Calculator', style: AppTextStyles.headline),
            ),
            const Divider(height: 1),
            for (final mode in CalculatorMode.values)
              ListTile(
                leading: Icon(
                  mode.icon,
                  color: mode == currentMode ? AppColors.primary : AppColors.subtext0,
                ),
                title: Text(
                  mode.label,
                  style: AppTextStyles.body.copyWith(
                    color: mode == currentMode ? AppColors.primary : AppColors.text,
                    fontWeight: mode == currentMode ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: mode == currentMode,
                selectedTileColor: AppColors.surface0,
                onTap: () => _navigate(context, mode),
              ),
          ],
        ),
      ),
    );
  }
}
