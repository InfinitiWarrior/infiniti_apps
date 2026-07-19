import 'package:flutter/material.dart';

/// Dark palette shared by every app. Catppuccin Mocha-inspired to match
/// the developer's Hyprland desktop theme. Tweak here to re-theme globally.
abstract final class AppColors {
  // Surfaces
  static const Color crust = Color(0xFF11111B);
  static const Color base = Color(0xFF1E1E2E);
  static const Color mantle = Color(0xFF181825);
  static const Color surface0 = Color(0xFF313244);
  static const Color surface1 = Color(0xFF45475A);
  static const Color surface2 = Color(0xFF585B70);

  // Text
  static const Color text = Color(0xFFCDD6F4);
  static const Color subtext1 = Color(0xFFBAC2DE);
  static const Color subtext0 = Color(0xFFA6ADC8);
  static const Color overlay = Color(0xFF6C7086);

  // Accents
  static const Color mauve = Color(0xFFCBA6F7);
  static const Color blue = Color(0xFF89B4FA);
  static const Color sapphire = Color(0xFF74C7EC);
  static const Color teal = Color(0xFF94E2D5);
  static const Color green = Color(0xFFA6E3A1);
  static const Color yellow = Color(0xFFF9E2AF);
  static const Color peach = Color(0xFFFAB387);
  static const Color red = Color(0xFFF38BA8);
  static const Color maroon = Color(0xFFEBA0AC);

  // Semantic aliases
  static const Color primary = mauve;
  static const Color secondary = blue;
  static const Color error = red;
  static const Color success = green;
  static const Color warning = yellow;
}
