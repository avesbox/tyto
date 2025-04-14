/// A class representing the result of a benchmark case.
/// It contains information about the benchmark group, name, average score,
/// standard deviation percentage, standard deviation, and whether it is the best or worst case.
class CaseResult {
  /// The group name of the benchmark case.
  final String group;

  /// The name of the benchmark case.
  final String name;

  /// The average score of the benchmark case.
  final double avgScore;

  /// The average score per second of the benchmark case.
  final double avgScorePerSecond;

  /// The standard deviation percentage of the benchmark case.
  final double stdDevPercentage;

  /// The standard deviation of the benchmark case.
  final double stdDev;

  /// Indicates if the benchmark case is the best case.
  final bool best;

  /// Indicates if the benchmark case is the worst case.
  final bool worst;

  /// The difference from the best case in percentage.
  final double differenceFromBest;

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
  });

  /// Creates a new instance of [CaseResult] from a map.
  Map<String, dynamic> toMap() {
    return {
      'group': group,
      'name': name,
      'avgScore': avgScore,
      'avgScorePerSecond': avgScorePerSecond,
      'stdDevPercentage': stdDevPercentage,
      'stdDev': stdDev,
      'best': best,
      'differenceFromBest': differenceFromBest,
      'worst': worst,
    };
  }
}
