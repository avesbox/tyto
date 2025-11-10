
import 'package:tyto/src/benchmarks/benchmark_base.dart';

/// Runner base class for benchmarks related to operations per seconds.
class OpsBenchmarkBase extends BenchmarkBase {

  /// Creates a new instance of [OpsBenchmarkBase].
  const OpsBenchmarkBase(
    super.name, {
    required super.onRun,
    super.group = 'default',
    super.onSetup,
    super.onTeardown,
  });

}