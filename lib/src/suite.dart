import 'package:logging/logging.dart' as logging;
import 'package:system_info2/system_info2.dart';
import 'package:tyto/src/models/case_result.dart';
import 'package:tyto/src/ops_benchmark.dart';
import 'package:tyto/src/report.dart';
import 'package:tyto/src/utils.dart';

/// A class that represents a suite of benchmarks.
class Suite {
  final logging.Logger _logger = logging.Logger('Suite');

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
  Suite({
    this.measureDuration = const Duration(seconds: 1),
  }) {
    logging.Logger.root.onRecord.listen((record) {
      print(record.message);
    });
  }

  /// Adds a benchmark to the suite.
  void add(OpsBenchmarkBase benchmark) {
    _benchmarks.add(benchmark);
  }

  /// Adds a report to be generated after running the benchmarks.
  void addReport(Report report) {
    _reports.add(report);
  }

  /// Runs the benchmarks in the suite and generates the reports.
  Future<List<CaseResult>> run({bool removeLogs = true}) async {
    if (removeLogs) {
      logging.Logger.root.level = logging.Level.OFF;
      logging.Logger.root.clearListeners();
    }
    if (measureDuration.isNegative || measureDuration.inEffectiveSeconds == 0) {
      throw ArgumentError('Measure duration must be greater than 0 seconds.');
    }
    _logger.info('Running benchmarks...\n');
    _logger.info(
        'Each case will be run for ${measureDuration.inEffectiveSeconds} seconds.\n');
    for (final benchmark in _benchmarks.indexed) {
      _logger.info('${benchmark.$2.name}:\n');
      BenchmarkResult score;
      try {
        score = await benchmark.$2.measure(measureDuration);
      } catch (e) {
        score = BenchmarkResult.zero(benchmark.$2.name, benchmark.$2.group);
        _logger.info('\tError: ${e.toString()}\n\tSkipping this benchmark.\n');
      }
      _scores[benchmark.$1] = score;
      if (score.avgScorePerSecond == 0) {
        continue;
      }
      _logger.info(
          '\t${score.avgScorePerSecond} ops/sec ± ${score.stdDevPercentage.toStringAsFixed(2)}%\n');
      _logger.info(
          '\tAvg: ${score.avgTime.toStringAsFixed(2)} μs, Min: ${score.minTime.toStringAsFixed(2)} μs, Max: ${score.maxTime.toStringAsFixed(2)} μs\n');
      _logger.info(
          '\tp75: ${score.p75Time.toStringAsFixed(2)} μs, p95: ${score.p95Time.toStringAsFixed(2)} μs, p99: ${score.p99Time.toStringAsFixed(2)} μs, p999: ${score.p999Time.toStringAsFixed(2)} μs\n');
    }
    _logger.info('Finished ${_benchmarks.length} cases.');
    _currentBest = double.negativeInfinity;
    _currentWorst = double.infinity;
    for (final entry in _scores.entries) {
      final score = entry.value.avgScorePerSecond;

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
          ((_currentBest - score.avgScorePerSecond) / _currentBest) * 100;
      results.add(CaseResult(
        group: benchmark.group,
        name: benchmark.name,
        avgScore: score.avgScore,
        avgScorePerSecond: score.avgScorePerSecond,
        stdDevPercentage: score.stdDevPercentage,
        stdDev: score.stdDev,
        best: isBest,
        differenceFromBest: differenceFromBest.isNaN ? 0 : differenceFromBest,
        worst: isWorst,
        avgTime: score.avgTime,
        minTime: score.minTime,
        maxTime: score.maxTime,
        p75Time: score.p75Time,
        p95Time: score.p95Time,
        p99Time: score.p99Time,
        p999Time: score.p999Time,
        cpu: SysInfo.cores.first.name,
        system: '${SysInfo.kernelName} ${SysInfo.kernelVersion}',
        memory:
            '${(SysInfo.getTotalPhysicalMemory() / (1024 * 1024 * 1024)).ceil()} GB',
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
    _logger.info(output);
  }
}
