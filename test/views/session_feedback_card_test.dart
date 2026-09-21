import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/session_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the read receipts the screen sends, and serves the history it needs
/// to send one, so the screen can be pumped without a server.
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
  Future<List<Training>> getAllTrainings() => throw UnimplementedError();

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

SessionModel _session({
  String? notes = 'Forearms were done by the third set',
  String? coachReply,
  bool coachReplyRead = false,
}) => SessionModel(
  id: 'session-1',
  name: 'Repeaters 20mm',
  notes: notes,
  isAssessment: false,
  origin: SessionOrigin.logged,
  activity: SessionActivity.hangboard,
  coachReply: coachReply,
  coachReplyAt: coachReply == null ? null : DateTime(2026, 8, 28),
  coachReplyRead: coachReplyRead,
  reps: const [],
);

Future<_FakeRepository> _pump(WidgetTester tester, SessionModel session) async {
  final repository = _FakeRepository([session]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        trainingRepositoryProvider.overrideWithValue(repository),
        sessionTrainingItemsProvider(
          session.trainingId,
        ).overrideWith((ref) async => const []),
      ],
      child: MaterialApp(home: SessionDetailScreen(session: session)),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('shows the notes on a session the coach has not answered', (
    tester,
  ) async {
    final repository = await _pump(tester, _session());

    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('HOW YOU FELT'), findsOneWidget);
    expect(find.text('YOUR COACH ANSWERED'), findsNothing);
    expect(repository.receipts, isEmpty);
  });

  testWidgets('shows an unread answer as new and sends the receipt', (
    tester,
  ) async {
    final repository = await _pump(
      tester,
      _session(coachReply: 'Noted, I added a rest day'),
    );

    expect(find.text('YOUR COACH ANSWERED'), findsOneWidget);
    expect(find.text('Noted, I added a rest day'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    expect(repository.receipts, ['session-1']);
  });

  testWidgets('leaves an answer already read unmarked', (tester) async {
    final repository = await _pump(
      tester,
      _session(coachReply: 'Noted', coachReplyRead: true),
    );

    expect(find.text('Noted'), findsOneWidget);
    expect(find.text('NEW'), findsNothing);
    expect(repository.receipts, isEmpty);
  });

  testWidgets('shows no card on a session nobody wrote about', (tester) async {
    await _pump(tester, _session(notes: ''));

    expect(find.text('Feedback'), findsNothing);
  });
}
