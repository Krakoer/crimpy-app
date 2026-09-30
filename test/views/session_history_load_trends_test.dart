import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/load_trends.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/session_history_screen/session_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessions extends Sessions {
  _Sessions(this.sessions);

  final List<SessionModel> sessions;

  @override
  Future<List<SessionModel>> build() async => sessions;
}

final _today = DateTime.now();

final _test = SessionModel(
  id: 's-1',
  name: 'MVC assessment',
  isAssessment: true,
  origin: SessionOrigin.played,
  date: DateTime(_today.year, _today.month, _today.day, 12),
  durationInSeconds: 3600,
);

final _trend = TrainingLoadTrend(
  key: 'repeaters',
  title: 'Repeaters 20mm',
  grips: [
    (
      (position: GripPosition.halfCrimp, edgeSizeMm: 20),
      [
        (date: DateTime(2026, 9, 8), kilograms: 20.0),
        (date: DateTime(2026, 9, 19), kilograms: 21.4),
      ],
    ),
  ],
);

Future<void> _show(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionsProvider.overrideWith(() => _Sessions([_test])),
        trainingLoadTrendsProvider.overrideWith((ref) async => [_trend]),
      ],
      child: const MaterialApp(home: SessionHistoryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('reads the trends over the whole history, under the calendar', (
    tester,
  ) async {
    await _show(tester);

    expect(find.text('LOAD PER GRIP'), findsOneWidget);
    expect(find.text('Repeaters 20mm'), findsOneWidget);
  });

  testWidgets('leaves the trends out under the assessments filter', (
    tester,
  ) async {
    await _show(tester);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assessments Only'));
    await tester.pumpAndSettle();

    expect(find.text('LOAD PER GRIP'), findsNothing);
  });

  // The filter empties the list, and the trends are over the whole history.
  testWidgets('keeps the trends under a filter that empties the list', (
    tester,
  ) async {
    await _show(tester);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trainings Only'));
    await tester.pumpAndSettle();

    expect(find.text('LOAD PER GRIP'), findsOneWidget);
  });
}
