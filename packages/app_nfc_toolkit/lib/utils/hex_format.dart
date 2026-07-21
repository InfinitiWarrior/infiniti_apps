import 'dart:typed_data';

/// "de ad be ef" (space-separated, uppercase) — used for tag UIDs and hex
/// dump display.
String bytesToHex(List<int> bytes, {String separator = ' '}) {
  return bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(separator);
}

Uint8List hexToBytes(String hex) {
  final cleaned = hex.replaceAll(RegExp(r'\s+'), '');
  if (cleaned.length.isOdd) {
    throw const FormatException('Hex string must have an even number of digits.');
  }
  final bytes = Uint8List(cleaned.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    final byteHex = cleaned.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(byteHex, radix: 16);
  }
  return bytes;
}
