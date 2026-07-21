import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../database/nfc_database.dart';
import '../repositories/scan_repository.dart';
import '../services/nfc_service.dart';
import '../widgets/hex_dump_view.dart';
import '../widgets/tag_info_card.dart';

enum _ScanState { idle, scanning, result, error }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.nfcService, required this.repository});

  final NfcService nfcService;
  final ScanRepository repository;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  _ScanState _state = _ScanState.idle;
  TagInfo? _tagInfo;
  NfcTag? _rawTag;
  String? _errorMessage;
  List<int>? _dump;
  bool _dumping = false;
  bool _saved = false;

  Future<void> _startScan() async {
    setState(() {
      _state = _ScanState.scanning;
      _errorMessage = null;
      _tagInfo = null;
      _rawTag = null;
      _dump = null;
      _saved = false;
    });

    final availability = await widget.nfcService.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      if (!mounted) return;
      setState(() {
        _state = _ScanState.error;
        _errorMessage = _availabilityMessage(availability);
      });
      return;
    }

    await widget.nfcService.startSession(
      onDiscovered: (tag) async {
        final info = widget.nfcService.readTagInfo(tag);
        await widget.nfcService.stopSession();
        if (!mounted) return;
        setState(() {
          _rawTag = tag;
          _tagInfo = info;
          _state = _ScanState.result;
        });
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _state = _ScanState.error;
          _errorMessage = message;
        });
      },
    );
  }

  Future<void> _cancelScan() async {
    await widget.nfcService.stopSession();
    if (!mounted) return;
    setState(() => _state = _ScanState.idle);
  }

  Future<void> _dumpTag() async {
    if (_rawTag == null) return;
    setState(() => _dumping = true);
    final bytes = await widget.nfcService.dumpPages(_rawTag!);
    if (!mounted) return;
    setState(() {
      _dump = bytes;
      _dumping = false;
    });
  }

  Future<void> _saveToHistory() async {
    if (_tagInfo == null) return;
    await widget.repository.saveScan(
      direction: ScanDirection.read,
      info: _tagInfo!,
      dumpBytes: _dump,
    );
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to history')));
  }

  Future<void> _formatTag() async {
    if (_rawTag == null || _tagInfo == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Format tag?'),
        content: const Text('This erases the tag\'s NDEF content. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Format'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.nfcService.formatTag(_rawTag!);
      await widget.repository.saveScan(direction: ScanDirection.format, info: _tagInfo!);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Tag formatted.')));
      setState(() => _state = _ScanState.idle);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Format failed: $e')));
    }
  }

  String _availabilityMessage(NfcAvailability availability) {
    return switch (availability) {
      NfcAvailability.disabled => 'NFC is turned off. Enable it in your phone\'s settings.',
      NfcAvailability.unsupported => 'This device doesn\'t support NFC.',
      NfcAvailability.enabled => '',
    };
  }

  @override
  void dispose() {
    if (_state == _ScanState.scanning) {
      widget.nfcService.stopSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: switch (_state) {
        _ScanState.idle => _IdlePrompt(onScan: _startScan),
        _ScanState.scanning => _ScanningPrompt(onCancel: _cancelScan),
        _ScanState.error => _ErrorPrompt(
          message: _errorMessage ?? 'Something went wrong.',
          onRetry: _startScan,
        ),
        _ScanState.result => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TagInfoCard(info: _tagInfo!),
              if (_tagInfo!.canDump) ...[
                const SizedBox(height: AppSpacing.md),
                if (_dump == null)
                  OutlinedButton.icon(
                    onPressed: _dumping ? null : _dumpTag,
                    icon: const Icon(Icons.memory),
                    label: Text(_dumping ? 'Reading memory…' : 'Dump raw pages'),
                  )
                else
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Raw dump (${_dump!.length} bytes)', style: AppTextStyles.title),
                        const SizedBox(height: AppSpacing.sm),
                        HexDumpView(bytes: _dump!),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _saved ? null : _saveToHistory,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved' : 'Save to history'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _formatTag,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Format (erase) tag'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: _startScan, child: const Text('Scan another tag')),
            ],
          ),
        ),
      },
    );
  }
}

class _IdlePrompt extends StatelessWidget {
  const _IdlePrompt({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.nfc, size: 64, color: AppColors.overlay),
          const SizedBox(height: AppSpacing.md),
          const Text('Read a tag\'s info and NDEF content.', style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.nfc),
            label: const Text('Start scan'),
          ),
        ],
      ),
    );
  }
}

class _ScanningPrompt extends StatelessWidget {
  const _ScanningPrompt({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Hold the tag near your phone…', style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
        ],
      ),
    );
  }
}

class _ErrorPrompt extends StatelessWidget {
  const _ErrorPrompt({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
