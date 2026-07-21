import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../services/subnet_calculator.dart';
import '../widgets/tools_drawer.dart';

class SubnetCalculatorScreen extends StatefulWidget {
  const SubnetCalculatorScreen({super.key, required this.repository});

  final NetworkToolsRepository repository;

  @override
  State<SubnetCalculatorScreen> createState() => _SubnetCalculatorScreenState();
}

class _SubnetCalculatorScreenState extends State<SubnetCalculatorScreen> {
  final _ipController = TextEditingController(text: '192.168.1.0');
  double _prefixLength = 24;
  SubnetInfo? _info;
  String? _error;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _calculate();
    _ipController.addListener(_calculate);
  }

  void _calculate() {
    try {
      final info = calculateSubnet(_ipController.text.trim(), _prefixLength.round());
      setState(() {
        _info = info;
        _error = null;
        _saved = false;
      });
    } catch (e) {
      setState(() {
        _info = null;
        _error = e is FormatException ? 'Invalid IPv4 address.' : e.toString();
        _saved = false;
      });
    }
  }

  Future<void> _save() async {
    final info = _info;
    if (info == null) return;
    await widget.repository.saveResult(
      toolType: NetworkToolType.subnetCalc,
      target: '${_ipController.text.trim()}/${info.prefixLength}',
      summary: '${info.networkAddress} – ${info.broadcastAddress} (${info.usableHostCount} usable)',
      details:
          'Network: ${info.networkAddress}\n'
          'Broadcast: ${info.broadcastAddress}\n'
          'Subnet mask: ${info.subnetMask}\n'
          'Wildcard mask: ${info.wildcardMask}\n'
          '${info.firstHost != null ? 'Usable range: ${info.firstHost} – ${info.lastHost}\n' : ''}'
          'Total addresses: ${info.totalAddresses}\n'
          'Usable hosts: ${info.usableHostCount}',
    );
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'Subnet Calculator'),
      drawer: ToolsDrawer(currentTool: NetworkTool.subnetCalculator, repository: widget.repository),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'IP address', hintText: 'e.g. 192.168.1.0'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text('Prefix length', style: AppTextStyles.body),
                const Spacer(),
                Text('/${_prefixLength.round()}', style: AppTextStyles.title),
              ],
            ),
            Slider(
              value: _prefixLength,
              min: 0,
              max: 32,
              divisions: 32,
              label: '/${_prefixLength.round()}',
              onChanged: (value) {
                setState(() => _prefixLength = value);
                _calculate();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (_error != null)
              Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.error))
            else if (info != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Network address', info.networkAddress),
                    _InfoRow('Broadcast address', info.broadcastAddress),
                    _InfoRow('Subnet mask', info.subnetMask),
                    _InfoRow('Wildcard mask', info.wildcardMask),
                    if (info.firstHost != null)
                      _InfoRow('Usable range', '${info.firstHost} – ${info.lastHost}'),
                    _InfoRow('Total addresses', '${info.totalAddresses}'),
                    _InfoRow('Usable hosts', '${info.usableHostCount}'),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: (info == null || _saved) ? null : _save,
              icon: Icon(_saved ? Icons.check : Icons.save_outlined),
              label: Text(_saved ? 'Saved' : 'Save to history'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          Text(value, style: AppTextStyles.mono),
        ],
      ),
    );
  }
}
