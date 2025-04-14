import 'dart:math';

import 'package:tyto/src/ops_benchmark.dart';
import 'package:tyto/src/report.dart';
import 'package:tyto/src/suite.dart';

void main(List<String> arguments) {
  Suite suite = Suite(
    measureDuration: const Duration(days: 1),
  );
  suite.add(OpsBenchmarkBase('Example Benchmark', onRun: () async {
    Random random = Random();
    int sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += random.nextInt(100);
    }
    sum;
  }));
  suite.add(OpsBenchmarkBase('Another Benchmark', onRun: () async {
    Random random = Random();
    int product = 1;
    for (int i = 0; i < 10; i++) {
      product *= random.nextInt(10) + 1;
    }
    product;
  }));
  suite.add(OpsBenchmarkBase('Yet Another Benchmark', onRun: () async {
    Random random = Random();
    int maxV = 0;
    for (int i = 0; i < 10; i++) {
      maxV = max(maxV, random.nextInt(100));
    }
  }));
  suite.addReport(Report(
    'benchmark_results',
    ReportType.json,
  ));
  suite.addReport(Report(
    'benchmark_results',
    ReportType.chart,
  ));
  suite.addReport(Report(
    'benchmark_results',
    ReportType.csv,
  ));
  suite.addReport(Report(
    'benchmark_results',
    ReportType.htmlTable,
  ));
  suite.run();
}
