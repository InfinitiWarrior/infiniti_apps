import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../services/whois_service.dart';
import '../widgets/tools_drawer.dart';

class WhoisScreen extends StatefulWidget {
  WhoisScreen({super.key, required this.repository, WhoisService? whoisService})
    : whoisService = whoisService ?? PlatformWhoisService();

  final NetworkToolsRepository repository;
  final WhoisService whoisService;

  @override
  State<WhoisScreen> createState() => _WhoisScreenState();
}

class _WhoisScreenState extends State<WhoisScreen> {
  final _domainController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _result;
  bool _saved = false;

  Future<void> _lookup() async {
    final domain = _domainController.text.trim();
    if (domain.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _saved = false;
    });
    try {
      final result = await widget.whoisService.lookup(domain);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Lookup failed: $e';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final result = _result;
    if (result == null) return;
    final firstLine = result
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => 'Whois result');
    await widget.repository.saveResult(
      toolType: NetworkToolType.whois,
      target: _domainController.text.trim(),
      summary: firstLine,
      details: result,
    );
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'Whois'),
      drawer: ToolsDrawer(currentTool: NetworkTool.whois, repository: widget.repository),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _domainController,
                    decoration: const InputDecoration(
                      labelText: 'Domain',
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
              child: switch ((_loading, _error, _result)) {
                (true, _, _) => const LoadingIndicator(),
                (_, final error?, _) => Center(
                  child: Text(
                    error,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                (_, _, final result?) => SingleChildScrollView(
                  child: SelectableText(result, style: AppTextStyles.mono.copyWith(fontSize: 13)),
                ),
                _ => const EmptyState(
                  icon: Icons.badge_outlined,
                  message: 'Enter a domain and tap Lookup.',
                ),
              },
            ),
            if (_result != null) ...[
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
