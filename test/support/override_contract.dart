import 'dart:convert';
import 'dart:io';

/// One key of contract/override-keys.json, the closed set of fields a program
/// week may replace on the item it targets. The file is the backend's, vendored
/// here and in crimpy-frontend: a key the backend names and this app does not
/// read is dropped from the prescription the athlete plays rather than merely
/// ignored, so the tests hold the merge and the chips to the whole list.
class OverrideContractKey {
  /// The key as it arrives in the override object.
  final String key;

  /// The field it replaces on the item, which is the name the key carries
  /// except for hb_worktime_seconds.
  final String itemField;

  /// A value every client can parse, so each of them can check that this key on
  /// its own reaches the item.
  final dynamic sample;

  const OverrideContractKey({
    required this.key,
    required this.itemField,
    required this.sample,
  });
}

List<OverrideContractKey> readOverrideContract() {
  final raw = File('contract/override-keys.json').readAsStringSync();
  final keys = (jsonDecode(raw) as Map<String, dynamic>)['keys'] as List;
  return keys
      .cast<Map<String, dynamic>>()
      .map(
        (entry) => OverrideContractKey(
          key: entry['key'] as String,
          itemField: entry['item_field'] as String,
          sample: entry['sample'],
        ),
      )
      .toList();
}
