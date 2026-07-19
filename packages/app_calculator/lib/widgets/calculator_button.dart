import 'package:core/core.dart';
import 'package:flutter/material.dart';

enum CalculatorButtonStyle { digit, operatorKey, function, equals }

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = CalculatorButtonStyle.digit,
    this.flex = 1,
    this.isActive = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final CalculatorButtonStyle style;
  final int flex;
  final bool isActive;
  final bool enabled;

  Color _background() {
    if (isActive) return AppColors.primary;
    switch (style) {
      case CalculatorButtonStyle.digit:
        return AppColors.surface0;
      case CalculatorButtonStyle.operatorKey:
        return AppColors.surface1;
      case CalculatorButtonStyle.function:
        return AppColors.mantle;
      case CalculatorButtonStyle.equals:
        return AppColors.primary;
    }
  }

  Color _foreground() {
    if (!enabled) return AppColors.overlay;
    if (isActive || style == CalculatorButtonStyle.equals) return AppColors.crust;
    if (style == CalculatorButtonStyle.function) return AppColors.subtext0;
    return AppColors.text;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Material(
            color: _background(),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: 64,
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.title.copyWith(color: _foreground()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
