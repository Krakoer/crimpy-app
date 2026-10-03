// ignore_for_file: avoid_public_notifier_properties

import 'dart:async';
import 'dart:convert';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/critical_force_result.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/utils/critical_force_analysis.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/run_drafts.dart';

/// The Critical Force notifier, capturing the test it is asked to save.
class _CriticalForceStore extends Assessments {
  AssessmentResultModel? saved;

  /// When set, the save waits on it, as a slow network would.
  Completer<void>? gate;

  /// How many times the save was asked for.
  int saves = 0;

  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => const [];

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessmentModel,
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    saves++;
    // Held for the save, as the real notifier holds itself.
    final keepAlive = ref.keepAlive();
    await gate?.future;
    keepAlive.close();
    saved = assessmentModel;
    return 'cf-session';
  }
}

/// The Max Force history the result is read against, capturing what is added.
class _MaxForceStore extends Assessments {
  final List<AssessmentModel> history;
  List<AssessmentResultModel>? added;
  String? addedTo;

  /// Whether the provider was still alive when the kept max was written: a
  /// disposed one has dropped it.
  bool? aliveWhenAdded;

  /// How many times kept maxes were added.
  int adds = 0;

  _MaxForceStore(this.history);

  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => history;

  @override
  Future<List<AssessmentResultModel>> addResultsToSession(
    List<AssessmentResultModel> results,
    String sessionId,
  ) async {
    aliveWhenAdded = ref.mounted;
    adds++;
    added = results;
    addedTo = sessionId;
    return const [];
  }
}

AssessmentModel _maxForce(double right, GripPosition grip) => AssessmentModel(
  id: 'mf-${grip.name}',
  date: DateTime(2026, 9, 1),
  definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
  rightValue: right,
  gripPosition: grip,
);

CriticalForceResults _results({required double peak}) => CriticalForceResults(
  criticalForce: 18,
  wPrime: 512.4,
  peakKg: peak,
  endForceKg: 16.8,
  pulls: [
    for (var i = 0; i < 4; i++)
      CriticalForcePull(
        index: i,
        start: i * 10,
        end: i * 10 + 7,
        meanKg: 18,
        peakKg: i == 0 ? peak : 20,
        endKg: 17,
        impulseKgS: 126,
        coverage: 1,
        heldAfterBellSeconds: i == 3 ? null : 0,
      ),
  ],
  firstCountedPull: 1,
  lastCountedPull: 4,
  averagedPullCount: 4,
);

