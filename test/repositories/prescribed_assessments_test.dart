import 'package:crimpy/repositories/program_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

/// A row of the recordable listing. The builtins and the athlete's own carry no
/// program, which is what tells them apart from a prescribed one.
Map<String, dynamic> _definition(
  String id, {
  String? trainingId,
  String? programId,
}) => {
  'id': id,
  'label': 'Assessment $id',
  'unit': 'repetitions',
  'per_hand': false,
  'is_builtin': trainingId == null,
  if (trainingId != null) 'training_id': trainingId,
  if (programId != null) 'program_id': programId,
};

Map<String, dynamic> _training(String id, {Map<String, dynamic>? assessment}) =>
    {
      'id': id,
      'title': 'Training $id',
      'items': <dynamic>[],
      if (assessment != null) 'assessment': assessment,
    };

Map<String, dynamic> _assessment(String id, String trainingId) => {
  'id': id,
  'label': 'Assessment $id',
  'unit': 'repetitions',
  'per_hand': false,
  'training_id': trainingId,
};

/// Serves a fixed recordable listing and the trainings it names, recording what
/// was asked for so the fetching can be checked.
class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    required this.definitions,
    required this.trainings,
    this.failingTrainings = const {},
  });

  final List<Map<String, dynamic>> definitions;
  final Map<String, Map<String, dynamic>> trainings;
  final Set<String> failingTrainings;

  final List<String> fetchedTrainings = [];
  final List<(String, String)> fetchedUnder = [];

  /// How many requests were outstanding at once, over the whole fetch.
  int inFlight = 0;
  int peakInFlight = 0;

  @override
  Future<List<Map<String, dynamic>>>
  getRecordableAssessmentDefinitionsApi() async => definitions;

  @override
  Future<List<Map<String, dynamic>>> getMyPrograms() async {
    throw StateError('the prescribed assessments must not walk the programs');
  }

  @override
  Future<List<Map<String, dynamic>>> getMyWeeks(String programId) async {
    throw StateError('the prescribed assessments must not walk the programs');
  }

  @override
  Future<Map<String, dynamic>> getMyWeek(
    String programId,
    int weekNumber,
  ) async {
    throw StateError('the prescribed assessments must not walk the programs');
  }

  @override
  Future<Map<String, dynamic>> getMyProgramTraining(
    String programId,
    String trainingId,
  ) async {
    inFlight++;
    if (inFlight > peakInFlight) peakInFlight = inFlight;
    try {
      await Future<void>.delayed(Duration.zero);
      fetchedTrainings.add(trainingId);
      fetchedUnder.add((programId, trainingId));
      if (failingTrainings.contains(trainingId)) {
        throw ApiException('boom', statusCode: 500);
      }
      return trainings[trainingId]!;
    } finally {
      inFlight--;
    }
  }
}

void main() {
  group('prescribed assessments', () {
    test(
      'fetches the trainings the server names, under their program',
      () async {
        final client = _FakeApiClient(
          definitions: [
            _definition('a-builtin'),
            _definition('a-own', trainingId: 't-own'),
            _definition(
              'a-pull-ups',
              trainingId: 't-max-pull-ups',
              programId: 'p1',
            ),
          ],
          trainings: {
            't-max-pull-ups': _training(
              't-max-pull-ups',
              assessment: _assessment('a-pull-ups', 't-max-pull-ups'),
            ),
          },
        );

        final found = await ProgramRepository(
          client,
        ).getPrescribedAssessmentTrainings();

        expect(found.map((t) => t.id), ['t-max-pull-ups']);
        expect(found.single.assessment!.id, 'a-pull-ups');
        expect(client.fetchedUnder, [('p1', 't-max-pull-ups')]);
      },
    );

    test('leaves the builtins and the athlete own assessments alone', () async {
      // They name no program because nothing prescribes them, and the app
      // already holds them: the builtins are compiled in and the athlete's own
      // come with their library.
      final client = _FakeApiClient(
        definitions: [
          _definition('a-builtin'),
          _definition('a-own', trainingId: 't-own'),
        ],
        trainings: {'t-own': _training('t-own')},
      );

      final found = await ProgramRepository(
        client,
      ).getPrescribedAssessmentTrainings();

      expect(found, isEmpty);
      expect(client.fetchedTrainings, isEmpty);
    });

    test('fetches a training named by two prescriptions once', () async {
      final client = _FakeApiClient(
        definitions: [
          _definition(
            'a-pull-ups',
            trainingId: 't-max-pull-ups',
            programId: 'p1',
          ),
          _definition(
            'a-pull-ups-again',
            trainingId: 't-max-pull-ups',
            programId: 'p2',
          ),
        ],
        trainings: {
          't-max-pull-ups': _training(
            't-max-pull-ups',
            assessment: _assessment('a-pull-ups', 't-max-pull-ups'),
          ),
        },
      );

      await ProgramRepository(client).getPrescribedAssessmentTrainings();

      expect(client.fetchedTrainings, ['t-max-pull-ups']);
    });

    test('a training that cannot be read leaves the others alone', () async {
      final client = _FakeApiClient(
        definitions: [
          _definition('a-broken', trainingId: 't-broken', programId: 'p1'),
          _definition(
            'a-pull-ups',
            trainingId: 't-max-pull-ups',
            programId: 'p1',
          ),
        ],
        trainings: {
          't-max-pull-ups': _training(
            't-max-pull-ups',
            assessment: _assessment('a-pull-ups', 't-max-pull-ups'),
          ),
        },
        failingTrainings: {'t-broken'},
      );

      final found = await ProgramRepository(
        client,
      ).getPrescribedAssessmentTrainings();

      expect(found.map((t) => t.id), ['t-max-pull-ups']);
    });

    test(
      'a training the server called an assessment but that comes back without one is dropped',
      () async {
        // Nothing should produce this, and what reads the list dereferences the
        // assessment, so a disagreement must not reach it.
        final client = _FakeApiClient(
          definitions: [
            _definition('a-pull-ups', trainingId: 't-plain', programId: 'p1'),
          ],
          trainings: {'t-plain': _training('t-plain')},
        );

        final found = await ProgramRepository(
          client,
        ).getPrescribedAssessmentTrainings();

        expect(found, isEmpty);
      },
    );

    test('keeps the fetching off the wire in one burst', () async {
      // An athlete on several programs can be prescribed more assessments than
      // the pool is wide, and firing them all at once is a burst their
      // connection absorbs in one go.
      final client = _FakeApiClient(
        definitions: [
          for (var number = 1; number <= 20; number++)
            _definition('a-$number', trainingId: 't-$number', programId: 'p1'),
        ],
        trainings: {
          for (var number = 1; number <= 20; number++)
            't-$number': _training(
              't-$number',
              assessment: _assessment('a-$number', 't-$number'),
            ),
        },
      );

      await ProgramRepository(client).getPrescribedAssessmentTrainings();

      expect(client.fetchedTrainings, hasLength(20));
      expect(client.peakInFlight, lessThanOrEqualTo(6));
    });
  });
}
