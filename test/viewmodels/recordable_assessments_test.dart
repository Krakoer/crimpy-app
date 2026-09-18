import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/program_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _ownDefinition = AssessmentDefinition(
  id: 'a-own',
  label: 'Board repeaters',
  unit: AssessmentUnit.seconds,
  trainingId: 't-own',
);

const _coachDefinition = AssessmentDefinition(
  id: 'a-coach',
  label: 'Max pull ups',
  unit: AssessmentUnit.repetitions,
  trainingId: 't-coach',
);

Training _training(String id, {AssessmentDefinition? assessment}) =>
    Training(id: id, title: 'Training $id', assessment: assessment);

/// The athlete's own library, served without a database behind it.
class _OwnTrainings extends Trainings {
  _OwnTrainings(this._trainings);

  final List<Training> _trainings;

  @override
  Future<List<Training>> build() async => _trainings;
}

/// Serves one program prescribing one assessment training, or fails outright.
class _FakeApiClient extends ApiClient {
  _FakeApiClient({this.fails = false});

  final bool fails;

  @override
  Future<List<Map<String, dynamic>>> getMyPrograms() async {
    if (fails) throw ApiException('offline', isOffline: true);
    return [
      {
        'id': 'p1',
        'coach_id': 'coach',
        'user_id': 'athlete',
        'name': 'Base',
        'start_date': '2026-01-05',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getMyWeeks(String programId) async => [
    {'id': 'w1', 'program_id': programId, 'week_number': 1},
  ];

  @override
  Future<Map<String, dynamic>> getMyWeek(
    String programId,
    int weekNumber,
  ) async => {
    'id': 'w1',
    'program_id': programId,
    'week_number': weekNumber,
    'sessions': [
      {
        'id': 's1',
        'training_id': 't-coach',
        'training_title': 'Max pull ups',
        'training_type': 'workout',
        'position': 0,
      },
    ],
  };

  @override
  Future<Map<String, dynamic>> getMyProgramTraining(
    String programId,
    String trainingId,
  ) async => {
    'id': trainingId,
    'title': 'Max pull ups test',
    'items': <dynamic>[],
    'assessment': _coachDefinition.toJson(),
  };
}

ProviderContainer _containerWith({
  required List<Training> own,
  ProgramRepository? programs,
}) => ProviderContainer.test(
  overrides: [
    trainingsProvider.overrideWith(() => _OwnTrainings(own)),
    programRepositoryProvider.overrideWith((ref) => programs),
  ],
);

void main() {
  test('lists the athlete own assessments and their coach ones', () async {
    final container = _containerWith(
      own: [
        _training('t-plain'),
        _training('t-own', assessment: _ownDefinition),
      ],
      programs: ProgramRepository(_FakeApiClient()),
    );

    final recordable = await container.read(
      recordableAssessmentTrainingsProvider.future,
    );

    expect(recordable.map((t) => t.assessment!.id), [
      // Ordered by name, the way the history lists them.
      'a-own',
      'a-coach',
    ]);
  });

  test('leaves out a training that is not an assessment', () async {
    final container = _containerWith(own: [_training('t-plain')]);

    final recordable = await container.read(
      recordableAssessmentTrainingsProvider.future,
    );

    expect(recordable, isEmpty);
  });

  test('lists an assessment prescribed and owned only once', () async {
    final container = _containerWith(
      own: [_training('t-coach', assessment: _coachDefinition)],
      programs: ProgramRepository(_FakeApiClient()),
    );

    final recordable = await container.read(
      recordableAssessmentTrainingsProvider.future,
    );

    expect(recordable.map((t) => t.assessment!.id), ['a-coach']);
  });

  test('keeps the athlete own assessments when the programs fail', () async {
    final container = _containerWith(
      own: [_training('t-own', assessment: _ownDefinition)],
      programs: ProgramRepository(_FakeApiClient(fails: true)),
    );

    final recordable = await container.read(
      recordableAssessmentTrainingsProvider.future,
    );

    expect(recordable.map((t) => t.assessment!.id), ['a-own']);
  });

  test('has nothing to offer in guest mode beyond the builtins', () async {
    final container = _containerWith(own: const []);

    final recordable = await container.read(
      recordableAssessmentTrainingsProvider.future,
    );

    expect(recordable, isEmpty);
  });
}
