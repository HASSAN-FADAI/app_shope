enum LogLevel { debug, info, warn, error }

class AppLogger {
  AppLogger._();

  static Future<void> log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stack,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = level.name.toUpperCase();
    // ignore: avoid_print
    print('[$prefix][$timestamp] $message');
    if (error != null) {
      // ignore: avoid_print
      print('  Cause: $error');
    }
    if (stack != null) {
      // ignore: avoid_print
      print('  Stack: ${stack.toString().substring(0, 200)}');
    }
  }

  static void d(String message) => log(LogLevel.debug, message);
  static void i(String message) => log(LogLevel.info, message);
  static void w(String message, {Object? e}) =>
      log(LogLevel.warn, message, error: e);
  static void e(String message, {Object? error, StackTrace? stack}) =>
      log(LogLevel.error, message, error: error, stack: stack);
}
