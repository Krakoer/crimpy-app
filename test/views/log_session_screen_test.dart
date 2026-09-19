import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
import 'package:crimpy/views/screens/home_screen/widgets/log_session_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures what the screen asks to be saved, so the payload can be asserted
/// without a database.
class _CapturingSessions extends Sessions {
  static SessionModel? saved;

  @override
  Future<List<SessionModel>> build() async => const [];

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    saved = session;
    return 's-1';
  }
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Save Session'));
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  // Tall enough for the whole form, so the save button is reachable without
  // scrolling a field the test has just typed into back out of view.
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionsProvider.overrideWith(_CapturingSessions.new)],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => _CapturingSessions.saved = null);

  testWidgets('a hangboard session can be logged by hand', (tester) async {
    // A hangboard session done without the sensor used to have no button of
    // its own, so it could only be logged as something it was not.
    await _pump(tester, const Scaffold(body: LogSessionButtons()));

    expect(find.text('Hangboard'), findsOneWidget);

    await tester.tap(find.text('Hangboard'));
    await tester.pumpAndSettle();

    expect(find.text('Log Hangboard'), findsOneWidget);
  });

  testWidgets('every activity keeps a button', (tester) async {
    await _pump(tester, const Scaffold(body: LogSessionButtons()));

    for (final activity in SessionActivity.values) {
      expect(find.text(activity.displayName), findsOneWidget);
    }
  });

  testWidgets('the name defaults to what the session used to be called', (
    tester,
  ) async {
    await _pump(
      tester,
      const LogSessionScreen(activity: SessionActivity.climbing),
    );

    await _save(tester);

    expect(_CapturingSessions.saved!.name, 'Climbing');
  });

  // A session logged by hand carries an RPE exactly as a played one does, which
  // is the case the issue names for this screen.
  testWidgets('a logged session carries the RPE anchor that was picked', (
    tester,
  ) async {
    await _pump(
      tester,
      const LogSessionScreen(activity: SessionActivity.climbing),
    );

    await tester.tap(find.text('Easy but productive'));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(_CapturingSessions.saved!.rpe, 6);
    expect(_CapturingSessions.saved!.rpeFailed, isFalse);
  });

  testWidgets('a logged session leaves a skipped prompt unrated', (
    tester,
  ) async {
    await _pump(
      tester,
      const LogSessionScreen(activity: SessionActivity.climbing),
    );

    await _save(tester);

    expect(_CapturingSessions.saved!.rpe, isNull);
    expect(_CapturingSessions.saved!.rpeFailed, isFalse);
  });

  testWidgets('a scheduled training keeps its title as the default name', (
    tester,
  ) async {
    await _pump(
      tester,
      const LogSessionScreen(
        activity: SessionActivity.climbing,
        name: 'Week 3 bouldering',
      ),
    );

    await _save(tester);

    expect(_CapturingSessions.saved!.name, 'Week 3 bouldering');
  });

  testWidgets('the athlete can name the session themselves', (tester) async {
    await _pump(
      tester,
      const LogSessionScreen(activity: SessionActivity.climbing),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Session name'),
      'Fontainebleau circuit',
    );
    await _save(tester);

    expect(_CapturingSessions.saved!.name, 'Fontainebleau circuit');
  });

  testWidgets('an empty name is refused rather than saved blank', (
    tester,
  ) async {
    await _pump(
      tester,
      const LogSessionScreen(activity: SessionActivity.climbing),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Session name'),
      '   ',
    );
    await _save(tester);

    expect(_CapturingSessions.saved, isNull);
    expect(find.text('Please enter a session name'), findsOneWidget);
  });
}
