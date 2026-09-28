import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _history = [
  AssessmentModel(
    id: 'mvc',
    date: DateTime(2026, 1, 1),
    definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
    rightValue: 40,
    leftValue: 40,
    gripPosition: GripPosition.halfCrimp,
  ),
];

/// A right hand hang at half the bodyweight: rated only once one is known.
final _bodyweightHang = Training(
  id: 'bw',
  title: 'Bodyweight hang',
  items: [
    TrainingItem(
      id: 'i',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: HangboardHand.right,
      loads: const [Load(value: 50, unit: 'percent_bw')],
      handPositions: const [
        ['HC'],
      ],
    ),
  ],
);

class _Bodyweight extends BodyweightController {
  final double? kilograms;
  _Bodyweight(this.kilograms);

  @override
  Future<double?> build() async => kilograms;
}

class _FailingBodyweight extends BodyweightController {
  @override
  Future<double?> build() async => throw StateError('no bodyweight store');
}

ProviderContainer _container(BodyweightController Function() bodyweight) =>
    ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        trainingLibraryProvider.overrideWith(
          (ref) async => (trainings: [_bodyweightHang], truncated: false),
        ),
        assessmentHistoryProvider.overrideWith((ref) async => _history),
        builtinTrainingCatalogProvider.overrideWith(
          (ref) async => (
            trainings: builtinTrainings
                .where((b) => b.name == 'Max Force')
                .toList(),
            pinnedIds: const <String>[],
            assessments: _history,
            customWeights:
                const <String, ({double? weightRight, double? weightLeft})>{},
          ),
        ),
        bodyweightProvider.overrideWith(bodyweight),
      ],
    );

TrainingListItem _named(List<TrainingListItem> items, String name) =>
    items.firstWhere((item) => item.name == name);

void main() {
  test('a known bodyweight rates the regular hang and the builtin', () async {
    final items = await _container(
      () => _Bodyweight(60),
    ).read(allTrainingsProvider.future);

    // 30 kg on a 40 kg half crimp max.
    expect(
      _named(items, 'Bodyweight hang').intensity!.percentOfMax,
      closeTo(75, 1e-9),
    );
    expect(
      _named(items, 'Max Force').intensity!.percentOfMax,
      closeTo(85, 1e-9),
    );
  });

  test('no bodyweight leaves the %BW hang unrated', () async {
    final items = await _container(
      () => _Bodyweight(null),
    ).read(allTrainingsProvider.future);

    expect(_named(items, 'Bodyweight hang').intensity, isNull);
    expect(_named(items, 'Max Force').intensity, isNotNull);
  });

  test('a bodyweight that fails to read does not fail the lists', () async {
    final container = _container(_FailingBodyweight.new);

    final all = await container.read(allTrainingsProvider.future);
    await container.read(pinnedTrainingsProvider.future);

    expect(_named(all, 'Bodyweight hang').intensity, isNull);
    expect(_named(all, 'Max Force').intensity, isNotNull);
  });
}
