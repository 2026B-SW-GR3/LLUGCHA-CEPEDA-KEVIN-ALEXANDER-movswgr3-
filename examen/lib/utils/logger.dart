import 'dart:developer' as developer;

/// Niveles de severidad aceptados por la bitácora estructurada.
enum LogLevel { debug, info, warn, error }

/// Logger sencillo basado en `dart:developer`. Imprime en consola con un
/// prefijo legible para que las trazas se distingan fácilmente:
///
///   [DEBUG] SqlRepository -> mensaje
///   [INFO]  HiveRepository -> mensaje
///   [WARN]  HiveRepository -> mensaje
///   [ERROR] SqlRepository -> mensaje (+stack trace)
class Log {
  static const String _tag = 'DualPersistence';

  static void d(String origin, String message) =>
      _log(LogLevel.debug, origin, message);

  static void i(String origin, String message) =>
      _log(LogLevel.info, origin, message);

  static void w(String origin, String message) =>
      _log(LogLevel.warn, origin, message);

  static void e(
    String origin,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _log(LogLevel.error, origin, message, error, stackTrace);

  static void _log(
    LogLevel level,
    String origin,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final prefix = switch (level) {
      LogLevel.debug => '[DEBUG]',
      LogLevel.info => '[INFO]',
      LogLevel.warn => '[WARN]',
      LogLevel.error => '[ERROR]',
    };
    final line = '$prefix $origin -> $message';
    developer.log(line, name: _tag, error: error, stackTrace: stackTrace);
    // ignore: avoid_print
    print(line);
    if (error != null) {
      // ignore: avoid_print
      print('   causa: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print(stackTrace.toString().split('\n').take(6).join('\n'));
    }
  }
}
