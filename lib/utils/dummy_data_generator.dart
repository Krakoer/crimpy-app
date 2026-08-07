import 'dart:math';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/logger.dart';
import 'package:drift/drift.dart' as drift;

/// Utility class to generate dummy data for testing and screenshots.
///
/// This generator creates realistic sample data including:
/// - Custom trainings (Beginner Repeaters, Advanced Hangs, Max Hangs, Endurance Workout)
/// - Climbing sessions with notes over the past 2 months
/// - Stretching sessions
/// - Crimpy training sessions with performance data
/// - Assessment sessions (MVC and Critical Force) showing progression over time
///
/// Usage:
/// 1. In debug mode, navigate to Settings screen
/// 2. Scroll to the "Debug Tools" section (only visible in debug mode)
/// 3. Tap "Generate Dummy Data" to populate the database
/// 4. Tap "Clear All Data" to remove all sessions and custom trainings
///
/// Note: This class is intended for debug mode only. The assert statements
/// ensure that methods are only called in debug mode.
class DummyDataGenerator {
  final TrainingRepository _trainingRepository;
  final Random _random = Random();

  DummyDataGenerator(this._trainingRepository);

  /// Generate a complete set of dummy data including sessions, trainings, and assessments
  Future<void> generateAllDummyData() async {
    assert(() {
      AppLoggerHelper.info('Generating dummy data for debug mode');
      return true;
    }());

    try {
      // Generate custom trainings
      await _generateCustomTrainings();

      // Generate climbing sessions
      await _generateClimbingSessions();

      // Generate stretching sessions
      await _generateStretchingSessions();

      // Generate Crimpy training sessions
      await _generateCrimpyTrainingSessions();

      // Generate assessment sessions
      await _generateAssessmentSessions();

      AppLoggerHelper.info('Successfully generated all dummy data');
    } catch (e) {
      AppLoggerHelper.error('Error generating dummy data: $e');
      rethrow;
    }
  }

  /// Clear all dummy data (useful for resetting)
  Future<void> clearAllData() async {
    assert(() {
      AppLoggerHelper.info('Clearing all data');
      return true;
    }());

    try {
      // Delete all sessions (cascade will handle related data)
      await gDatabase.delete(gDatabase.sessions).go();

      await gDatabase.delete(gDatabase.trainings).go();

      AppLoggerHelper.info('Successfully cleared all data');
    } catch (e) {
      AppLoggerHelper.error('Error clearing data: $e');
      rethrow;
    }
  }

  TrainingItem _repeaterItem({
    required int sets,
    required int reps,
    required int worktime,
    required int resttime,
    required int setRest,
    required bool splitHand,
    required double weightRight,
    double? weightLeft,
    GripPosition gripPosition = GripPosition.halfCrimp,
  }) {
    final loadsPerRep = List.filled(reps, Load(value: weightRight, unit: 'kg'));
    final leftLoads = splitHand && weightLeft != null
        ? List.filled(reps, Load(value: weightLeft, unit: 'kg'))
        : null;
    final positions = List.filled(reps, gripPosition.name);
    return TrainingItem(
      id: '',
      type: TrainingItemType.repeater,
      position: 0,
      cycles: sets,
      reps: reps,
      worktimeSeconds: worktime,
      restSeconds: resttime,
      cycleRestSeconds: setRest,
      hand: splitHand ? HangboardHand.split : HangboardHand.alternate,
      granularity: HangboardGranularity.perRep,
      loads: loadsPerRep,
      leftLoads: leftLoads,
      handPositions: [positions],
    );
  }

