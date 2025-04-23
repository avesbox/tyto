import 'dart:math';

import 'package:tyto/src/utils.dart';

/// A base class for running ops benchmarks in Dart.
class OpsBenchmarkBase {
  /// A function that will be called to set up the benchmark before running it.
  final Future<void> Function() onSetup;

  /// A function that will be called to tear down the benchmark after running it.
  final Future<void> Function() onTeardown;

  /// A function that will be called to run the benchmark.
  final Future<void> Function() onRun;

  /// The name of the benchmark.
  final String name;

  /// The group to which the benchmark belongs.
  final String group;

  /// Creates a new instance of [OpsBenchmarkBase].
  const OpsBenchmarkBase(
    this.name, {
    required this.onRun,
    this.group = 'default',
    this.onSetup = _emptySetup,
    this.onTeardown = _emptyTeardown,
  });

  static Future<void> _emptySetup() async {}
  static Future<void> _emptyTeardown() async {}

  /// Runs the benchmark.
  Future<void> run() {
    return onRun();
  }

  /// Warms up the benchmark by running it once before measuring.
  Future<void> warmup() async {
    for(int i = 0; i < 10; i++) {
      await onRun();
    }
  }

  /// Measures the benchmark for a given duration and returns the result.
  Future<BenchmarkResult> measure(Duration measureDuration) async {
    final results = [];
    List<int> iterationsMicroseconds = [];
    for (int i = 0; i < 10; i++) {
      await onSetup();
      await warmup();
      final stopwatch = Stopwatch()..start();
      int iterations = 0;
      while (stopwatch.elapsed < measureDuration) {
        final iterationStopwatch = Stopwatch()..start();
        await onRun();
        iterationStopwatch.stop();
        iterationsMicroseconds.add(iterationStopwatch.elapsedTicks);
        iterations++;
      }
      await onTeardown();
      stopwatch.stop();
      final result = iterations.toDouble();
      results.add(result);
    }
    final mean = results.reduce((a, b) => a + b) / results.length;
    final meanPerSecond = mean / measureDuration.inEffectiveSeconds;
    final variance = results
            .map((e) => pow(
                ((e / measureDuration.inEffectiveSeconds) - meanPerSecond), 2))
            .reduce((a, b) => a + b) /
        results.length;
    final stdDev = sqrt(variance);
    final stdDevPercentage = (stdDev / meanPerSecond) * 100;
    final sortedIterations = iterationsMicroseconds..sort();
    final p75Time = sortedIterations[(sortedIterations.length * 0.75).toInt()];
    final p95Time = sortedIterations[(sortedIterations.length * 0.95).toInt()];
    final p99Time = sortedIterations[(sortedIterations.length * 0.99).toInt()];
    final p999Time = sortedIterations[(sortedIterations.length * 0.999).toInt()];
    final minTime = sortedIterations.first;
    final maxTime = sortedIterations.last;
    final meanTime = iterationsMicroseconds.reduce((a, b) => a + b) /
        iterationsMicroseconds.length;
    return BenchmarkResult(
      name,
      group,
      mean,
      meanPerSecond,
      stdDevPercentage,
      stdDev,
      meanTime,
      minTime.toDouble(),
      maxTime.toDouble(),
      p75Time.toDouble(),
      p95Time.toDouble(),
      p99Time.toDouble(),
      p999Time.toDouble(),
    );
  }
}

/// A class representing the result of a benchmark case.
final class BenchmarkResult {
  /// The name of the benchmark case.
  final String name;

  /// The group name of the benchmark case.
  final String group;

  /// The average score of the benchmark case.
  final double avgScore;

  // The average score per second of the benchmark case.
  final double avgScorePerSecond;

  /// The standard deviation percentage of the benchmark case.
  final double stdDevPercentage;

  /// The standard deviation of the benchmark case.
  final double stdDev;

  /// The average time in microseconds per iteration of the benchmark case.
  final double avgTime;

  /// The minimum time in microseconds per iteration of the benchmark case.
  final double minTime;

  /// The maximum time in microseconds per iteration of the benchmark case.
  final double maxTime;

  /// p75 time in microseconds per iteration of the benchmark case.
  final double p75Time;

  /// p95 time in microseconds per iteration of the benchmark case.
  final double p95Time;

  /// p99 time in microseconds per iteration of the benchmark case.
  final double p99Time;

  /// p999 time in microseconds per iteration of the benchmark case.
  final double p999Time;

  factory BenchmarkResult.zero(String name, String group) {
    return BenchmarkResult(name, group, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
  }

  /// Indicates if the benchmark case is the best case.
  const BenchmarkResult(this.name, this.group, this.avgScore,
      this.avgScorePerSecond, this.stdDevPercentage, this.stdDev, this.avgTime, this.minTime,
      this.maxTime, this.p75Time, this.p95Time, this.p99Time, this.p999Time);
}
