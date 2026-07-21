import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../services/port_scanner_service.dart';
import '../widgets/tools_drawer.dart';

enum _PortSelection { common, range }

class PortScannerScreen extends StatefulWidget {
  PortScannerScreen({super.key, required this.repository, PortScannerService? scannerService})
    : scannerService = scannerService ?? PlatformPortScannerService();

  final NetworkToolsRepository repository;
  final PortScannerService scannerService;

  @override
  State<PortScannerScreen> createState() => _PortScannerScreenState();
}

class _PortScannerScreenState extends State<PortScannerScreen> {
  final _hostController = TextEditingController();
  final _startPortController = TextEditingController(text: '1');
  final _endPortController = TextEditingController(text: '1024');
  _PortSelection _selection = _PortSelection.common;

  StreamSubscription<PortScanResult>? _subscription;
  final List<PortScanResult> _results = [];
  int _totalPorts = 0;
  bool _running = false;
  bool _saved = false;

  static const _maxRangeSize = 2000;

  List<int>? _resolvePorts() {
    if (_selection == _PortSelection.common) return commonPorts;
    final start = int.tryParse(_startPortController.text.trim());
    final end = int.tryParse(_endPortController.text.trim());
    if (start == null || end == null || start < 1 || end > 65535 || start > end) {
      return null;
    }
    if (end - start + 1 > _maxRangeSize) return null;
    return [for (var p = start; p <= end; p++) p];
  }

  void _start() {
    final host = _hostController.text.trim();
    final ports = _resolvePorts();
    if (host.isEmpty || ports == null || _running) return;

    setState(() {
      _results.clear();
      _totalPorts = ports.length;
      _running = true;
      _saved = false;
    });

    _subscription = widget.scannerService.scan(host, ports).listen(
      (result) {
        if (!mounted) return;
        setState(() => _results.add(result));
      },
      onDone: () {
        if (mounted) setState(() => _running = false);
      },
      onError: (Object _) {
        if (mounted) setState(() => _running = false);
      },
    );
  }

  void _stop() {
    _subscription?.cancel();
    setState(() => _running = false);
  }

  Future<void> _save() async {
    final openPorts = _results.where((r) => r.isOpen).map((r) => r.port).toList()..sort();
    await widget.repository.saveResult(
      toolType: NetworkToolType.portScan,
      target: _hostController.text.trim(),
      summary: openPorts.isEmpty
          ? 'No open ports found (${_results.length} scanned)'
          : '${openPorts.length} open: ${openPorts.join(', ')}',
      details: openPorts.map((p) => 'Port $p open').join('\n'),
    );
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hostController.dispose();
    _startPortController.dispose();
    _endPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openPorts = _results.where((r) => r.isOpen).toList();
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'Port Scanner'),
      drawer: ToolsDrawer(currentTool: NetworkTool.portScanner, repository: widget.repository),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: 'e.g. 192.168.1.1',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<_PortSelection>(
              segments: const [
                ButtonSegment(value: _PortSelection.common, label: Text('Common ports')),
                ButtonSegment(value: _PortSelection.range, label: Text('Range')),
              ],
              selected: {_selection},
              onSelectionChanged: (s) => setState(() => _selection = s.first),
            ),
            if (_selection == _PortSelection.range) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startPortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Start port'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _endPortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'End port'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _running ? _stop : _start,
              child: Text(_running ? 'Stop' : 'Scan'),
            ),
            if (_running || _results.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: _totalPorts == 0 ? null : _results.length / _totalPorts,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${_results.length}/$_totalPorts scanned · ${openPorts.length} open',
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: openPorts.isEmpty
                  ? EmptyState(
                      icon: Icons.settings_ethernet,
                      message: _results.isEmpty
                          ? 'Enter a host and tap Scan.'
                          : 'No open ports found.',
                    )
                  : ListView.builder(
                      itemCount: openPorts.length,
                      itemBuilder: (context, index) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                        title: Text('Port ${openPorts[index].port}', style: AppTextStyles.mono),
                      ),
                    ),
            ),
            if (_results.isNotEmpty && !_running) ...[
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _saved ? null : _save,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved' : 'Save to history'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
