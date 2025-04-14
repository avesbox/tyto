import 'dart:convert';
import 'dart:io';

import 'package:tyto/src/models/case_result.dart';

/// A class that represents a report to be generated after running benchmarks.
class Report {
  /// The name of the report file.
  final String name;

  /// The type of the report. It is one option from [ReportType].
  final ReportType type;

  /// Creates a new instance of [Report].
  const Report(this.name, this.type);

  Future<void> generate(
    List<CaseResult> scores,
  ) async {
    switch (type) {
      case ReportType.json:
        await _generateJson(scores);
        break;
      case ReportType.chart:
        await _generateChart(scores);
        break;
      case ReportType.csv:
        await _generateCsv(scores);
        break;
      case ReportType.htmlTable:
        await _generateHtmlTable(scores);
        break;
    }
  }

  Future<void> _generateJson(
    List<CaseResult> results,
  ) async {
    final jsonList = results.map((result) => result.toMap()).toList();
    final file = File('${Directory.current.absolute.path}/$name.json');
    await file.writeAsString('{"results": ${jsonEncode(jsonList)} }');
    print('Generated JSON report: ${file.path}');
  }

  Future<void> _generateChart(List<CaseResult> results) async {
    /// Uses Chart.js to generate a chart
    final file = File('${Directory.current.absolute.path}/$name.chart.html');
    final htmlString = StringBuffer();
    htmlString.writeln(
        '<html><head><script src="https://cdn.jsdelivr.net/npm/chart.js"></script></head><body>');
    htmlString
        .writeln('<canvas id="myChart" width="400" height="200"></canvas>');
    htmlString.writeln('<script>');
    htmlString.writeln(
        'const ctx = document.getElementById(\'myChart\').getContext(\'2d\');');
    htmlString.writeln('const myChart = new Chart(ctx, {');
    htmlString.writeln('type: \'bar\',');
    htmlString.writeln('data: {');
    htmlString.writeln(
        'labels: ${jsonEncode(results.map((result) => result.name).toList())},');
    htmlString.writeln('datasets: [');
    htmlString.writeln('{');
    htmlString.writeln('label: \'Scores\',');
    htmlString.writeln(
        'data: ${jsonEncode(results.map((result) => result.avgScorePerSecond).toList())},');
    htmlString.writeln('backgroundColor: \'rgba(75, 192, 192, 0.2)\',');
    htmlString.writeln('borderColor: \'rgba(75, 192, 192, 1)\',');
    htmlString.writeln('borderWidth: 1');
    htmlString.writeln('}');
    htmlString.writeln(']');
    htmlString.writeln('},');
    htmlString.writeln('options: {');
    htmlString.writeln('scales: {');
    htmlString.writeln('y: {');
    htmlString.writeln('beginAtZero: true');
    htmlString.writeln('}');
    htmlString.writeln('}');
    htmlString.writeln('}');
    htmlString.writeln('});');
    htmlString.writeln('</script>');
    htmlString.writeln('</body></html>');
    await file.writeAsString(htmlString.toString());
    print('Generated Chart report: ${file.path}');
  }

  Future<void> _generateCsv(
    List<CaseResult> results,
  ) async {
    final csvList = results.map((result) => result.toMap()).toList();
    final file = File('${Directory.current.absolute.path}/$name.csv');
    final csvString = StringBuffer();
    csvString.writeln('Name,Group,AverageScore,AverageScorePerSecond,StdDev,StdDevPercentage,Best,Worst');
    for (final result in csvList) {
      csvString.writeln(
          '${result['name']},${result['group']},${result['avgScore']},${result['avgScorePerSecond']},${result['stdDev']},${result['stdDevPercentage']},${result['best'] ? 1 : 0},${result['worst'] ? 1 : 0}');
    }
    await file.writeAsString(csvString.toString());
    print('Generated CSV report: ${file.path}');
  }

  Future<void> _generateHtmlTable(List<CaseResult> scores) async {
    final file = File('${Directory.current.absolute.path}/$name.html');
    final htmlString = StringBuffer();
    htmlString.writeln('<html><body><table>');
    htmlString.writeln(
        '<tr><th>Name</th><th>Group</th><th>Average Score</th><th>Average Score/sec</th><th>StdDev</th><th>StdDevPercentage</th><th>Best</th><th>Worst</th></tr>');
    for (final score in scores) {
      htmlString.writeln(
          '<tr><td>${score.name}</td><td>${score.group}</td><td>${score.avgScore}</td><td>${score.avgScorePerSecond}</td><td>${score.stdDev}</td><td>${score.stdDevPercentage}</td><td>${score.best ? 1 : 0}</td><td>${score.worst ? 1 : 0}</td></tr>');
    }
    htmlString.writeln('</table></body></html>');
    await file.writeAsString(htmlString.toString());
    print('Generated HTML report: ${file.path}');
  }
}

enum ReportType { json, chart, csv, htmlTable }
