import 'dart:math';

import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/hangboard_layout.dart';

/// Editable hangboard configuration behind the repeater editor.
///
/// It holds one entry per configuration row in every array, the same shape the
/// API stores, and resizes them in place when the granularity, the hand mode or
/// the set and rep counts change. Values are carried over by their (set, rep)
/// coordinates so widening or narrowing the grid keeps what the user typed.
class HangboardConfig {
  int sets;
  int reps;
  String hand;
  String granularity;

  List<int> edgeSizesMm;
  List<Load> loads;
  List<Load> leftLoads;
  List<String> grips;
  List<String> leftGrips;

  HangboardConfig({
    required this.sets,
    required this.reps,
    required this.hand,
    required this.granularity,
    required this.edgeSizesMm,
    required this.loads,
    required this.leftLoads,
    required this.grips,
    required this.leftGrips,
  });

  static const defaultEdgeMm = 20;
  static const defaultGrip = 'halfCrimp';
  static const defaultLoad = Load(value: 0, unit: 'kg');

  factory HangboardConfig.initial() => HangboardConfig(
    sets: 3,
    reps: 6,
    hand: HangboardHand.alternate,
    granularity: HangboardGranularity.uniform,
    edgeSizesMm: [defaultEdgeMm],
    loads: [defaultLoad],
    leftLoads: [defaultLoad],
    grips: [defaultGrip],
    leftGrips: [defaultGrip],
  );

  /// Reads an existing item back into an editable configuration, resolving
  /// every row through the layout the item declares.
  factory HangboardConfig.fromItem(TrainingItem item) {
    final layout = HangboardLayout.of(item);
    final config = HangboardConfig(
      sets: max(1, item.cycles ?? 1),
      reps: max(1, item.reps ?? 1),
      hand: item.hand ?? HangboardHand.both,
      granularity: item.granularity ?? HangboardGranularity.uniform,
      edgeSizesMm: [],
      loads: [],
      leftLoads: [],
      grips: [],
      leftGrips: [],
    );
    for (int row = 0; row < config.rowCount; row++) {
      final (set, rep) = config.coordinateOf(row);
      config.edgeSizesMm.add(layout.edgeSizeMm(set, rep) ?? defaultEdgeMm);
      config.loads.add(layout.load(set, rep, leftHand: false) ?? defaultLoad);
      config.leftLoads.add(
        layout.load(set, rep, leftHand: true) ?? defaultLoad,
      );
      config.grips.add(layout.grip(set, rep, leftHand: false) ?? defaultGrip);
      config.leftGrips.add(
        layout.grip(set, rep, leftHand: true) ?? defaultGrip,
      );
    }
    return config;
  }

  bool get worksHandsSeparately => HangboardHand.worksHandsSeparately(hand);

  HangboardGrid get grid =>
      HangboardGrid(granularity: granularity, sets: sets, reps: reps);

  int get rowCount => grid.rowCount;

  /// The (set, rep) a configuration row stands for.
  (int, int) coordinateOf(int row) => grid.coordinateOf(row);

  /// Row holding the configuration of a given set and rep.
  int rowOf(int set, int rep) => grid.rowOf(set, rep);

  /// Human label for a row, e.g. "Set 2 - Rep 3".
  String labelOf(int row) {
    final (set, rep) = coordinateOf(row);
    return switch (granularity) {
      HangboardGranularity.perSet => 'Set ${set + 1} - Rep ${rep + 1}',
      HangboardGranularity.perRep => 'Rep ${rep + 1}',
      _ => 'Every rep',
    };
  }

  /// Applies new counts, granularity or hand mode, carrying every value over to
  /// the row it belongs to under the new layout.
  void reshape({int? sets, int? reps, String? granularity, String? hand}) {
    final previous = _Snapshot(this);
    this.sets = max(1, sets ?? this.sets);
    this.reps = max(1, reps ?? this.reps);
    this.granularity = granularity ?? this.granularity;
    this.hand = hand ?? this.hand;

    edgeSizesMm = _resample(previous.edgeSizesMm, defaultEdgeMm, previous);
    loads = _resample(previous.loads, defaultLoad, previous);
    leftLoads = _resample(previous.leftLoads, defaultLoad, previous);
    grips = _resample(previous.grips, defaultGrip, previous);
    leftGrips = _resample(previous.leftGrips, defaultGrip, previous);
  }

  List<T> _resample<T>(List<T> values, T fallback, _Snapshot previous) =>
      List<T>.generate(rowCount, (row) {
        final (set, rep) = coordinateOf(row);
        final source = previous.rowOf(
          min(set, previous.sets - 1),
          min(rep, previous.reps - 1),
        );
        return source >= 0 && source < values.length
            ? values[source]
            : fallback;
      });

  /// Copies a row onto every row below it, staying inside the set it belongs to
  /// when the configuration is per set.
  void fillDown(int row) {
    final limit = granularity == HangboardGranularity.perSet
        ? (row ~/ reps + 1) * reps
        : rowCount;
    for (int target = row + 1; target < limit; target++) {
      edgeSizesMm[target] = edgeSizesMm[row];
      loads[target] = loads[row];
      leftLoads[target] = leftLoads[row];
      grips[target] = grips[row];
      leftGrips[target] = leftGrips[row];
    }
  }

  /// Builds the training item this configuration describes.
  TrainingItem toItem({
    required String id,
    required int position,
    required int worktimeSeconds,
    required int restSeconds,
    required int cycleRestSeconds,
  }) => TrainingItem(
    id: id,
    type: TrainingItemType.repeater,
    position: position,
    cycles: sets,
    reps: reps,
    worktimeSeconds: worktimeSeconds,
    restSeconds: restSeconds,
    cycleRestSeconds: cycleRestSeconds,
    hand: hand,
    granularity: granularity,
    loads: List.of(loads),
    leftLoads: worksHandsSeparately ? List.of(leftLoads) : null,
    edgeSizesMm: List.of(edgeSizesMm),
    handPositions: worksHandsSeparately
        ? [List.of(leftGrips), List.of(grips)]
        : [List.of(grips)],
    loadIsMax: _everyLoadIsMax,
  );

  bool get _everyLoadIsMax {
    final all = [...loads, if (worksHandsSeparately) ...leftLoads];
    return all.isNotEmpty && all.every((l) => l.isMax);
  }
}

/// The layout an edit started from, so values can be read back by coordinate.
class _Snapshot {
  final int sets;
  final int reps;
  final String granularity;
  final List<int> edgeSizesMm;
  final List<Load> loads;
  final List<Load> leftLoads;
  final List<String> grips;
  final List<String> leftGrips;

  _Snapshot(HangboardConfig config)
    : sets = config.sets,
      reps = config.reps,
      granularity = config.granularity,
      edgeSizesMm = List.of(config.edgeSizesMm),
      loads = List.of(config.loads),
      leftLoads = List.of(config.leftLoads),
      grips = List.of(config.grips),
      leftGrips = List.of(config.leftGrips);

  int rowOf(int set, int rep) => HangboardGrid(
    granularity: granularity,
    sets: sets,
    reps: reps,
  ).rowOf(set, rep);
}
