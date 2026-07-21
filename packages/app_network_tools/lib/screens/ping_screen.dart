import 'dart:async';

import 'package:core/core.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../services/ping_service.dart';
import '../widgets/tools_drawer.dart';

class PingScreen extends StatefulWidget {
  PingScreen({super.key, required this.repository, PingService? pingService})
    : pingService = pingService ?? PlatformPingService();

  final NetworkToolsRepository repository;
  final PingService pingService;

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  final _hostController = TextEditingController();
  StreamSubscription<PingEvent>? _subscription;
  final List<PingEvent> _events = [];
  bool _running = false;
  PingSummary? _summary;
  bool _saved = false;

  void _start() {
    final host = _hostController.text.trim();
    if (host.isEmpty || _running) return;
    setState(() {
      _events.clear();
      _summary = null;
      _running = true;
      _saved = false;
    });
    _subscription = widget.pingService.ping(host, count: 10).listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _events.add(event);
          if (event is PingSummary) {
            _summary = event;
            _running = false;
          }
        });
      },
      onError: (Object _) {
        if (mounted) setState(() => _running = false);
      },
      onDone: () {
        if (mounted) setState(() => _running = false);
      },
    );
  }

  void _stop() {
    _subscription?.cancel();
    setState(() => _running = false);
  }

  Future<void> _save() async {
    final summary = _summary;
    if (summary == null) return;
    final avg = summary.stats?.avg;
    await widget.repository.saveResult(
      toolType: NetworkToolType.ping,
      target: _hostController.text.trim(),
      summary:
          '${summary.received}/${summary.transmitted} received '
          '(${summary.packetLoss.toStringAsFixed(0)}% loss)'
          '${avg != null ? ', avg ${avg.inMilliseconds}ms' : ''}',
      details: _events.map((e) => e.toString()).join('\n'),
    );
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'Ping'),
      drawer: ToolsDrawer(currentTool: NetworkTool.ping, repository: widget.repository),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      hintText: 'e.g. 1.1.1.1 or example.com',
                    ),
                    onSubmitted: (_) => _start(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: _running ? _stop : _start,
                  child: Text(_running ? 'Stop' : 'Ping'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _events.isEmpty
                  ? const EmptyState(
                      icon: Icons.network_ping_outlined,
                      message: 'Enter a host and tap Ping.',
                    )
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) => _PingEventTile(event: _events[index]),
                    ),
            ),
            if (_summary != null) ...[
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

class _PingEventTile extends StatelessWidget {
  const _PingEventTile({required this.event});

  final PingEvent event;

  @override
  Widget build(BuildContext context) {
    return switch (event) {
      PingResponse(:final seq, :final ttl, :final time, :final ip) => ListTile(
        dense: true,
        leading: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
        title: Text(
          'seq=${seq ?? '?'} from $ip'
          '${ttl != null ? ' ttl=$ttl' : ''}'
          '${time != null ? ' time=${time.inMilliseconds}ms' : ''}',
          style: AppTextStyles.mono.copyWith(fontSize: 13),
        ),
      ),
      PingError(:final error, :final seq, :final ip) => ListTile(
        dense: true,
        leading: const Icon(Icons.error_outline, color: AppColors.error, size: 20),
        title: Text(
          '${error.message}${seq != null ? ' seq=$seq' : ''}${ip != null ? ' from $ip' : ''}',
          style: AppTextStyles.mono.copyWith(fontSize: 13),
        ),
      ),
      PingSummary(:final transmitted, :final received, :final packetLoss, :final stats) => ListTile(
        dense: true,
        leading: const Icon(Icons.flag_outlined, size: 20),
        title: Text(
          '$received/$transmitted received, ${packetLoss.toStringAsFixed(0)}% loss',
          style: AppTextStyles.body,
        ),
        subtitle: stats?.avg != null
            ? Text(
                'min/avg/max = ${stats!.min!.inMilliseconds}/${stats.avg!.inMilliseconds}/${stats.max!.inMilliseconds} ms',
                style: AppTextStyles.caption,
              )
            : null,
      ),
    };
  }
}
