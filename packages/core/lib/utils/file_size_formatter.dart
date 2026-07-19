/// Formats byte counts as human-readable sizes, e.g. 1536 -> "1.5 KB".
abstract final class FileSizeFormatter {
  static const _units = ['B', 'KB', 'MB', 'GB', 'TB'];

  static String format(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';

    final exponent = (bytes.bitLength - 1) ~/ 10;
    final unitIndex = exponent.clamp(0, _units.length - 1);
    final value = bytes / (1 << (unitIndex * 10));

    return '${value.toStringAsFixed(unitIndex == 0 ? 0 : decimals)} ${_units[unitIndex]}';
  }
}
