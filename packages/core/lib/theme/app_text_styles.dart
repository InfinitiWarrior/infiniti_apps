import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles shared across all apps. Use these instead of ad-hoc TextStyle
/// instances so type changes propagate globally.
abstract final class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    letterSpacing: -0.5,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.subtext0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.overlay,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 16,
    color: AppColors.text,
  );
}
