import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../services/dns_service.dart';
import '../widgets/tools_drawer.dart';

class DnsLookupScreen extends StatefulWidget {
  DnsLookupScreen({super.key, required this.repository, DnsService? dnsService})
    : dnsService = dnsService ?? PlatformDnsService();

  final NetworkToolsRepository repository;
  final DnsService dnsService;

  @override
  State<DnsLookupScreen> createState() => _DnsLookupScreenState();
}

class _DnsLookupScreenState extends State<DnsLookupScreen> {
  final _hostController = TextEditingController();
  bool _loading = false;
  String? _error;
  List<InternetAddress>? _results;
  bool _saved = false;

  Future<void> _lookup() async {
    final host = _hostController.text.trim();
    if (host.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = null;
      _saved = false;
    });
    try {
      final results = await widget.dnsService.lookup(host);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final results = _results;
    if (results == null) return;
    await widget.repository.saveResult(
      toolType: NetworkToolType.dnsLookup,
      target: _hostController.text.trim(),
      summary: results.isEmpty
          ? 'No records found'
          : results.map((a) => a.address).join(', '),
      details: results.map((a) => '${a.address} (${a.type.name})').join('\n'),
    );
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'DNS Lookup'),
      drawer: ToolsDrawer(currentTool: NetworkTool.dnsLookup, repository: widget.repository),
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
                      labelText: 'Hostname',
                      hintText: 'e.g. example.com',
                    ),
                    onSubmitted: (_) => _lookup(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: _loading ? null : _lookup,
                  child: const Text('Lookup'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: switch ((_loading, _error, _results)) {
                (true, _, _) => const LoadingIndicator(),
                (_, final error?, _) => Center(
                  child: Text(
                    error,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                (_, _, final results?) when results.isEmpty => const EmptyState(
                  icon: Icons.dns_outlined,
                  message: 'No records found.',
                ),
                (_, _, final results?) => ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final address = results[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.dns_outlined),
                      title: Text(address.address, style: AppTextStyles.mono),
                      trailing: Text(address.type.name, style: AppTextStyles.caption),
                    );
                  },
                ),
                _ => const EmptyState(
                  icon: Icons.dns_outlined,
                  message: 'Enter a hostname and tap Lookup.',
                ),
              },
            ),
            if (_results != null) ...[
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
