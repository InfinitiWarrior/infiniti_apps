import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../services/ping_service.dart';
import '../services/traceroute_service.dart';
import '../widgets/tools_drawer.dart';

class TracerouteScreen extends StatefulWidget {
  TracerouteScreen({super.key, required this.repository, PingService? pingService})
    : tracerouteService = TracerouteService(pingService ?? PlatformPingService());

  final NetworkToolsRepository repository;
  final TracerouteService tracerouteService;

  @override
  State<TracerouteScreen> createState() => _TracerouteScreenState();
}

class _TracerouteScreenState extends State<TracerouteScreen> {
  final _hostController = TextEditingController();
  StreamSubscription<TracerouteHop>? _subscription;
  final List<TracerouteHop> _hops = [];
  bool _running = false;
  bool _saved = false;

  void _start() {
    final host = _hostController.text.trim();
    if (host.isEmpty || _running) return;
    setState(() {
      _hops.clear();
      _running = true;
      _saved = false;
    });
    _subscription = widget.tracerouteService.traceroute(host).listen(
      (hop) {
        if (!mounted) return;
        setState(() => _hops.add(hop));
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
    if (_hops.isEmpty) return;
    final reached = _hops.isNotEmpty && _hops.last.isDestination;
    await widget.repository.saveResult(
      toolType: NetworkToolType.traceroute,
      target: _hostController.text.trim(),
      summary: reached
          ? 'Reached in ${_hops.length} hops'
          : '${_hops.length} hops, destination not reached',
      details: _hops
          .map((h) => '${h.ttl}\t${h.address ?? '*'}${h.isDestination ? ' (destination)' : ''}')
          .join('\n'),
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
      appBar: const InfinitiAppBar(title: 'Traceroute'),
      drawer: ToolsDrawer(currentTool: NetworkTool.traceroute, repository: widget.repository),
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
                  child: Text(_running ? 'Stop' : 'Trace'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _hops.isEmpty
                  ? const EmptyState(
                      icon: Icons.route_outlined,
                      message: 'Enter a host and tap Trace.',
                    )
                  : ListView.builder(
                      itemCount: _hops.length,
                      itemBuilder: (context, index) {
                        final hop = _hops[index];
                        return ListTile(
                          dense: true,
                          leading: SizedBox(
                            width: 28,
                            child: Text('${hop.ttl}', style: AppTextStyles.mono),
                          ),
                          title: Text(
                            hop.address ?? '* (no reply)',
                            style: AppTextStyles.mono.copyWith(fontSize: 13),
                          ),
                          trailing: hop.isDestination
                              ? const Icon(Icons.flag, color: AppColors.success, size: 18)
                              : null,
                        );
                      },
                    ),
            ),
            if (_hops.isNotEmpty && !_running) ...[
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
