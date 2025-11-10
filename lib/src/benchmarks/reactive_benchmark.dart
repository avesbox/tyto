import 'package:tyto/src/benchmarks/benchmark_base.dart';

abstract interface class ISignal<T> {
  T read();
}

abstract interface class Signal<T> implements ISignal<T> {
  void write(T value);
}

abstract interface class Computed<T> implements ISignal<T> {}

abstract class ReactiveFramework {
  const ReactiveFramework();

  Signal<T> signal<T>(T value);
  Computed<T> computed<T>(T Function() fn);
  void effect(void Function() fn);
  void withBatch<T>(T Function() fn);
  T withBuild<T>(T Function() fn);
}

final class _Signal<T> implements Signal<T> {
  const _Signal(this.getter, this.setter);

  final T Function() getter;
  final void Function(T _) setter;

  @override
  T read() => getter();

  @override
  void write(T value) => setter(value);
}

Signal<T> createSignal<T>(T Function() getter, void Function(T) setter) {
  return _Signal(getter, setter);
}

final class _Computed<T> implements Computed<T> {
  const _Computed(this.getter);

  final T Function() getter;

  @override
  T read() => getter();
}

Computed<T> createComputed<T>(T Function() fn) {
  return _Computed(fn);
}

class ReactiveBenchmark extends BenchmarkBase {
  final ReactiveFramework framework;

  ReactiveBenchmark(
    super.name, {
    required super.onRun,
    required this.framework,
    super.group = 'default',
    super.onSetup,
    super.onTeardown,
  });
  
}