  /// Generate custom training definitions
  Future<void> _generateCustomTrainings() async {
    final trainingId = await _trainingRepository.saveTraining(
      Training(
        id: '',
        title: 'Beginner Repeaters',
        isFavorite: true,
        items: [
          _repeaterItem(
            sets: 3,
            reps: 5,
            worktime: 7,
            resttime: 3,
            setRest: 120,
            splitHand: false,
            weightRight: 15.0,
          ),
        ],
      ),
    );
    AppLoggerHelper.info('Created Beginner Repeaters: $trainingId');

    await _trainingRepository.saveTraining(
      Training(
        id: '',
        title: 'Advanced Hangs',
        isFavorite: true,
        items: [
          _repeaterItem(
            sets: 5,
            reps: 20,
            worktime: 10,
            resttime: 5,
            setRest: 180,
            splitHand: false,
            weightRight: 25.0,
          ),
        ],
      ),
    );

    await _trainingRepository.saveTraining(
      Training(
        id: '',
        title: 'Max Hangs',
        items: [
          _repeaterItem(
            sets: 4,
            reps: 3,
            worktime: 10,
            resttime: 10,
            setRest: 240,
            splitHand: false,
            weightRight: 35.0,
          ),
        ],
      ),
    );

    await _trainingRepository.saveTraining(
      Training(
        id: '',
        title: 'Resi',
        items: [
          _repeaterItem(
            sets: 3,
            reps: 12,
            worktime: 7,
            resttime: 3,
            setRest: 480,
            splitHand: true,
            weightRight: 31.0,
            weightLeft: 27.0,
          ),
        ],
      ),
    );

    await _trainingRepository.saveTraining(
      Training(
        id: '',
        title: 'Endurance Workout',
        items: [
          TrainingItem(
            id: '',
            type: TrainingItemType.hangboardRep,
            position: 0,
            worktimeSeconds: 30,
            restSeconds: 10,
            hand: HangboardHand.right,
            granularity: HangboardGranularity.uniform,
            loads: [const Load(value: 20.0, unit: 'kg')],
            handPositions: const [
              ['halfCrimp'],
            ],
          ),
          TrainingItem(
            id: '',
            type: TrainingItemType.hangboardRep,
            position: 1,
            worktimeSeconds: 30,
            restSeconds: 120,
            hand: HangboardHand.left,
            granularity: HangboardGranularity.uniform,
            loads: [const Load(value: 20.0, unit: 'kg')],
            handPositions: const [
              ['halfCrimp'],
            ],
          ),
        ],
      ),
    );

    AppLoggerHelper.info('Generated 5 custom trainings');
  }

  /// Generate climbing sessions with realistic data
  Future<void> _generateClimbingSessions() async {
    final now = DateTime.now();
    final sessions = <SessionModel>[];

    // Generate 10 climbing sessions over the past 2 months
    for (int i = 0; i < 10; i++) {
      final daysAgo = _random.nextInt(60);
      final sessionDate = now.subtract(
        Duration(
          days: daysAgo,
          hours: _random.nextInt(8) + 10, // Between 10am and 6pm
          minutes: _random.nextInt(60),
        ),
      );

      final duration = 60 + _random.nextInt(120); // 60-180 minutes

      sessions.add(
        SessionModel(
          name: 'Climbing Session',
          isAssessment: false,
          sessionType: SessionType.climbing,
          durationInSeconds: duration * 60,
          date: sessionDate,
          notes: _getRandomClimbingNote(),
        ),
      );
    }

    await _saveSessions(sessions);
    AppLoggerHelper.info('Generated ${sessions.length} climbing sessions');
  }

  /// Generate stretching sessions
  Future<void> _generateStretchingSessions() async {
    final now = DateTime.now();
    final sessions = <SessionModel>[];

    // Generate 5 stretching sessions
    for (int i = 0; i < 5; i++) {
      final daysAgo = _random.nextInt(30);
      final sessionDate = now.subtract(
        Duration(
          days: daysAgo,
          hours: _random.nextInt(4) + 18, // Between 6pm and 10pm
          minutes: _random.nextInt(60),
        ),
      );

      final duration = 15 + _random.nextInt(30); // 15-45 minutes

      sessions.add(
        SessionModel(
          name: 'Stretching Session',
          isAssessment: false,
          sessionType: SessionType.stretching,
          durationInSeconds: duration * 60,
          date: sessionDate,
          notes: _getRandomStretchingNote(),
        ),
      );
    }

    await _saveSessions(sessions);
    AppLoggerHelper.info('Generated ${sessions.length} stretching sessions');
  }

