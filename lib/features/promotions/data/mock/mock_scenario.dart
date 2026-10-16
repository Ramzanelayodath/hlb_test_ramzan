enum MockScenario {
  success,
  empty,
  error;

  /// Parses a `--dart-define` value; anything unknown falls back to [success].
  static MockScenario fromName(String name) => values.firstWhere(
    (scenario) => scenario.name == name.toLowerCase(),
    orElse: () => success,
  );
}
