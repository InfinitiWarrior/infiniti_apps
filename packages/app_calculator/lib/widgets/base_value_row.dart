import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// A tappable row showing a value formatted in one number base (HEX/DEC/OCT/BIN).
/// Tapping it makes that base the active input base.
class BaseValueRow extends StatelessWidget {
  const BaseValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? AppColors.primary : AppColors.overlay,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: AppTextStyles.mono.copyWith(
                    fontSize: isActive ? 26 : 18,
                    color: isActive ? AppColors.text : AppColors.subtext0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
