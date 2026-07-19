import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../services/recording_format.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settingsService});

  final SettingsService settingsService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  RecordingFormat? _format;

  @override
  void initState() {
    super.initState();
    widget.settingsService.getFormat().then((value) {
      if (mounted) setState(() => _format = value);
    });
  }

  Future<void> _setFormat(RecordingFormat format) async {
    setState(() => _format = format);
    await widget.settingsService.setFormat(format);
  }

  @override
  Widget build(BuildContext context) {
    if (_format == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    return SettingsPage(
      sections: [
        SettingsSection(
          title: 'Recording',
          tiles: [
            RadioGroup<RecordingFormat>(
              groupValue: _format,
              onChanged: (value) {
                if (value != null) _setFormat(value);
              },
              child: Column(
                children: [
                  for (final format in RecordingFormat.values)
                    RadioListTile<RecordingFormat>(
                      title: Text(format.label, style: AppTextStyles.body),
                      subtitle: Text(
                        format == RecordingFormat.aac
                            ? 'Compressed, smaller files'
                            : 'Uncompressed, larger files',
                        style: AppTextStyles.caption,
                      ),
                      value: format,
                      activeColor: AppColors.primary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
