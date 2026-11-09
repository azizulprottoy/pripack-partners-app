import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'PripackSeller',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
