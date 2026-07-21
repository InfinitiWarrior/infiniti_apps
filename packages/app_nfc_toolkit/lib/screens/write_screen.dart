import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../database/nfc_database.dart';
import '../repositories/scan_repository.dart';
import '../services/ndef_codec.dart';
import '../services/nfc_service.dart';
import '../widgets/tag_info_card.dart';

enum _WriteState { form, scanning, success, error }
enum _RecordType { text, uri }

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key, required this.nfcService, required this.repository});

  final NfcService nfcService;
  final ScanRepository repository;

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  _WriteState _state = _WriteState.form;
  _RecordType _type = _RecordType.text;
  final _contentController = TextEditingController();
  String? _errorMessage;
  TagInfo? _tagInfo;
  NdefMessage? _writtenMessage;
  bool _saved = false;

  @override
  void dispose() {
    if (_state == _WriteState.scanning) {
      widget.nfcService.stopSession();
    }
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _startWrite() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    final record = _type == _RecordType.text ? encodeTextRecord(content) : encodeUriRecord(content);
    final message = NdefMessage(records: [record]);

    setState(() {
      _state = _WriteState.scanning;
      _errorMessage = null;
      _saved = false;
    });

    final availability = await widget.nfcService.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      if (!mounted) return;
      setState(() {
        _state = _WriteState.error;
        _errorMessage = _availabilityMessage(availability);
      });
      return;
    }

    await widget.nfcService.startSession(
      onDiscovered: (tag) async {
        try {
          await widget.nfcService.writeNdefMessage(tag, message);
          final info = widget.nfcService.readTagInfo(tag);
          await widget.nfcService.stopSession();
          if (!mounted) return;
          setState(() {
            _tagInfo = info;
            _writtenMessage = message;
            _state = _WriteState.success;
          });
        } catch (e) {
          await widget.nfcService.stopSession();
          if (!mounted) return;
          setState(() {
            _state = _WriteState.error;
            _errorMessage = 'Write failed: $e';
          });
        }
      },
      onError: (errorMessage) {
        if (!mounted) return;
        setState(() {
          _state = _WriteState.error;
          _errorMessage = errorMessage;
        });
      },
    );
  }

  Future<void> _cancelScan() async {
    await widget.nfcService.stopSession();
    if (!mounted) return;
    setState(() => _state = _WriteState.form);
  }

  Future<void> _saveToHistory() async {
    if (_tagInfo == null) return;
    await widget.repository.saveScan(
      direction: ScanDirection.write,
      info: _tagInfo!,
      message: _writtenMessage,
    );
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to history')));
  }

  void _writeAnother() {
    setState(() => _state = _WriteState.form);
  }

  String _availabilityMessage(NfcAvailability availability) {
    return switch (availability) {
      NfcAvailability.disabled => 'NFC is turned off. Enable it in your phone\'s settings.',
      NfcAvailability.unsupported => 'This device doesn\'t support NFC.',
      NfcAvailability.enabled => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: switch (_state) {
        _WriteState.form => _WriteForm(
          type: _type,
          controller: _contentController,
          onTypeChanged: (type) => setState(() => _type = type),
          onWrite: _startWrite,
        ),
        _WriteState.scanning => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 64, height: 64, child: CircularProgressIndicator()),
              const SizedBox(height: AppSpacing.md),
              const Text('Hold the tag near your phone…', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: _cancelScan, child: const Text('Cancel')),
            ],
          ),
        ),
        _WriteState.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage ?? 'Something went wrong.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: _startWrite, child: const Text('Try again')),
            ],
          ),
        ),
        _WriteState.success => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: AppSpacing.sm),
                  Text('Written successfully', style: AppTextStyles.title),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TagInfoCard(info: _tagInfo!),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _saved ? null : _saveToHistory,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved' : 'Save to history'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: _writeAnother, child: const Text('Write another tag')),
            ],
          ),
        ),
      },
    );
  }
}

class _WriteForm extends StatelessWidget {
  const _WriteForm({
    required this.type,
    required this.controller,
    required this.onTypeChanged,
    required this.onWrite,
  });

  final _RecordType type;
  final TextEditingController controller;
  final ValueChanged<_RecordType> onTypeChanged;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Write an NDEF record to a tag.', style: AppTextStyles.bodyMuted),
        const SizedBox(height: AppSpacing.md),
        SegmentedButton<_RecordType>(
          segments: const [
            ButtonSegment(
              value: _RecordType.text,
              label: Text('Text'),
              icon: Icon(Icons.text_fields),
            ),
            ButtonSegment(
              value: _RecordType.uri,
              label: Text('URI'),
              icon: Icon(Icons.link),
            ),
          ],
          selected: {type},
          onSelectionChanged: (selection) => onTypeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: type == _RecordType.text ? 4 : 1,
          keyboardType: type == _RecordType.uri ? TextInputType.url : TextInputType.multiline,
          decoration: InputDecoration(
            labelText: type == _RecordType.text ? 'Text' : 'URI',
            hintText: type == _RecordType.text ? 'Note to store on the tag' : 'https://example.com',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onWrite,
          icon: const Icon(Icons.nfc),
          label: const Text('Write to tag'),
        ),
      ],
    );
  }
}