Future<(_CriticalForceStore, _MaxForceStore)> _pump(
  WidgetTester tester, {
  required List<AssessmentModel> maxForces,
  double peak = 38,
  Completer<void>? gate,
}) async {
  // Wide enough for the result card in the test font, which is wider than
  // the app's.
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final criticalForce = _CriticalForceStore()..gate = gate;
  final maxForce = _MaxForceStore(maxForces);
  final results = _results(peak: peak);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assessmentsProvider(
          BuiltinAssessmentIds.criticalForce,
        ).overrideWith(() => criticalForce),
        assessmentsProvider(
          BuiltinAssessmentIds.maxForce,
        ).overrideWith(() => maxForce),
        ...runDraftOverrides(),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => CriticalForceResultScreen(
                results: results,
                data: const [],
                samples: const [(t: 0, kg: 0), (t: 40, kg: 0)],
                hand: HandSide.right,
                gripPosition: GripPosition.halfCrimp,
                edgeSizeMm: BuiltinAssessmentIds.maxForceEdgeSizeMm,
                saveAssessment: AssessmentResultModel(
                  assessmentId: BuiltinAssessmentIds.criticalForce,
                  rightValue: 18,
                  gripPosition: GripPosition.halfCrimp,
                  details: results.toDetails(workSeconds: 7, restSeconds: 3),
                ),
                saveSession: SessionModel(
                  name: 'Critical Force',
                  isAssessment: true,
                  origin: SessionOrigin.played,
                ),
                saveReps: const [],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (criticalForce, maxForce);
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Save new result'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('reads the Critical Force as a share of the max on the grip', (
    tester,
  ) async {
    await _pump(
      tester,
      maxForces: [
        _maxForce(40, GripPosition.halfCrimp),
        _maxForce(60, GripPosition.openHand),
      ],
    );

    expect(find.text('45 % of your max'), findsOneWidget);
    expect(find.text("W' 512 kg.s"), findsOneWidget);
  });

  testWidgets('says no share without a max on file for the grip', (
    tester,
  ) async {
    await _pump(tester, maxForces: [_maxForce(60, GripPosition.openHand)]);

    expect(find.textContaining('% of your max'), findsNothing);
    expect(find.text("W' 512 kg.s"), findsOneWidget);
  });

  testWidgets('saves the details with the result and offers nothing below '
      'the max', (tester) async {
    final (criticalForce, maxForce) = await _pump(
      tester,
      maxForces: [_maxForce(40, GripPosition.halfCrimp)],
    );

    expect(find.text('New Max Force'), findsNothing);
    await _save(tester);

    final details = criticalForce.saved!.details!;
    expect(CriticalForceResults.wPrimeOf(details), 512.4);
    expect(details['end_force_kg'], 16.8);
    expect(details['protocol'], '7:3x4');
    expect(details['pulls'], hasLength(4));
    expect(maxForce.added, isNull);
  });

  testWidgets('offers the hardest pull above the max, saved only when ticked', (
    tester,
  ) async {
    final (_, maxForce) = await _pump(
      tester,
      maxForces: [_maxForce(40, GripPosition.halfCrimp)],
      peak: 43.2,
    );

    expect(find.text('New Max Force'), findsOneWidget);
    expect(find.text('43.2 kg, up from 40.0 kg'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save new result'));
    await _save(tester);

    expect(maxForce.addedTo, 'cf-session');
    final kept = maxForce.added!.single;
    expect(kept.assessmentId, BuiltinAssessmentIds.maxForce);
    expect(kept.rightValue, 43.2);
    expect(kept.gripPosition, GripPosition.halfCrimp);
    expect(kept.origin, AssessmentOrigin.training);
  });

  testWidgets('a kept max is still written when the athlete leaves mid save', (
    tester,
  ) async {
    final gate = Completer<void>();
    final (_, maxForce) = await _pump(
      tester,
      maxForces: [_maxForce(40, GripPosition.halfCrimp)],
      peak: 43.2,
      gate: gate,
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save new result'));
    await tester.tap(find.text('Save new result'));
    await tester.pump();

    // The athlete leaves while the test is still being stored.
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator).last)
          .pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const SizedBox()),
          ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CriticalForceResultScreen), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();

    expect(maxForce.added?.single.rightValue, 43.2);
    expect(maxForce.aliveWhenAdded, isTrue);
  });

  testWidgets('a double tap on save stores the test and its kept max once', (
    tester,
  ) async {
    final gate = Completer<void>();
    final (criticalForce, maxForce) = await _pump(
      tester,
      maxForces: [_maxForce(40, GripPosition.halfCrimp)],
      peak: 43.2,
      gate: gate,
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save new result'));
    await tester.tap(find.text('Save new result'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Save new result'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));

    gate.complete();
    await tester.pumpAndSettle();

    expect(criticalForce.saves, 1);
    expect(maxForce.adds, 1);
  });

  testWidgets('a run kept on the device saves what a fresh one would', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    // Four 7 s pulls at 20 kg, the first peaking at 26 kg, read at 10 Hz.
    final samples = [
      for (var tenths = 0; tenths < 400; tenths++)
        (
          t: tenths / 10,
          kg: tenths % 100 >= 70
              ? 0.0
              : tenths == 30
              ? 26.0
              : 20.0,
        ),
    ];
    final windows = [
      for (var pull = 0; pull < 4; pull++)
        (start: pull * 10.0, end: pull * 10.0 + 7),
    ];
    final details = analyseCriticalForce(
      samples,
      windows,
    ).toDetails(workSeconds: 7, restSeconds: 3);
    final kept = CriticalForceResultDraft(
      owner: 'user-1',
      hand: HandSide.right,
      edgeSizeMm: BuiltinAssessmentIds.maxForceEdgeSizeMm,
      saveAssessment: AssessmentResultModel(
        assessmentId: BuiltinAssessmentIds.criticalForce,
        rightValue: 20,
        gripPosition: GripPosition.halfCrimp,
        details: details,
      ),
      saveSession: SessionModel(
        name: 'Critical force assessment',
        date: DateTime(2026, 9, 28, 18, 30),
        isAssessment: true,
        origin: SessionOrigin.played,
      ),
      saveReps: const [],
      data: const [],
      samples: samples,
      pullWindows: windows,
    );
    // As the next launch reads it back from the file.
    final resumed =
        FinishedRunDraft.fromJson(
              jsonDecode(jsonEncode(kept.toJson())) as Map<String, dynamic>,
            )
            as CriticalForceResultDraft;
    expect(resumed.hand, HandSide.right);
    expect(resumed.gripPosition, GripPosition.halfCrimp);
    expect(resumed.edgeSizeMm, BuiltinAssessmentIds.maxForceEdgeSizeMm);

    final criticalForce = _CriticalForceStore();
    final maxForce = _MaxForceStore([_maxForce(22, GripPosition.halfCrimp)]);
    final drafts = MemoryRunDrafts(resumed);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assessmentsProvider(
            BuiltinAssessmentIds.criticalForce,
          ).overrideWith(() => criticalForce),
          assessmentsProvider(
            BuiltinAssessmentIds.maxForce,
          ).overrideWith(() => maxForce),
          ...runDraftOverrides(drafts),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => CriticalForceResultScreen.fromDraft(resumed),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('% of your max'), findsOneWidget);
    expect(find.text('New Max Force'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save new result'));
    await _save(tester);

    expect(criticalForce.saves, 1);
    expect(criticalForce.saved!.details, details);
    expect(criticalForce.saved!.gripPosition, GripPosition.halfCrimp);
    expect(criticalForce.saved!.rightValue, 20);
    expect(maxForce.added!.single.rightValue, 26);
    expect(maxForce.added!.single.gripPosition, GripPosition.halfCrimp);
    expect(drafts.draft, isNull);
  });

  testWidgets('a run kept before its details were fills them in on save', (
    tester,
  ) async {
    final samples = [
      for (var tenths = 0; tenths < 400; tenths++)
        (t: tenths / 10, kg: tenths % 100 < 70 ? 20.0 : 0.0),
    ];
    final windows = [
      for (var pull = 0; pull < 4; pull++)
        (start: pull * 10.0, end: pull * 10.0 + 7),
    ];
    final old = CriticalForceResultDraft(
      owner: 'user-1',
      hand: HandSide.right,
      edgeSizeMm: BuiltinAssessmentIds.maxForceEdgeSizeMm,
      saveAssessment: AssessmentResultModel(
        assessmentId: BuiltinAssessmentIds.criticalForce,
        rightValue: 20,
      ),
      saveSession: SessionModel(
        name: 'Critical force assessment',
        isAssessment: true,
        origin: SessionOrigin.played,
      ),
      saveReps: const [],
      data: const [],
      samples: samples,
      pullWindows: windows,
    );

    final saved = CriticalForceResultScreen.fromDraft(old).saveAssessment;

    expect(
      saved.details,
      analyseCriticalForce(
        samples,
        windows,
      ).toDetails(workSeconds: 7, restSeconds: 3),
    );
    expect(saved.gripPosition, GripPosition.halfCrimp);
    expect(saved.rightValue, 20);
  });

  testWidgets('a skipped offer saves only the test', (tester) async {
    final (criticalForce, maxForce) = await _pump(
      tester,
      maxForces: [_maxForce(40, GripPosition.halfCrimp)],
      peak: 43.2,
    );

    await _save(tester);

    expect(criticalForce.saved, isNotNull);
    expect(maxForce.added, isNull);
  });
}
