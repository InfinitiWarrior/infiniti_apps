import 'package:core/core.dart';
import 'package:flutter/material.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({super.key, required this.expression, required this.value});

  /// The pending expression so far, e.g. "12 +", shown above the value.
  final String expression;

  /// The current entry or result, shown large.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            expression,
            style: AppTextStyles.bodyMuted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              key: const Key('calculator-display-value'),
              style: AppTextStyles.displayLarge,
            ),
          ),
        ],
      ),
    );
  }
}
