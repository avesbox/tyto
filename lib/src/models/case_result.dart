/// A class representing the result of a benchmark case.
/// It contains information about the benchmark group, name, average score,
/// standard deviation percentage, standard deviation, and whether it is the best or worst case.
class CaseResult {
  /// The group name of the benchmark case.
  final String group;

  /// The name of the benchmark case.
  final String name;

  /// A warning message associated with the benchmark case, if any.
  final String? warningMessage;

  /// The average score of the benchmark case.
  final double avgScore;

  /// The average score per second of the benchmark case.
  final double avgScorePerSecond;

  /// The standard deviation percentage of the benchmark case.
  final double stdDevPercentage;

  /// The standard deviation of the benchmark case.
  final double stdDev;

  /// The average time per iteration of the benchmark case.
  final double avgTime;

  /// The minimum time per iteration of the benchmark case.
  final double minTime;

  /// The maximum time per iteration of the benchmark case.
  final double maxTime;

  /// p75 time per iteration of the benchmark case.
  final double p75Time;

  /// p95 time per iteration of the benchmark case.
  final double p95Time;

  /// p99 time per iteration of the benchmark case.
  final double p99Time;

  /// p999 time per iteration of the benchmark case.
  final double p999Time;

  /// Indicates if the benchmark case is the best case.
  final bool best;

  /// Indicates if the benchmark case is the worst case.
  final bool worst;

  /// The difference from the best case in percentage.
  final double differenceFromBest;

  /// The CPU on which the tests have been conducted.
  final String cpu;

  /// The system on which the tests have been conducted.
  final String system;

  /// The memory on which the tests have been conducted.
  final String memory;

  /// Creates a new instance of [CaseResult].
  const CaseResult({
    required this.group,
    required this.name,
    required this.avgScore,
    required this.avgScorePerSecond,
    required this.stdDevPercentage,
    required this.stdDev,
    required this.best,
    required this.differenceFromBest,
    required this.worst,
    required this.avgTime,
    required this.minTime,
    required this.maxTime,
    required this.p75Time,
    required this.p95Time,
    required this.p99Time,
    required this.p999Time,
    required this.cpu,
    required this.system,
    required this.memory,
    this.warningMessage,
  });

  /// Creates a new instance of [CaseResult] from a map.
  Map<String, dynamic> toMap() {
    return {
      'group': group,
      'name': name,
      'warningMessage': warningMessage,
      'avgScore': avgScore,
      'avgScorePerSecond': avgScorePerSecond,
      'stdDevPercentage': stdDevPercentage,
      'stdDev': stdDev,
      'best': best,
      'differenceFromBest': differenceFromBest,
      'worst': worst,
      'avgTime': avgTime,
      'minTime': minTime,
      'maxTime': maxTime,
      'p75Time': p75Time,
      'p95Time': p95Time,
      'p99Time': p99Time,
      'p999Time': p999Time,
      'cpu': cpu,
      'system': system,
      'memory': memory,
    };
  }
}
