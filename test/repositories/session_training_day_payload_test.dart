import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the bodies the session write paths would send, so the training day
/// the API is told can be asserted without a server.
class _CapturingApiClient extends ApiClient {
  Map<String, dynamic>? created;
  Map<String, dynamic>? updated;

  @override
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> body) async {
    created = body;
    return {'id': 's-1'};
  }

  @override
  Future<void> updateSessionApi(String id, Map<String, dynamic> body) async {
    updated = body;
  }
}

SessionModel _session(
  DateTime date, {
  String? id,
  SessionOrigin origin = SessionOrigin.logged,
}) => SessionModel(
  id: id,
  name: 'Session',
  date: date,
  isAssessment: false,
  activity: SessionActivity.hangboard,
  origin: origin,
  durationInSeconds: 600,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('create', () {
    test('files a session begun after midnight under the day before', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(
        client,
      ).saveSession(_session(DateTime(2026, 9, 29, 0, 30)), []);

      expect(client.created!['training_day'], '2026-09-28');
    });

    test('files a session begun from 04:00 under its own day', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(
        client,
      ).saveSession(_session(DateTime(2026, 9, 29, 4)), []);

      expect(client.created!['training_day'], '2026-09-29');
    });

    test('reads a date handed over in UTC on the local clock', () async {
      final local = DateTime(2026, 9, 29, 0, 30);
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(
        client,
      ).saveSession(_session(local.toUtc()), []);

      expect(client.created!['training_day'], '2026-09-28');
    });
  });

  group('update', () {
    test('sends the day beside the date of a logged session', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(
        client,
      ).updateSession(_session(DateTime(2026, 9, 29, 1), id: 's-1'));

      expect(client.updated!['training_day'], '2026-09-28');
      expect(client.updated!.containsKey('date'), isTrue);
    });

    test('leaves the day of a played session alone with its date', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(client).updateSession(
        _session(
          DateTime(2026, 9, 29, 1),
          id: 's-1',
          origin: SessionOrigin.played,
        ),
      );

      expect(client.updated!.containsKey('training_day'), isFalse);
      expect(client.updated!.containsKey('date'), isFalse);
    });
  });
}
