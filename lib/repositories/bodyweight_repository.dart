import 'package:crimpy/models/bodyweight.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/bodyweight_service.dart';

/// The athlete's bodyweight: a dated series on the server, and the latest value
/// cached on the device.
///
/// Both copies matter and neither is redundant. The server's is what a coach
/// reads a strength number as a ratio to, and what a percent_bw prescription is
/// frozen against. The device's is what a run resolves its loads with, and a
/// run must work with no network at all.
class BodyweightRepository {
  final ApiClient _apiClient;
  final BodyweightService _service;

  BodyweightRepository(this._apiClient, {BodyweightService? service})
    : _service = service ?? BodyweightService();

  Future<void>? _inFlight;

  Future<double?> cached() => _service.load();

  /// Whether a measurement is still waiting to reach the server.
  Future<bool> hasPending() async => await _service.pending() != null;

  /// Records a measurement on the device. Deliberately does not touch the
  /// network: this is called on the way into a run, and a run must not wait on
  /// one. [flushPending] is what sends it, and is safe to leave unawaited.
  Future<void> record(double kilograms, {DateTime? measuredAt}) async {
    await _service.save(kilograms);
    await _service.markPending(kilograms, measuredAt ?? DateTime.now());
  }

  /// Sends the measurement the server has not got, under the day it was taken.
  /// Does nothing when there is none, and leaves it pending when the send
  /// fails, so the next attempt has everything it needs.
  ///
  /// One at a time. Several things ask for a flush at once, a weigh-in and the
  /// session upload that follows it, and two overlapping attempts would both
  /// read the same pending record and file it twice, leaving the coach reading
  /// the same measurement twice in one day.
  Future<void> flushPending() {
    return _inFlight ??= _flush().whenComplete(() => _inFlight = null);
  }

  Future<void> _flush() async {
    final pending = await _service.pending();
    if (pending == null) return;
    try {
      await _apiClient.createBodyweight(pending.weightKg, pending.measuredAt);
      await _service.clearPending();
    } catch (_) {
      // Still nothing we can do about it. It stays pending.
    }
  }

  /// The series as the coach sees it, newest first.
  Future<List<BodyweightEntry>> series() async {
    final rows = await _apiClient.getMyBodyweights();
    return rows.map(BodyweightEntry.fromJson).toList();
  }

  Future<void> clear() => _service.clear();
}
