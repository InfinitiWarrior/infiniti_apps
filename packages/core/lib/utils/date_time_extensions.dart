import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  static final _dateFormat = DateFormat('MMM d, y');
  static final _timeFormat = DateFormat('h:mm a');
  static final _dateTimeFormat = DateFormat('MMM d, y · h:mm a');

  String get formattedDate => _dateFormat.format(this);
  String get formattedTime => _timeFormat.format(this);
  String get formattedDateTime => _dateTimeFormat.format(this);

  /// "3 minutes ago", "yesterday", "on Mar 4", etc.
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24 && now.day == day) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1 || (diff.inHours < 48 && now.day - day == 1)) {
      return 'yesterday';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return formattedDate;
  }
}
