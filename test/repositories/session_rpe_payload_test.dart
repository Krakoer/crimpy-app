import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the bodies the session write paths would send, so what the API is
/// told about an RPE can be asserted without a server.
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

SessionModel _session({
  String? id,
  int? rpe,
  bool rpeFailed = false,
  SessionOrigin origin = SessionOrigin.logged,
}) => SessionModel(
  id: id,
  name: 'Session',
  date: DateTime.utc(2026, 8, 21),
  isAssessment: false,
  activity: SessionActivity.climbing,
  origin: origin,
  durationInSeconds: 3600,
  rpe: rpe,
  rpeFailed: rpeFailed,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('create', () {
    test('sends the value the athlete picked', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(client).saveSession(_session(rpe: 8), []);

      expect(client.created!['rpe'], 8);
      expect(client.created!.containsKey('rpe_failed'), isFalse);
    });

    test('sends a failure instead of a number, never both', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(
        client,
      ).saveSession(_session(rpeFailed: true), []);

      expect(client.created!['rpe_failed'], isTrue);
      expect(client.created!.containsKey('rpe'), isFalse);
    });

    test('says nothing about an RPE the athlete skipped', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(client).saveSession(_session(), []);

      expect(client.created!.containsKey('rpe'), isFalse);
      expect(client.created!.containsKey('rpe_failed'), isFalse);
    });
  });

  group('update', () {
    test('fills in an RPE the run was saved without', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(
        client,
      ).updateSession(_session(id: 's-1', rpe: 7));

      expect(client.updated!['rpe'], 7);
      expect(client.updated!['rpe_failed'], isFalse);
    });

    // Always sent, so an answer can be taken back: the server leaves the stored
    // one alone only when a request mentions neither field.
    test('states the answer is gone when it was cleared', () async {
      final client = _CapturingApiClient();
      await RemoteTrainingRepository(client).updateSession(_session(id: 's-1'));

      expect(client.updated!['rpe_failed'], isFalse);
      expect(client.updated!.containsKey('rpe'), isFalse);
    });

    test(
      'carries an RPE on a played session, whose timings it may not',
      () async {
        final client = _CapturingApiClient();
        await RemoteTrainingRepository(client).updateSession(
          _session(id: 's-1', rpe: 9, origin: SessionOrigin.played),
        );

        expect(client.updated!['rpe'], 9);
        expect(client.updated!.containsKey('date'), isFalse);
      },
    );
  });

  group('SessionModel', () {
    test('reads the pair back off the API shape', () {
      final session = SessionModel.fromJson({
        'id': 's-1',
        'name': 'Session',
        'notes': '',
        'date': '2026-08-21T10:00:00Z',
        'is_assessment': false,
        'activity': 1,
        'origin': 'logged',
        'duration': 3600,
        'rpe': 6,
        'rpe_failed': false,
      });

      expect(session.rpe, 6);
      expect(session.rpeFailed, isFalse);
    });

    test('reads a session from a server that knows no RPE as unrated', () {
      final session = SessionModel.fromJson({
        'id': 's-1',
        'name': 'Session',
        'notes': '',
        'date': '2026-08-21T10:00:00Z',
        'is_assessment': false,
        'activity': 1,
        'origin': 'logged',
        'duration': 3600,
      });

      expect(session.rpe, isNull);
      expect(session.rpeFailed, isFalse);
    });

    test('takes an answer back, which copyWith cannot', () {
      final rated = _session(id: 's-1', rpe: 10);

      expect(rated.copyWith(notes: 'edited').rpe, 10);
      expect(rated.withSessionRpe().rpe, isNull);
      expect(rated.withSessionRpe().rpeFailed, isFalse);
    });

    test('drops the number when the answer becomes a failure', () {
      final failed = _session(
        id: 's-1',
        rpe: 10,
      ).withSessionRpe(rpe: 10, rpeFailed: true);

      expect(failed.rpe, isNull);
      expect(failed.rpeFailed, isTrue);
    });
  });
}
