import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_bar.dart';

/// A titled group of settings tiles, e.g. "Storage" or "Recording".
class SettingsSection {
  const SettingsSection({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;
}

/// Standard settings page shell every app should use for its settings screen.
/// Pass sections of tiles (e.g. [SwitchListTile], [ListTile]) to keep
/// layout and spacing consistent across apps.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.title = 'Settings', required this.sections});

  final String title;
  final List<SettingsSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(title: title),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(section.title, style: AppTextStyles.caption),
              ),
              ...section.tiles,
            ],
          );
        },
      ),
    );
  }
}
