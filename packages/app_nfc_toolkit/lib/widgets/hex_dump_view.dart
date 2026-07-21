import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Classic offset / hex / ASCII dump layout, 16 bytes per row.
class HexDumpView extends StatelessWidget {
  const HexDumpView({super.key, required this.bytes});

  final List<int> bytes;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    for (var offset = 0; offset < bytes.length; offset += 16) {
      final chunk = bytes.skip(offset).take(16).toList();
      final hex = chunk
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ')
          .padRight(47);
      final ascii = chunk
          .map((b) => (b >= 32 && b < 127) ? String.fromCharCode(b) : '.')
          .join();
      lines.add('${offset.toRadixString(16).padLeft(4, '0')}  $hex  $ascii');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(lines.join('\n'), style: AppTextStyles.mono),
    );
  }
}