  /// Generate Crimpy training sessions with performance data
  Future<void> _generateCrimpyTrainingSessions() async {
    final now = DateTime.now();
    final sessions = <Map<String, dynamic>>[];

    // Define repeater configurations for each training type
    // These must match the RepeaterModel configurations from _generateCustomTrainings
    final repeaterConfigs = {
      'Beginner Repeaters': RepeaterConfig(
        sets: 3,
        repsPerSet: 5,
        workTime: 7,
        restTime: 3,
        setRest: 120,
        splitHand: false,
      ),
      'Advanced Hangs': RepeaterConfig(
        sets: 5,
        repsPerSet: 20,
        workTime: 10,
        restTime: 5,
        setRest: 180,
        splitHand: false,
      ),
      'Max Hangs': RepeaterConfig(
        sets: 4,
        repsPerSet: 3,
        workTime: 10,
        restTime: 10,
        setRest: 240,
        splitHand: false,
      ),
      'Resi': RepeaterConfig(
        sets: 3,
        repsPerSet: 12,
        workTime: 7,
        restTime: 3,
        setRest: 480,
        splitHand: true,
      ),
      'Endurance Workout': null, // Not a repeater - uses custom reps
    };

    // Generate 15 Crimpy training sessions with various performance levels
    for (int i = 0; i < 15; i++) {
      final daysAgo = _random.nextInt(60);
      final sessionDate = now.subtract(
        Duration(
          days: daysAgo,
          hours: _random.nextInt(8) + 10,
          minutes: _random.nextInt(60),
        ),
      );

      // Randomly choose training type
      final trainingNames = [
        'Beginner Repeaters',
        'Advanced Hangs',
        'Max Hangs',
        'Resi',
        'Endurance Workout',
      ];
      final trainingName = trainingNames[_random.nextInt(trainingNames.length)];

      // Generate realistic reps with varying success rates
      final reps = _generateRealisticReps(trainingName, daysAgo);

      sessions.add({
        'session': SessionModel(
          name: trainingName,
          isAssessment: false,
          sessionType: SessionType.crimpy,
          durationInSeconds: reps.fold<int>(0, (sum, r) => sum + r.duration),
          date: sessionDate,
          notes: _getRandomTrainingNote(),
          repeaterConfig: repeaterConfigs[trainingName],
        ),
        'reps': reps,
      });
    }

    for (final sessionData in sessions) {
      await _trainingRepository.saveSession(
        sessionData['session'] as SessionModel,
        sessionData['reps'] as List<RepDataModel>,
      );
    }

    AppLoggerHelper.info(
      'Generated ${sessions.length} Crimpy training sessions',
    );
  }

  /// Generate assessment sessions with results
  Future<void> _generateAssessmentSessions() async {
    final now = DateTime.now();

    // Generate MVC assessments over time showing progression
    for (int i = 0; i < 5; i++) {
      final daysAgo = 14 * (i + 1); // Every 2 weeks
      final sessionDate = now.subtract(
        Duration(days: daysAgo, hours: 14, minutes: 30),
      );

      // Simulate progression over time (older = weaker)
      final baseStrength = 25.0 + (5 - i) * 2.0; // 27.0 to 35.0 kg
      final rightMVC = baseStrength + _random.nextDouble() * 3.0;
      final leftMVC = baseStrength * 0.9 + _random.nextDouble() * 2.0;

      final reps = _generateMVCReps(rightMVC, leftMVC);

      final session = SessionModel(
        name: 'Max Force',
        isAssessment: true,
        sessionType: SessionType.crimpy,
        durationInSeconds: reps.fold<int>(0, (sum, r) => sum + r.duration),
        date: sessionDate,
        notes: 'Half crimp grip position',
      );

      final sessionId = await _trainingRepository.saveSession(session, reps);

      // Save assessment result
      await gDatabase
          .into(gDatabase.assessments)
          .insert(
            AssessmentsCompanion.insert(
              type: AssessmentType.mvc.index,
              rightValue: drift.Value(rightMVC),
              leftValue: drift.Value(leftMVC),
              sessionId: sessionId,
              gripPosition: drift.Value(GripPosition.halfCrimp.index),
            ),
          );
    }

    // Generate Critical Force assessments
    for (int i = 0; i < 3; i++) {
      final daysAgo = 21 * (i + 1); // Every 3 weeks
      final sessionDate = now.subtract(
        Duration(days: daysAgo, hours: 15, minutes: 0),
      );

      final baseCF = 12.0 + (3 - i) * 1.5; // 13.5 to 16.5 kg
      final rightCF = baseCF + _random.nextDouble() * 2.0;
      final leftCF = baseCF * 0.85 + _random.nextDouble() * 1.5;

      final reps = _generateCriticalForceReps(rightCF, leftCF);

      final session = SessionModel(
        name: 'Critical Force',
        isAssessment: true,
        sessionType: SessionType.crimpy,
        durationInSeconds: reps.fold<int>(0, (sum, r) => sum + r.duration),
        date: sessionDate,
        notes: 'Half crimp grip position',
      );

      final sessionId = await _trainingRepository.saveSession(session, reps);

      // Save assessment result
      await gDatabase
          .into(gDatabase.assessments)
          .insert(
            AssessmentsCompanion.insert(
              type: AssessmentType.criticalForce.index,
              rightValue: drift.Value(rightCF),
              leftValue: drift.Value(leftCF),
              sessionId: sessionId,
              gripPosition: drift.Value(GripPosition.halfCrimp.index),
            ),
          );
    }

    AppLoggerHelper.info('Generated 8 assessment sessions');
  }

