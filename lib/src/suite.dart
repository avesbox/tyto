import 'dart:io';

import 'package:tyto/src/models/case_result.dart';
import 'package:tyto/src/ops_benchmark.dart';
import 'package:tyto/src/report.dart';

/// A class that represents a suite of benchmarks.
class Suite {
  /// The duration for which each benchmark will be run.
  final Duration measureDuration;

  /// A list of benchmarks to be run in the suite.
  final List<OpsBenchmarkBase> _benchmarks = [];

  /// A list of reports to be generated after running the benchmarks.
  final List<Report> _reports = [];

  /// A map that stores the scores of each benchmark.
  final Map<int, BenchmarkResult> _scores = {};

  /// A map that stores the results of each benchmark.
  final Map<int, double> _results = {};

  /// The current best score among all benchmarks.
  double _currentBest = double.negativeInfinity;

  /// The current worst score among all benchmarks.
  double _currentWorst = double.infinity;

  /// The index of the benchmark with the best score.
  int _currentBestIndex = -1;

  /// The index of the benchmark with the worst score.
  int _currentWorstIndex = -1;

  /// Creates a new instance of [Suite].
  Suite({this.measureDuration = const Duration(seconds: 1)});

  /// Adds a benchmark to the suite.
  void add(OpsBenchmarkBase benchmark) {
    _benchmarks.add(benchmark);
  }

  /// Adds a report to be generated after running the benchmarks.
  void addReport(Report report) {
    _reports.add(report);
  }

  /// Runs the benchmarks in the suite and generates the reports.
  Future<List<CaseResult>> run() async {
    stdout.writeln('Running benchmarks...\n');
    stdout.writeln('Each case will be run for $measureDuration seconds.\n');
    for (final benchmark in _benchmarks.indexed) {
      stdout.writeln('${benchmark.$2.name}:\n');
      final score = await benchmark.$2.measure(measureDuration);
      _scores[benchmark.$1] = score;
      stdout.writeln(
          '\t${score.avgScore} ops/sec ± ${score.stdDevPercentage.toStringAsFixed(2)}%\n');
    }
    stdout.writeln('Finished ${_benchmarks.length} cases.');
    _currentBest = double.negativeInfinity;
    _currentWorst = double.infinity;
    for (final entry in _scores.entries) {
      final score = entry.value.avgScore;

      // Update the best and worst scores
      if (score > _currentBest) {
        _currentBest = score;
        _currentBestIndex = entry.key;
      }
      if (score < _currentWorst) {
        _currentWorst = score;
        _currentWorstIndex = entry.key;
      }

      // Store the score in the results map
      _results[entry.key] = score;
    }
    final results = <CaseResult>[];
    for (final entry in _scores.entries) {
      final benchmark = _benchmarks[entry.key];
      final score = entry.value;
      final isBest = entry.key == _currentBestIndex;
      final isWorst = entry.key == _currentWorstIndex;
      final differenceFromBest =
          ((_currentBest - score.avgScore) / _currentBest) * 100;
      results.add(CaseResult(
        group: benchmark.group,
        name: benchmark.name,
        avgScore: score.avgScore,
        stdDevPercentage: score.stdDevPercentage,
        stdDev: score.stdDev,
        best: isBest,
        differenceFromBest: differenceFromBest,
        worst: isWorst,
      ));
    }
    if (_benchmarks.length > 1) {
      _scoreboard();
    }
    for (final report in _reports) {
      await report.generate(results);
    }
    return results;
  }

  void _scoreboard() {
    final output = StringBuffer();
    for (final entry in _results.entries) {
      final benchmark = _benchmarks[entry.key];
      final score = entry.value;

      // Calculate the percentage difference from the fastest score
      final percentageDifference =
          ((_currentBest - score) / _currentBest) * 100;

      // Determine if the benchmark is the fastest or slowest
      final status = score == _currentBest
          ? 'Fastest'
          : '${score == _currentWorst ? 'Slowest | ' : ''}${percentageDifference.toStringAsFixed(2)}% slower';

      output.writeln('${benchmark.name} - $status');
    }
    // Print the results
    stdout.writeln(output);
  }
}
