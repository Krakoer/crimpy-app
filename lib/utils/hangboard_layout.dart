import 'dart:math';

import 'package:crimpy/models/training_item_model.dart';

/// How finely a hangboard item varies its edge, load and grip.
/// [uniform]: one value for the whole item.
/// [perRep]: one value per rep, replayed in every set.
/// [perSet]: one value per (set, rep) pair.
enum _HangboardGranularity { uniform, perRep, perSet }

/// Resolves the edge size, load and grip a hangboard item prescribes for a
/// given (set, rep) coordinate.
///
/// The wire format carries no granularity marker: the number of entries tells
/// the layouts apart, the same way the coach portal reads them. One entry is
/// uniform, one entry per rep is per-rep, and sets x reps entries are per set
/// and rep, indexed set * reps + rep. Granularity is resolved per array so an
/// item written by the app, which sends per-rep loads and no edge sizes at all,
/// keeps varying its load per rep.
class HangboardLayout {
  final int sets;
  final int reps;
  final bool split;
  final List<int> _edgeSizesMm;
  final List<Load> _loads;
  final List<Load> _leftLoads;
  final List<List<String>> _handPositions;

  HangboardLayout._({
    required this.sets,
    required this.reps,
    required this.split,
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
    split: item.hand == 'split',
    edgeSizesMm: item.edgeSizesMm ?? const [],
    loads: item.loads ?? const [],
    leftLoads: item.leftLoads ?? const [],
    handPositions: item.handPositionsPerHand,
  );

  /// Granularity of the item as a whole, read from the edge sizes because that
  /// is the array the coach portal always writes.
  _HangboardGranularity get _granularity => _granularityOf(_edgeSizesMm.length);

  /// Configuration rows the item carries at its granularity.
  int get _rowCount => switch (_granularity) {
    _HangboardGranularity.uniform => 1,
    _HangboardGranularity.perRep => reps,
    _HangboardGranularity.perSet => sets * reps,
  };

  int? edgeSizeMm(int set, int rep) =>
      _at(_edgeSizesMm, _rowIn(_edgeSizesMm.length, set, rep));

  /// Target load for one hand. Split items come in two conventions: the app
  /// writes the left hand into left_loads, the coach portal interleaves both
  /// hands into loads with the left at 2 * row and the right at 2 * row + 1.
  Load? load(int set, int rep, {required bool leftHand}) {
    if (leftHand && _leftLoads.isNotEmpty) {
      return _at(_leftLoads, _rowIn(_leftLoads.length, set, rep));
    }
    if (_hasInterleavedLoads) {
      final row = _rowIn(_loads.length ~/ 2, set, rep);
      return _at(_loads, 2 * row + (leftHand ? 0 : 1));
    }
    return _at(_loads, _rowIn(_loads.length, set, rep));
  }

  /// Grip for one hand. hand_positions holds one array per hand, the left one
  /// first; a single array applies to both hands.
  String? grip(int set, int rep, {required bool leftHand}) {
    if (_handPositions.isEmpty) return null;
    final hand = _handPositions.length > 1 ? (leftHand ? 0 : 1) : 0;
    final slots = _handPositions[hand];
    return _at(slots, _rowIn(slots.length, set, rep));
  }

  /// Only the portal interleaves, and it always writes edge sizes, so an item
  /// without them is never read as interleaved. The edge sizes are what tell
  /// the two conventions apart when the counts alone are ambiguous: a two-rep
  /// item written by this app also carries two loads, which would otherwise
  /// read as one interleaved row.
  bool get _hasInterleavedLoads =>
      split &&
      _leftLoads.isEmpty &&
      _edgeSizesMm.isNotEmpty &&
      _loads.length == 2 * _rowCount;

  _HangboardGranularity _granularityOf(int entries) {
    if (entries <= 1) return _HangboardGranularity.uniform;
    if (sets > 1 && entries == sets * reps) return _HangboardGranularity.perSet;
    return _HangboardGranularity.perRep;
  }

  int _rowIn(int entries, int set, int rep) => switch (_granularityOf(
    entries,
  )) {
    _HangboardGranularity.uniform => 0,
    _HangboardGranularity.perSet => set * reps + rep,
    // Shorter arrays than the item has reps stay in range rather than throwing.
    _HangboardGranularity.perRep => rep % entries,
  };

  T? _at<T>(List<T> values, int index) =>
      index >= 0 && index < values.length ? values[index] : null;
}
