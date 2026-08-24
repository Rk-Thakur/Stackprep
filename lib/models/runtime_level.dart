/// A selectable experience tier for onboarding calibration.
class RuntimeLevel {
  const RuntimeLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.focus,
  });

  final String id;
  final String title;
  final String description;

  /// Short "Objective Focus" phrase shown on the onboarding summary screen.
  final String focus;
}
