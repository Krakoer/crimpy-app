import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/remote_assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer containerFor({required bool authenticated}) =>
    ProviderContainer.test(
      overrides: [isAuthenticatedProvider.overrideWith((ref) => authenticated)],
    );

void main() {
  group('guest mode', () {
    test('trainings and assessments come from the local database', () {
      final container = containerFor(authenticated: false);

      expect(
        container.read(trainingRepositoryProvider),
        isA<LocalTrainingRepository>(),
      );
      expect(
        container.read(assessmentRepositoryProvider),
        isA<LocalAssessmentRepository>(),
      );
    });

    test('there is no program repository', () {
      final container = containerFor(authenticated: false);

      expect(container.read(programRepositoryProvider), isNull);
    });
  });

  group('authenticated', () {
    test('trainings and assessments come from the API', () {
      final container = containerFor(authenticated: true);

      expect(
        container.read(trainingRepositoryProvider),
        isA<RemoteTrainingRepository>(),
      );
      expect(
        container.read(assessmentRepositoryProvider),
        isA<RemoteAssessmentRepository>(),
      );
    });

    test('a program repository is available', () {
      final container = containerFor(authenticated: true);

      expect(container.read(programRepositoryProvider), isNotNull);
    });
  });

  test('signing out swaps the remote repositories back to local ones', () {
    var authenticated = true;
    final container = ProviderContainer.test(
      overrides: [isAuthenticatedProvider.overrideWith((ref) => authenticated)],
    );
    container.listen(trainingRepositoryProvider, (previous, next) {});

    expect(
      container.read(trainingRepositoryProvider),
      isA<RemoteTrainingRepository>(),
    );

    authenticated = false;
    container.invalidate(isAuthenticatedProvider);

    expect(
      container.read(trainingRepositoryProvider),
      isA<LocalTrainingRepository>(),
    );
  });
}
