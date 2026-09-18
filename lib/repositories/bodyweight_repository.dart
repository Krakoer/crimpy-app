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

  Future<double?> cached() => _service.load();

  /// Records a measurement. The cache is written first and unconditionally, so
  /// a run can resolve against it whatever the network did, then the server is
  /// told. A send that fails is remembered rather than lost: [flushPending]
  /// files it the next time there is a network.
  ///
  /// Answers whether the server has it, so a caller can say the coach cannot
  /// see it yet rather than implying it was filed.
  Future<bool> record(double kilograms, {DateTime? measuredAt}) async {
    final at = measuredAt ?? DateTime.now();
    await _service.save(kilograms);
    try {
      await _apiClient.createBodyweight(kilograms, at);
      await _service.clearPending();
      return true;
    } catch (_) {
      await _service.markPending(at);
      return false;
    }
  }

  /// Sends a measurement taken while the device was offline, under the day it
  /// was taken. Does nothing when there is none, and leaves it pending when the
  /// send fails again.
  Future<void> flushPending() async {
    final measuredAt = await _service.pendingMeasuredAt();
    if (measuredAt == null) return;
    final kilograms = await _service.load();
    if (kilograms == null) {
      await _service.clearPending();
      return;
    }
    try {
      await _apiClient.createBodyweight(kilograms, measuredAt);
      await _service.clearPending();
    } catch (_) {
      // Still no network. It stays pending.
    }
  }

  /// The series as the coach sees it, newest first.
  Future<List<BodyweightEntry>> series() async {
    final rows = await _apiClient.getMyBodyweights();
    return rows.map(BodyweightEntry.fromJson).toList();
  }

  Future<void> clear() => _service.clear();
}
