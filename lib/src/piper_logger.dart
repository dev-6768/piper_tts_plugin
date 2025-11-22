class PiperLogger {
  PiperLogger._(); // private constructor
  static final PiperLogger instance = PiperLogger._();

  bool enabled = true; // can disable from anywhere
  LogLevel level = LogLevel.debug;

  void log(String message, {LogLevel logLevel = LogLevel.info}) {
    if (!enabled) return;
    if (logLevel.index < level.index) return;

    final time = DateTime.now().toIso8601String();
    final tag = _colorize("[${logLevel.name.toUpperCase()}]", logLevel);
    print("$time $tag $message");
  }

  void debug(String msg) => log(msg, logLevel: LogLevel.debug);
  void info(String msg)  => log(msg, logLevel: LogLevel.info);
  void warn(String msg)  => log(msg, logLevel: LogLevel.warning);
  void error(String msg) => log(msg, logLevel: LogLevel.error);

  String _colorize(String text, LogLevel lvl) {
    switch (lvl) {
      case LogLevel.debug: return "\x1B[90m$text\x1B[0m";   // grey
      case LogLevel.info: return "\x1B[34m$text\x1B[0m";    // blue
      case LogLevel.warning: return "\x1B[33m$text\x1B[0m"; // yellow
      case LogLevel.error: return "\x1B[31m$text\x1B[0m";   // red
    }
  }
}

enum LogLevel { debug, info, warning, error }
