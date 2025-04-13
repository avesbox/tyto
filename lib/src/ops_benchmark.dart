import 'dart:isolate';
import 'dart:math';

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
    await onRun();
  }

  /// Measures the benchmark for a given duration and returns the result.
  Future<BenchmarkResult> measure(Duration measureDuration) async {
    final results = [];
    for (int i = 0; i < 10; i++) {
      final result = await Isolate.run<double>(() async {
        await onSetup();
        await warmup();
        final stopwatch = Stopwatch()..start();
        int iterations = 0;
        while (stopwatch.elapsed < measureDuration) {
          await onRun();
          iterations++;
        }
        await onTeardown();
        stopwatch.stop();
        final score = iterations.toDouble();
        return score;
      });
      results.add(result);
    }
    final mean = results.reduce((a, b) => a + b) / results.length;
    final variance =
        results.map((e) => (e - mean) * (e - mean)).reduce((a, b) => a + b) /
            results.length;
    final stdDev = sqrt(variance);
    final stdDevPercentage = (stdDev / mean) * 100;
    return BenchmarkResult(
      name,
      group,
      mean,
      stdDevPercentage,
      stdDev,
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

  /// The standard deviation percentage of the benchmark case.
  final double stdDevPercentage;

  /// The standard deviation of the benchmark case.
  final double stdDev;

  /// Indicates if the benchmark case is the best case.
  const BenchmarkResult(
      this.name, this.group, this.avgScore, this.stdDevPercentage, this.stdDev);
}
