import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_item_model.dart';

/// Unified training with a structured list of items.
class Training {
  final String id;
  final String title;
  final String? description;
  final String? goal;
  final String? comment;
  final bool isFavorite;
  final List<TrainingItem> items;

  /// Set when this training is a custom assessment: it is run like any other and
  /// ends on the question the definition asks, whose answer is the result.
  final AssessmentDefinition? assessment;

  const Training({
    required this.id,
    required this.title,
    this.description,
    this.goal,
    this.comment,
    this.isFavorite = false,
    this.items = const [],
    this.assessment,
  });

  bool get isAssessment => assessment != null;

  factory Training.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    String? cleaned(dynamic raw) {
      final value = raw as String?;
      return (value == null || value.trim().isEmpty) ? null : value;
    }

    return Training(
      id: json['id'] as String,
      title: json['title'] as String,
      description: cleaned(json['description']),
      goal: cleaned(json['goal']),
      comment: cleaned(json['comment']),
      isFavorite: json['is_favorite'] as bool? ?? false,
      items: rawItems
          .map((e) => TrainingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      assessment: json['assessment'] == null
          ? null
          : AssessmentDefinition.fromJson(
              json['assessment'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (goal != null) 'goal': goal,
    if (comment != null) 'comment': comment,
    'is_favorite': isFavorite,
    'items': items.map((i) => i.toJson()).toList(),
    if (assessment != null) 'assessment': assessment!.toJson(),
  };

  /// Whether any exercise in the tree can be performed with the force sensor.
  bool get canUseSensor {
    bool any(List<TrainingItem> items) =>
        items.any((item) => item.usesSensor || any(item.items));
    return any(items);
  }

  /// Whether any exercise in the tree is loaded as a percentage of the
  /// bodyweight, and so cannot be run in kilograms without one.
  bool get needsBodyweight {
    bool any(List<TrainingItem> items) =>
        items.any((item) => item.needsBodyweight || any(item.items));
    return any(items);
  }
}
