import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A measurement the device holds but the server has not been told about.
class PendingBodyweight {
  final double weightKg;
  final DateTime measuredAt;

  const PendingBodyweight(this.weightKg, this.measuredAt);
}

/// Device-local storage for the athlete bodyweight in kilograms, used to turn
/// the loads coaches express as a percentage of the bodyweight into kilograms.
///
/// The series itself lives on the server, where the coach can read it. This is
/// the cache a run resolves against, because a run must not need the network,
/// and the holding place for a measurement that has not reached the server.
class BodyweightService {
  static const String _bodyweightKey = 'bodyweight_kg';

  /// One key, holding the whole pending measurement.
  ///
  /// The weight and the date were two keys until a write across the await
  /// between them could be read as the new weight under the previous date, and
  /// a flush that read that pair filed a weight the athlete never had on that
  /// day. A slot that is one value cannot be half written.
  static const String _pendingKey = 'bodyweight_pending';

  Future<double?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bodyweightKey);
  }

  Future<void> save(double kilograms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bodyweightKey, kilograms);
  }

  /// Holds a measurement until the server has it, weight and all.
  ///
  /// The weight is stored here rather than read back from the cache at send
  /// time: the cache moves on as soon as the athlete weighs in again, and a
  /// measurement waiting to be sent must not be replaced by a later one it was
  /// never about.
  Future<void> markPending(double kilograms, DateTime measuredAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingKey,
      jsonEncode({
        'weight_kg': kilograms,
        'measured_at': measuredAt.toUtc().toIso8601String(),
      }),
    );
  }

  /// The measurement waiting to be sent, or null when there is none.
  Future<PendingBodyweight?> pending() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pendingKey);
    if (stored == null) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(stored);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    final kilograms = decoded['weight_kg'];
    final measuredAt = DateTime.tryParse(
      decoded['measured_at'] as String? ?? '',
    );
    if (kilograms is! num || measuredAt == null) return null;
    return PendingBodyweight(kilograms.toDouble(), measuredAt);
  }

  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }

  /// Clears the slot only if it still holds [sent].
  ///
  /// A send takes as long as the network does, and the athlete can weigh
  /// themselves again while it is in flight, to fix a typo on the way into a
  /// run. Clearing whatever is in the slot by then would throw that second
  /// measurement away without ever sending it, leaving the device and the
  /// coach's series disagreeing with nothing left to reconcile them.
  ///
  /// Answers whether the slot is now empty, so a caller can tell "sent and
  /// settled" from "sent, but something newer is waiting".
  ///
  /// The comparison is on the fields rather than on the stored string, because
  /// what matters is the measurement rather than its spelling, and [pending]
  /// now reads the pair from one key, so it cannot be a torn one.
  Future<bool> clearPendingIfUnchanged(PendingBodyweight sent) async {
    final current = await pending();
    if (current == null) return true;
    if (current.weightKg != sent.weightKg ||
        !current.measuredAt.isAtSameMomentAs(sent.measuredAt)) {
      return false;
    }
    await clearPending();
    return true;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bodyweightKey);
    await clearPending();
  }
}
