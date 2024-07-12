import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, int> _counters = {};

  void startTimer(String key) {
    _timers[key] = Stopwatch()..start();
  }

  void stopTimer(String key) {
    final timer = _timers[key];
    if (timer != null) {
      timer.stop();
      debugPrint('Timer $key: ${timer.elapsedMilliseconds}ms');
    }
  }

  void incrementCounter(String key) {
    _counters[key] = (_counters[key] ?? 0) + 1;
  }

  void logCounters() {
    _counters.forEach((key, value) {
      debugPrint('Counter $key: $value');
    });
  }

  // Add methods for memory usage and battery consumption monitoring
}
