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

/// Serves a recordable listing naming one prescribed assessment training, or
/// fails outright.
class _FakeApiClient extends ApiClient {
  _FakeApiClient({this.fails = false});

  final bool fails;

  /// How many times the prescribed assessments were read, so a rebuild that
  /// should have reused the previous answer can be told from one that refetched.
  int listings = 0;

  @override
  Future<List<Map<String, dynamic>>>
  getRecordableAssessmentDefinitionsApi() async {
    listings++;
    if (fails) throw ApiException('offline', isOffline: true);
    return [
      // The athlete's own, which names no program: nothing prescribes it and
      // their library already holds it.
      _ownDefinition.toJson(),
      {..._coachDefinition.toJson(), 'program_id': 'p1'},
    ];
  }

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

  test(
    'keeps the athlete own assessments when the prescriptions fail',
    () async {
      final container = _containerWith(
        own: [_training('t-own', assessment: _ownDefinition)],
        programs: ProgramRepository(_FakeApiClient(fails: true)),
      );

      final recordable = await container.read(
        recordableAssessmentTrainingsProvider.future,
      );

      expect(recordable.map((t) => t.assessment!.id), ['a-own']);
    },
  );

  test(
    'a change to the athlete library does not re-read the prescriptions',
    () async {
      // The tab keeps this provider alive, and favouriting a training in the
      // trainings tab invalidates the library. Re-reading the prescriptions
      // then costs a request per prescribed training, for a list that only
      // changes when a coach edits a program.
      final client = _FakeApiClient();
      final container = _containerWith(
        own: [_training('t-own', assessment: _ownDefinition)],
        programs: ProgramRepository(client),
      );
      container.listen(
        recordableAssessmentTrainingsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await container.read(recordableAssessmentTrainingsProvider.future);
      expect(client.listings, 1);

      container.invalidate(trainingsProvider);
      await container.read(recordableAssessmentTrainingsProvider.future);

      expect(client.listings, 1);
    },
  );

  test('has nothing to offer in guest mode beyond the builtins', () async {
    final container = _containerWith(own: const []);

    final recordable = await container.read(
      recordableAssessmentTrainingsProvider.future,
    );

    expect(recordable, isEmpty);
  });
}
