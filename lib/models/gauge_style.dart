/// Design the live force gauge is drawn with during a sensor step.
enum GaugeStyle {
  circle(
    'Circle',
    'A disc filling inside the rep timer ring, at the centre of the screen',
  ),
  fullScreen(
    'Full screen',
    'A level rising over the whole screen, with the target line, the peak and the average of the rep',
  );

  const GaugeStyle(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Design used until the athlete picks one, and whenever a stored name no
  /// longer matches a design.
  static const GaugeStyle fallback = fullScreen;

  static GaugeStyle fromName(String? name) =>
      values.firstWhere((style) => style.name == name, orElse: () => fallback);
}
