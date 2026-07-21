/// Parses "a.b.c.d" into a 32-bit value packed into a (64-bit) Dart [int].
int parseIPv4(String address) {
  final parts = address.split('.');
  if (parts.length != 4) {
    throw const FormatException('Expected 4 dot-separated octets.');
  }
  var result = 0;
  for (final part in parts) {
    final octet = int.tryParse(part);
    if (octet == null || octet < 0 || octet > 255) {
      throw FormatException('Invalid octet: "$part".');
    }
    result = (result << 8) | octet;
  }
  return result;
}

String formatIPv4(int address) {
  return [
    (address >> 24) & 0xFF,
    (address >> 16) & 0xFF,
    (address >> 8) & 0xFF,
    address & 0xFF,
  ].join('.');
}

bool isValidIPv4(String address) {
  try {
    parseIPv4(address);
    return true;
  } on FormatException {
    return false;
  }
}
