import 'package:flutter/material.dart';

/// Standard app bar. Styling comes from [AppTheme.dark]'s [AppBarTheme];
/// this just fixes the shape every app uses it in.
class InfinitiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InfinitiAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: actions, leading: leading);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
