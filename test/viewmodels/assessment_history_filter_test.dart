import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AssessmentModel _result(String assessmentId, String id, DateTime date) =>
    AssessmentModel(
      id: id,
      date: date,
      definition: AssessmentDefinition(
        id: assessmentId,
        label: 'Assessment $assessmentId',
        unit: AssessmentUnit.kilograms,
      ),
      rightValue: 1,
    );

/// A history spanning two assessments, handed back oldest first the way both
/// stores order it, and counting its reads.
class _HistoryOfTwo extends AssessmentRepository {
  int reads = 0;

  static final rows = [
    _result('a-1', 'r-1', DateTime.utc(2026, 1, 1)),
    _result('a-2', 'r-2', DateTime.utc(2026, 1, 2)),
    _result('a-1', 'r-3', DateTime.utc(2026, 1, 3)),
    _result('a-2', 'r-4', DateTime.utc(2026, 1, 4)),
  ];

  @override
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    reads++;
    return rows;
  }

  @override
  Future<List<AssessmentDefinition>> getAssessmentDefinitions() async =>
      const [];

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async => throw UnimplementedError();

  @override
  Future<void> deleteAssessment(String id) => throw UnimplementedError();
}

ProviderContainer _containerFor(_HistoryOfTwo history) =>
    ProviderContainer.test(
      overrides: [assessmentRepositoryProvider.overrideWith((ref) => history)],
    );

void main() {
  // The keyed entries used to ask the store for a narrower list. They filter the
  // shared history in memory now, so what the filter does is this repo's
  // business rather than the store's and has to be asserted here.
  group('a keyed assessment list', () {
    test('holds only that assessment, oldest first', () async {
      final history = _HistoryOfTwo();
      final container = _containerFor(history);

      final measured = await container.read(assessmentsProvider('a-1').future);

      expect(measured.map((result) => result.id), ['r-1', 'r-3']);
      // Callers take the last entry as the most recent one, so the order is
      // part of the contract and filtering must not disturb it.
      expect(measured.last.id, 'r-3');
    });

    test('costs no read of its own', () async {
      final history = _HistoryOfTwo();
      final container = _containerFor(history);

      await container.read(assessmentsProvider('a-1').future);
      await container.read(assessmentsProvider('a-2').future);
      await container.read(assessmentsProvider(null).future);

      // Three views, one read. Asking the store per key is what this replaced.
      expect(history.reads, 1);
    });

    test('hands the whole history through under a null key', () async {
      final history = _HistoryOfTwo();
      final container = _containerFor(history);

      final all = await container.read(assessmentsProvider(null).future);

      expect(all.map((result) => result.id), ['r-1', 'r-2', 'r-3', 'r-4']);
    });

    test('is empty for an assessment with no results', () async {
      final history = _HistoryOfTwo();
      final container = _containerFor(history);

      expect(
        await container.read(assessmentsProvider('a-none').future),
        isEmpty,
      );
    });
  });
}
