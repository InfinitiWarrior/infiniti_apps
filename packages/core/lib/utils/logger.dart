import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

/// Minimal logger used instead of print() everywhere. Routes through
/// dart:developer so output shows up in DevTools/`flutter logs` with levels,
/// and never leaks to a release console via bare print().
abstract final class AppLogger {
  static const _levelSeverity = {
    LogLevel.debug: 500,
    LogLevel.info: 800,
    LogLevel.warning: 900,
    LogLevel.error: 1000,
  };

  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String name = 'infiniti',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      level: _levelSeverity[level]!,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String name = 'infiniti'}) =>
      log(message, level: LogLevel.debug, name: name);

  static void info(String message, {String name = 'infiniti'}) =>
      log(message, level: LogLevel.info, name: name);

  static void warning(String message, {String name = 'infiniti'}) =>
      log(message, level: LogLevel.warning, name: name);

  static void error(
    String message, {
    String name = 'infiniti',
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.error,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );
}