  // Helper methods

  List<RepDataModel> _generateRealisticReps(String trainingName, int daysAgo) {
    final reps = <RepDataModel>[];
    int index = 0;

    // Simulate performance degradation over time and within session
    final basePerformance =
        1.0 - (daysAgo / 120.0) * 0.1; // Older = slightly worse
    final sessionFatigue = 0.05; // 5% performance drop per set

    if (trainingName == 'Beginner Repeaters') {
      // Non-split hand: each rep is performed with both hands
      for (int set = 0; set < 3; set++) {
        for (int rep = 0; rep < 5; rep++) {
          final performance = basePerformance - (set * sessionFatigue);

          // Right hand work rep
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 7,
              targetWeight: 15.0,
              performance: performance,
              handSide: HandSide.right,
            ),
          );
          // Rest after right hand
          reps.add(_createRestRep(index: index++, duration: 3));

          // Left hand work rep
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 7,
              targetWeight: 13.0, // Slightly weaker left hand
              performance: performance * 0.95,
              handSide: HandSide.left,
            ),
          );
          // Rest after left hand (if not last rep)
          if (rep < 4) {
            reps.add(_createRestRep(index: index++, duration: 3));
          }
        }
        if (set < 2) {
          reps.add(_createRestRep(index: index++, duration: 120));
        }
      }
    } else if (trainingName == 'Advanced Hangs') {
      // Non-split hand: each rep is performed with both hands
      for (int set = 0; set < 5; set++) {
        for (int rep = 0; rep < 20; rep++) {
          final performance = basePerformance - (set * sessionFatigue);

          // Right hand work rep
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 10,
              targetWeight: 25.0,
              performance: performance,
              handSide: HandSide.right,
            ),
          );
          // Rest after right hand
          reps.add(_createRestRep(index: index++, duration: 5));

          // Left hand work rep
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 10,
              targetWeight: 22.0, // Slightly weaker left hand
              performance: performance * 0.93,
              handSide: HandSide.left,
            ),
          );
          // Rest after left hand (if not last rep)
          if (rep < 19) {
            reps.add(_createRestRep(index: index++, duration: 5));
          }
        }
        if (set < 4) {
          reps.add(_createRestRep(index: index++, duration: 180));
        }
      }
    } else if (trainingName == 'Max Hangs') {
      // Non-split hand: each rep is performed with both hands
      for (int set = 0; set < 4; set++) {
        for (int rep = 0; rep < 3; rep++) {
          final performance = basePerformance - (set * sessionFatigue * 1.2);

          // Right hand work rep
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 10,
              targetWeight: 35.0,
              performance: performance,
              handSide: HandSide.right,
            ),
          );
          // Rest after right hand
          reps.add(_createRestRep(index: index++, duration: 10));

          // Left hand work rep
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 10,
              targetWeight: 32.0, // Slightly weaker left hand
              performance: performance * 0.92,
              handSide: HandSide.left,
            ),
          );
          // Rest after left hand (if not last rep)
          if (rep < 2) {
            reps.add(_createRestRep(index: index++, duration: 10));
          }
        }
        if (set < 3) {
          reps.add(_createRestRep(index: index++, duration: 240));
        }
      }
    } else if (trainingName == 'Resi') {
      // Split hand repeater: 3 sets of 12 reps per hand
      // Each set: 12 right reps, rest, 12 left reps, long rest
      final restBetweenHands = 3 / 2; // Half of normal rest time between hands

      for (int set = 0; set < 3; set++) {
        final performance = basePerformance - (set * sessionFatigue);

        // Right hand reps
        for (int rep = 0; rep < 12; rep++) {
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 7,
              targetWeight: 31.0,
              performance: performance,
              handSide: HandSide.right,
            ),
          );
          if (rep < 11) {
            reps.add(_createRestRep(index: index++, duration: 3));
          }
        }

        // Rest between right and left hand
        reps.add(
          _createRestRep(index: index++, duration: restBetweenHands.round()),
        );

        // Left hand reps
        for (int rep = 0; rep < 12; rep++) {
          reps.add(
            _createWorkRep(
              index: index++,
              duration: 7,
              targetWeight: 27.0,
              performance: performance - 0.02, // Slightly worse on second hand
              handSide: HandSide.left,
            ),
          );
          if (rep < 11) {
            reps.add(_createRestRep(index: index++, duration: 3));
          }
        }

        // Rest between left hand and next right hand set
        if (set < 2) {
          reps.add(
            _createRestRep(index: index++, duration: restBetweenHands.round()),
          );
        }

        // Long rest between sets (8 minutes)
        if (set < 2) {
          reps.add(_createRestRep(index: index++, duration: 480));
        }
      }
    } else {
      // Endurance Workout - single round matching the training definition
      final performance = basePerformance;
      reps.add(
        _createWorkRep(
          index: index++,
          duration: 30,
          targetWeight: 20.0,
          performance: performance,
          handSide: HandSide.right,
        ),
      );
      reps.add(_createRestRep(index: index++, duration: 10));
      reps.add(
        _createWorkRep(
          index: index++,
          duration: 30,
          targetWeight: 20.0,
          performance: performance - 0.05,
          handSide: HandSide.left,
        ),
      );
      reps.add(_createRestRep(index: index++, duration: 120));
    }

    return reps;
  }

  RepDataModel _createWorkRep({
    required int index,
    required int duration,
    required double targetWeight,
    required double performance,
    required HandSide handSide,
  }) {
    // Add some random variation (±5%)
    final variation = 0.95 + _random.nextDouble() * 0.1;
    final achievedWeight = targetWeight * performance * variation;

    return RepDataModel(
      averageWeight: achievedWeight,
      isRest: false,
      handSide: handSide,
      duration: duration,
      targetWeight: targetWeight,
      index: index,
      gripPosition: GripPosition.halfCrimp,
    );
  }

  RepDataModel _createRestRep({required int index, required int duration}) {
    return RepDataModel(
      averageWeight: 0,
      isRest: true,
      handSide: HandSide.left,
      duration: duration,
      targetWeight: 0,
      index: index,
      gripPosition: GripPosition.halfCrimp,
    );
  }

  List<RepDataModel> _generateMVCReps(double rightMVC, double leftMVC) {
    return [
      _createRestRep(index: 0, duration: 10),
      RepDataModel(
        averageWeight: rightMVC,
        isRest: false,
        handSide: HandSide.right,
        duration: 5,
        targetWeight: 0,
        index: 1,
        gripPosition: GripPosition.halfCrimp,
      ),
      _createRestRep(index: 2, duration: 10),
      RepDataModel(
        averageWeight: leftMVC,
        isRest: false,
        handSide: HandSide.left,
        duration: 5,
        targetWeight: 0,
        index: 3,
        gripPosition: GripPosition.halfCrimp,
      ),
    ];
  }

  List<RepDataModel> _generateCriticalForceReps(double rightCF, double leftCF) {
    final reps = <RepDataModel>[];
    int index = 0;

    // Critical Force test: multiple rounds of progressively longer hangs
    final durations = [10, 20, 30, 40];

    for (final duration in durations) {
      reps.add(_createRestRep(index: index++, duration: 60));
      reps.add(
        RepDataModel(
          averageWeight: rightCF * (1.0 - duration / 100.0),
          isRest: false,
          handSide: HandSide.right,
          duration: duration,
          targetWeight: 0,
          index: index++,
          gripPosition: GripPosition.halfCrimp,
        ),
      );
      reps.add(_createRestRep(index: index++, duration: 60));
      reps.add(
        RepDataModel(
          averageWeight: leftCF * (1.0 - duration / 100.0),
          isRest: false,
          handSide: HandSide.left,
          duration: duration,
          targetWeight: 0,
          index: index++,
          gripPosition: GripPosition.halfCrimp,
        ),
      );
    }

    return reps;
  }

  String? _getRandomClimbingNote() {
    final notes = [
      'Great session! Sent my project route.',
      'Focused on technique and footwork today.',
      'Tried some harder routes, good progress on crimpy holds.',
      'Indoor gym session, worked on overhangs.',
      'Outdoor climbing day, beautiful weather!',
      null, // Some sessions have no notes
      null,
    ];
    return notes[_random.nextInt(notes.length)];
  }

  String? _getRandomStretchingNote() {
    final notes = [
      'Full body stretching routine.',
      'Focused on shoulders and forearms.',
      'Recovery session after hard training.',
      'Yoga flow for climbers.',
      null,
      null,
    ];
    return notes[_random.nextInt(notes.length)];
  }

  String? _getRandomTrainingNote() {
    final notes = [
      'Felt strong today, good performance!',
      'A bit tired, but completed all sets.',
      'New PR on some reps!',
      'Need more rest between sets next time.',
      'Solid session, maintaining consistency.',
      null,
      null,
      null,
    ];
    return notes[_random.nextInt(notes.length)];
  }

  Future<void> _saveSessions(List<SessionModel> sessions) async {
    for (final session in sessions) {
      await _trainingRepository.saveSession(session, []);
    }
  }
}
