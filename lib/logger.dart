import 'dart:collection';
import 'package:logger/logger.dart';

class _MemoryLogOutput extends LogOutput {
  static const int _maxLines = 2000;
  final ListQueue<String> _lines = ListQueue();

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      _lines.add(line);
      if (_lines.length > _maxLines) {
        _lines.removeFirst();
      }
    }
  }

  String get text {
    // Strip ANSI escape codes so the log file is plain text.
    final ansiEscape = RegExp(r'\x1B\[[\d;]*m');
    return _lines.map((l) => l.replaceAll(ansiEscape, '')).join('\n');
  }
}

class AppLoggerHelper {
  static final _MemoryLogOutput _memoryOutput = _MemoryLogOutput();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 5,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    output: MultiOutput([ConsoleOutput(), _memoryOutput]),
    level: Level.debug,
  );

  static bool _isInitialized = false;

  static void initialize() {
    _isInitialized = true;
  }

  static void debug(String message) {
    if (_isInitialized) _logger.d(message);
  }

  static void info(String message) {
    if (_isInitialized) _logger.i(message);
  }

  static void warning(String message) {
    if (_isInitialized) _logger.w(message);
  }

  static void error(String message, [dynamic error]) {
    if (_isInitialized) {
      _logger.e(message, error: error, stackTrace: StackTrace.current);
    }
  }

  static String getLogsAsText() => _memoryOutput.text;
}
