import 'package:crimpy/repositories/program_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _program(String id) => {
  'id': id,
  'coach_id': 'coach',
  'user_id': 'athlete',
  'name': 'Program $id',
  'start_date': '2026-01-05',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _week(
  String programId,
  int number,
  List<String> trainingIds,
) => {
  'id': '$programId-w$number',
  'program_id': programId,
  'week_number': number,
  'sessions': [
    for (final (index, trainingId) in trainingIds.indexed)
      {
        'id': '$programId-w$number-s$index',
        'training_id': trainingId,
        'training_title': trainingId,
        'training_type': 'hangboard',
        'position': index,
      },
  ],
};

Map<String, dynamic> _training(String id, {Map<String, dynamic>? assessment}) =>
    {
      'id': id,
      'title': 'Training $id',
      'items': <dynamic>[],
      if (assessment != null) 'assessment': assessment,
    };

/// Serves a fixed program tree, counting what was asked for so the walk can be
/// checked for fetching a shared training once.
class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    required this.programs,
    required this.weeks,
    required this.trainings,
    this.failingWeeks = const {},
    this.failingTrainings = const {},
  });

  final List<Map<String, dynamic>> programs;

  /// Weeks per program id.
  final Map<String, List<Map<String, dynamic>>> weeks;
  final Map<String, Map<String, dynamic>> trainings;
  final Set<int> failingWeeks;
  final Set<String> failingTrainings;

  final List<String> fetchedTrainings = [];

  /// How many requests were outstanding at once, over the whole walk.
  int inFlight = 0;
  int peakInFlight = 0;

  Future<T> _tracked<T>(Future<T> Function() request) async {
    inFlight++;
    if (inFlight > peakInFlight) peakInFlight = inFlight;
    try {
      await Future<void>.delayed(Duration.zero);
      return await request();
    } finally {
      inFlight--;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyPrograms() async => programs;

  @override
  Future<List<Map<String, dynamic>>> getMyWeeks(String programId) => _tracked(
    () async => [
      for (final week in weeks[programId] ?? const <Map<String, dynamic>>[])
        {
          'id': week['id'],
          'program_id': week['program_id'],
          'week_number': week['week_number'],
        },
    ],
  );

  @override
  Future<Map<String, dynamic>> getMyWeek(String programId, int weekNumber) =>
      _tracked(() async {
        if (failingWeeks.contains(weekNumber)) {
          throw ApiException('boom', statusCode: 500);
        }
        return (weeks[programId] ?? const <Map<String, dynamic>>[]).firstWhere(
          (week) => week['week_number'] == weekNumber,
        );
      });

  @override
  Future<Map<String, dynamic>> getMyProgramTraining(
    String programId,
    String trainingId,
  ) => _tracked(() async {
    fetchedTrainings.add(trainingId);
    if (failingTrainings.contains(trainingId)) {
      throw ApiException('boom', statusCode: 500);
    }
    return trainings[trainingId]!;
  });
}

void main() {
  group('prescribed assessments', () {
    test('keeps the prescribed trainings that are assessments', () async {
      final client = _FakeApiClient(
        programs: [_program('p1')],
        weeks: {
          'p1': [
            _week('p1', 1, ['t-strength', 't-max-pull-ups']),
          ],
        },
        trainings: {
          't-strength': _training('t-strength'),
          't-max-pull-ups': _training(
            't-max-pull-ups',
            assessment: {
              'id': 'a-pull-ups',
              'label': 'Max pull ups',
              'unit': 'repetitions',
              'per_hand': false,
              'training_id': 't-max-pull-ups',
            },
          ),
        },
      );

      final found = await ProgramRepository(
        client,
      ).getPrescribedAssessmentTrainings();

      expect(found.map((t) => t.id), ['t-max-pull-ups']);
      expect(found.single.assessment!.label, 'Max pull ups');
    });

    test('fetches a training prescribed by several weeks once', () async {
      final client = _FakeApiClient(
        programs: [_program('p1')],
        weeks: {
          'p1': [
            _week('p1', 1, ['t-max-pull-ups']),
            _week('p1', 2, ['t-max-pull-ups']),
          ],
        },
        trainings: {'t-max-pull-ups': _training('t-max-pull-ups')},
      );

      await ProgramRepository(client).getPrescribedAssessmentTrainings();

      expect(client.fetchedTrainings, ['t-max-pull-ups']);
    });

    test('a week that cannot be read leaves the others alone', () async {
      final client = _FakeApiClient(
        programs: [_program('p1')],
        weeks: {
          'p1': [
            _week('p1', 1, ['t-broken']),
            _week('p1', 2, ['t-max-pull-ups']),
          ],
        },
        trainings: {
          't-max-pull-ups': _training(
            't-max-pull-ups',
            assessment: {
              'id': 'a-pull-ups',
              'label': 'Max pull ups',
              'unit': 'repetitions',
            },
          ),
        },
        failingWeeks: {1},
      );

      final found = await ProgramRepository(
        client,
      ).getPrescribedAssessmentTrainings();

      expect(found.map((t) => t.id), ['t-max-pull-ups']);
    });

    test('a training that cannot be read leaves the others alone', () async {
      final client = _FakeApiClient(
        programs: [_program('p1')],
        weeks: {
          'p1': [
            _week('p1', 1, ['t-broken', 't-max-pull-ups']),
          ],
        },
        trainings: {
          't-max-pull-ups': _training(
            't-max-pull-ups',
            assessment: {
              'id': 'a-pull-ups',
              'label': 'Max pull ups',
              'unit': 'repetitions',
            },
          ),
        },
        failingTrainings: {'t-broken'},
      );

      final found = await ProgramRepository(
        client,
      ).getPrescribedAssessmentTrainings();

      expect(found.map((t) => t.id), ['t-max-pull-ups']);
    });

    test('keeps the walk off the wire in one burst', () async {
      // A season of programs is dozens of weeks and dozens of trainings, and
      // firing them all at once is a burst the athlete connection absorbs in
      // one go.
      final client = _FakeApiClient(
        programs: [_program('p1')],
        weeks: {
          'p1': [
            for (var number = 1; number <= 20; number++)
              _week('p1', number, ['t-$number']),
          ],
        },
        trainings: {
          for (var number = 1; number <= 20; number++)
            't-$number': _training('t-$number'),
        },
      );

      await ProgramRepository(client).getPrescribedAssessmentTrainings();

      expect(client.fetchedTrainings, hasLength(20));
      expect(client.peakInFlight, lessThanOrEqualTo(6));
    });

    test('an assessment stays listed once its week is in the past', () async {
      final client = _FakeApiClient(
        programs: [_program('p1')],
        weeks: {
          'p1': [
            _week('p1', 1, ['t-max-pull-ups']),
            _week('p1', 2, const []),
          ],
        },
        trainings: {
          't-max-pull-ups': _training(
            't-max-pull-ups',
            assessment: {
              'id': 'a-pull-ups',
              'label': 'Max pull ups',
              'unit': 'repetitions',
            },
          ),
        },
      );

      final found = await ProgramRepository(
        client,
      ).getPrescribedAssessmentTrainings();

      expect(found.map((t) => t.id), ['t-max-pull-ups']);
    });
  });
}
