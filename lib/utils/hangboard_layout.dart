import 'dart:math';

import 'package:crimpy/models/training_item_model.dart';

/// Resolves the edge size, load and grip a hangboard item prescribes for a
/// given (set, rep) coordinate.
///
/// The item declares its own layout through [TrainingItem.granularity], and
/// every configuration array holds exactly one entry per row, so nothing here
/// is inferred from an array length.
class HangboardLayout {
  final int sets;
  final int reps;
  final String granularity;
  final List<int> _edgeSizesMm;
  final List<Load> _loads;
  final List<Load> _leftLoads;
  final List<List<String>> _handPositions;

  HangboardLayout._({
    required this.sets,
    required this.reps,
    required this.granularity,
    required List<int> edgeSizesMm,
    required List<Load> loads,
    required List<Load> leftLoads,
    required List<List<String>> handPositions,
  }) : _edgeSizesMm = edgeSizesMm,
       _loads = loads,
       _leftLoads = leftLoads,
       _handPositions = handPositions;

  factory HangboardLayout.of(TrainingItem item) => HangboardLayout._(
    sets: max(1, item.cycles ?? 1),
    reps: max(1, item.reps ?? 1),
    granularity: item.granularity ?? HangboardGranularity.uniform,
    edgeSizesMm: item.edgeSizesMm ?? const [],
    loads: item.loads ?? const [],
    leftLoads: item.leftLoads ?? const [],
    handPositions: item.handPositionsPerHand,
  );

  /// Configuration rows the item carries at its granularity.
  int get rowCount => switch (granularity) {
    HangboardGranularity.perSet => sets * reps,
    HangboardGranularity.perRep => reps,
    _ => 1,
  };

  /// Row holding the configuration of a given set and rep.
  int _row(int set, int rep) => switch (granularity) {
    HangboardGranularity.perSet => set * reps + rep,
    HangboardGranularity.perRep => rep,
    _ => 0,
  };

  int? edgeSizeMm(int set, int rep) => _at(_edgeSizesMm, _row(set, rep));

  /// Target load for one hand. The left hand falls back to [loads] when the
  /// item prescribes no separate left load.
  Load? load(int set, int rep, {required bool leftHand}) {
    final row = _row(set, rep);
    if (leftHand && _leftLoads.isNotEmpty) return _at(_leftLoads, row);
    return _at(_loads, row);
  }

  /// Grip for one hand. hand_positions holds one array per hand, the left one
  /// first; a single array applies to both hands.
  String? grip(int set, int rep, {required bool leftHand}) {
    if (_handPositions.isEmpty) return null;
    final hand = _handPositions.length > 1 ? (leftHand ? 0 : 1) : 0;
    return _at(_handPositions[hand], _row(set, rep));
  }

  T? _at<T>(List<T> values, int index) =>
      index >= 0 && index < values.length ? values[index] : null;
}
