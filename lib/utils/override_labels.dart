import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/format.dart';

/// Every key a program week may replace on the item it targets. The set is
/// closed and mirrors itemOverride in
/// crimpy-backend/internal/handler/training_items.go: a key the backend names
/// and no client reads is dropped from the prescription the athlete plays.
/// [overrideChipLabels] has to name all of them, which is what
/// override_labels_test asserts.
const overrideKeys = {
  'cycles',
  'cycle_rest_seconds',
  'interval_seconds',
  'reps',
  'reps_is_max',
  'duration',
  'rest_seconds',
  'hb_worktime_seconds',
  'hand',
  'granularity',
  'load_is_max',
  'loads',
  'left_loads',
  'hand_positions',
  'edge_sizes_mm',
  'variable_targets',
};

/// The keys that carry no chip of their own because another key already says
/// what they mean. The max effort marker mirrors the load units and only ever
/// travels with the loads, whose chip names the effort.
const _silentOverrideKeys = {'load_is_max'};

/// A chip summarises the whole override, so it shows the first row only.
String _loads(dynamic raw) {
  final first = raw is List ? raw.firstOrNull : null;
  if (first is! Map<String, dynamic>) return '';
  return Load.fromJson(first).label();
}

String _list(dynamic raw) => raw is List ? raw.join('/') : '';

/// Grips arrive as one array per hand, so each hand reads as its own group.
String _grips(dynamic raw) {
  final byHand = parseHandPositions(raw);
  if (byHand == null) return '';
  return byHand.map((hand) => hand.join('/')).join(' | ');
}

String _hand(dynamic raw) => switch (raw) {
  HangboardHand.both => 'BOTH HANDS',
  HangboardHand.alternate => 'ALTERNATE HANDS',
  HangboardHand.split => 'SPLIT HANDS',
  HangboardHand.left => 'LEFT HAND',
  HangboardHand.right => 'RIGHT HAND',
  _ => '$raw',
};

/// A rep count or a duration the week set as a percentage of an assessment, or
/// the empty targets that say this week prescribes no percentage at all.
String _variableTargets(dynamic raw) {
  final targets = parseVariableTargets(raw);
  if (targets.isEmpty) return 'NO PERCENTAGE';
  return targets.entries
      .map((e) => '${e.key.toUpperCase()} ${e.value.percent.round()}%')
      .join(', ');
}

/// The label each override key reads as, in the words the item tiles above the
/// chips use. Keyed rather than switched so the set of keys this handles is a
/// value the tests can compare against [overrideKeys]: a key the backend adds
/// and this map forgets would otherwise reach the athlete as raw JSON, which is
/// how "REPS_IS_MAX true" nearly shipped.
final Map<String, String Function(dynamic)> _labels = {
  'loads': (v) => 'LOAD ${_loads(v)}',
  'left_loads': (v) => 'LEFT ${_loads(v)}',
  'reps': (v) => 'REPS $v',
  'reps_is_max': (v) => v == true ? 'AMRAP' : 'FIXED REPS',
  'duration': (v) => 'TIME ${formatSecondsAsLength(v as int)}',
  'cycles': (v) => 'CYCLES $v',
  'interval_seconds': (v) => 'EVERY ${formatSecondsAsLength(v as int)}',
  'cycle_rest_seconds': (v) => 'CYCLE REST ${formatSecondsAsLength(v as int)}',
  'rest_seconds': (v) => 'REST ${formatSecondsAsLength(v as int)}',
  'hb_worktime_seconds': (v) => 'WORK ${formatSecondsAsLength(v as int)}',
  'edge_sizes_mm': (v) => 'EDGE ${_list(v)}mm',
  'hand_positions': (v) => 'GRIP ${_grips(v)}',
  'hand': _hand,
  'granularity': (v) => 'LAYOUT ${'$v'.toUpperCase()}',
  'variable_targets': _variableTargets,
};

/// Every key [overrideChipLabels] can name, plus the ones it deliberately keeps
/// silent. Together these have to cover [overrideKeys].
Set<String> get labelledOverrideKeys => {
  ..._labels.keys,
  ..._silentOverrideKeys,
};

/// What one program week asks of an item, one short label per key it carries.
/// A key with no entry in [_labels] falls through to the raw key and value,
/// which is a bug rather than a format: the tests assert it cannot happen.
List<String> overrideChipLabels(Map<String, dynamic> overrides) {
  final labels = <String>[];
  overrides.forEach((key, value) {
    if (_silentOverrideKeys.contains(key)) return;
    final label = _labels[key];
    labels.add(label == null ? '${key.toUpperCase()} $value' : label(value));
  });
  return labels;
}
