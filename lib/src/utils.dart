extension EffectiveInSeconds on Duration {
  /// Converts the duration to seconds.
  double get inEffectiveSeconds =>
      inMicroseconds / Duration.microsecondsPerSecond;
}
