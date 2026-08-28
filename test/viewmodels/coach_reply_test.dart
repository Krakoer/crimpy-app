import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/notification_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a fixed history and records the read receipts, so the notifier can
/// be exercised without a database or a server.
class _FakeRepository extends TrainingRepository {
  _FakeRepository(this.sessions);

  final List<SessionModel> sessions;
  final List<String> receipts = [];

  @override
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async => sessions;

  @override
  Future<void> markCoachReplyRead(String sessionId) async {
    receipts.add(sessionId);
  }

  @override
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) =>
      throw UnimplementedError();

  @override
  Future<Training?> getTraining(String trainingId) =>
      throw UnimplementedError();

  @override
  Future<Training> saveTraining(Training training) =>
      throw UnimplementedError();

  @override
  Future<Training> updateTraining(Training training) =>
      throw UnimplementedError();

  @override
  Future<void> toggleFav(String trainingId) => throw UnimplementedError();

  @override
  Future<void> deleteTraining(String trainingId) => throw UnimplementedError();

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) => throw UnimplementedError();

  @override
  Future<void> updateSession(SessionModel session) =>
      throw UnimplementedError();

  @override
  Future<void> deleteSession(String sessionId) => throw UnimplementedError();
}

ProviderContainer _containerWith(_FakeRepository repository) =>
    ProviderContainer.test(
      overrides: [trainingRepositoryProvider.overrideWithValue(repository)],
    );

SessionModel _session({
  required String id,
  String? coachReply,
  bool coachReplyRead = false,
}) => SessionModel(
  id: id,
  name: 'Repeaters',
  notes: 'Felt heavy',
  isAssessment: false,
  origin: SessionOrigin.logged,
  activity: SessionActivity.hangboard,
  coachReply: coachReply,
  coachReplyAt: coachReply == null ? null : DateTime(2026, 8, 28),
  coachReplyRead: coachReplyRead,
);

void main() {
  group('SessionModel.fromJson', () {
    test('reads the coach reply and its receipt', () {
      final session = SessionModel.fromJson({
        'id': 's-1',
        'name': 'Repeaters',
        'notes': 'Felt heavy',
        'date': '2026-08-27T18:30:00Z',
        'origin': 'logged',
        'duration': 1800,
        'coach_reply': 'Rest more next week',
        'coach_reply_at': '2026-08-28T09:00:00Z',
        'coach_reply_read': false,
      });

      expect(session.coachReply, 'Rest more next week');
      expect(session.coachReplyAt, DateTime.utc(2026, 8, 28, 9).toLocal());
      expect(session.hasUnreadCoachReply, isTrue);
    });

    test('leaves a session the coach never answered without one', () {
      final session = SessionModel.fromJson({
        'id': 's-1',
        'name': 'Repeaters',
        'notes': '',
        'date': '2026-08-27T18:30:00Z',
        'origin': 'logged',
        'duration': 1800,
      });

      expect(session.coachReply, isNull);
      expect(session.coachReplyAt, isNull);
      expect(session.hasUnreadCoachReply, isFalse);
    });
  });

  group('unreadCoachRepliesProvider', () {
    test('keeps only the answers still waiting to be read', () async {
      final container = _containerWith(
        _FakeRepository([
          _session(id: 's-1', coachReply: 'Rest more'),
          _session(id: 's-2'),
          _session(id: 's-3', coachReply: 'Nice', coachReplyRead: true),
        ]),
      );

      final unread = await container.read(unreadCoachRepliesProvider.future);

      expect(unread.map((s) => s.id), ['s-1']);
    });
  });

  group('Sessions.markCoachReplyRead', () {
    test('sends the receipt and drops the badge in place', () async {
      final repository = _FakeRepository([
        _session(id: 's-1', coachReply: 'Rest more'),
      ]);
      final container = _containerWith(repository);
      await container.read(sessionsProvider.future);

      await container.read(sessionsProvider.notifier).markCoachReplyRead('s-1');

      expect(repository.receipts, ['s-1']);
      final sessions = container.read(sessionsProvider).requireValue;
      expect(sessions.single.hasUnreadCoachReply, isFalse);
      expect(sessions.single.coachReply, 'Rest more');
    });

    test('leaves the rest of the history untouched', () async {
      final repository = _FakeRepository([
        _session(id: 's-1', coachReply: 'Rest more'),
        _session(id: 's-2', coachReply: 'Nice'),
      ]);
      final container = _containerWith(repository);
      await container.read(sessionsProvider.future);

      await container.read(sessionsProvider.notifier).markCoachReplyRead('s-1');

      final sessions = container.read(sessionsProvider).requireValue;
      expect(sessions[1].hasUnreadCoachReply, isTrue);
    });
  });
}
