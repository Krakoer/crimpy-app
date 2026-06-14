import 'package:crimpy/database/database.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/repositories/remote_assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:crimpy/services/auth_service.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;

part 'auth_view_model.g.dart';

class LocalImportStatus {
  final int sessionCount;
  final int trainingCount;

  const LocalImportStatus({
    required this.sessionCount,
    required this.trainingCount,
  });

  bool get hasData => sessionCount > 0 || trainingCount > 0;
}

@riverpod
ApiClient apiClient(Ref ref) {
  final client = ApiClient();
  client.onUnauthorized = () => ref.invalidate(authStateProvider);
  return client;
}

@riverpod
AuthService authService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
}

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<auth_models.User?> build() async {
    final dbUser = await gDatabase.getCurrentUser();
    if (dbUser == null) return null;

    // A stored user without a token is a stale, inconsistent state (e.g. the
    // token expired or was cleared by the 401 interceptor). Treat it as logged
    // out so the app falls back to guest mode instead of looping on
    // unauthorized requests.
    final hasToken = await ref.read(apiClientProvider).hasToken();
    if (!hasToken) return null;

    return auth_models.User(
      id: dbUser.id,
      email: dbUser.email,
      firstname: dbUser.firstname,
      lastname: dbUser.lastname,
      emailVerified: dbUser.emailVerified,
      isAdmin: dbUser.isAdmin,
      isCoach: dbUser.isCoach,
      coachValidated: dbUser.coachValidated,
      createdAt: dbUser.createdAt.toIso8601String(),
    );
  }

  Future<void> login(String email, String password) async {
    try {
      final authService = ref.read(authServiceProvider);
      final authResponse = await authService.login(email, password);

      await _saveUserToDb(authResponse.user);
      ref.invalidateSelf();

      AppLoggerHelper.info('Login successful');
    } catch (e, s) {
      AppLoggerHelper.error('Login error: $e (stacktrace: $s)');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    bool isCoach = false,
  }) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.register(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );

      ref.invalidateSelf();

      AppLoggerHelper.info('Registration successful');
    } catch (e) {
      AppLoggerHelper.error('Registration error: $e');
      rethrow;
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyEmail(token);

      final currentUser = await gDatabase.getCurrentUser();
      if (currentUser != null) {
        await gDatabase.saveCurrentUser(
          UsersCompanion(
            id: drift.Value(currentUser.id),
            emailVerified: const drift.Value(true),
          ),
        );
        ref.invalidateSelf();
      }

      AppLoggerHelper.info('Email verification successful');
    } catch (e) {
      AppLoggerHelper.error('Email verification error: $e');
      rethrow;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendVerificationEmail(email);

      AppLoggerHelper.info('Verification email resent');
    } catch (e) {
      AppLoggerHelper.error('Resend verification error: $e');
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getCurrentUser();

      await _saveUserToDb(user);
      ref.invalidateSelf();

      AppLoggerHelper.info('User data refreshed');
    } catch (e) {
      AppLoggerHelper.error('Refresh user error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      await gDatabase.wipeLocalData();
      await gDatabase.deleteCurrentUser();

      ref.invalidate(sensorConfigsProvider);
      ref.invalidateSelf();

      AppLoggerHelper.info('Logout successful, data providers invalidated');
    } catch (e) {
      AppLoggerHelper.error('Logout error: $e');
      rethrow;
    }
  }

  Future<LocalImportStatus> checkLocalDataBeforeLogin() async {
    final sessions = await gDatabase.getAllSessions();
    final trainings = await gDatabase.getAllTrainings();
    return LocalImportStatus(
      sessionCount: sessions.length,
      trainingCount: trainings.length,
    );
  }

  Future<void> importLocalDataToApi() async {
    final apiClient = ref.read(apiClientProvider);
    final remoteRepo = RemoteTrainingRepository(apiClient);
    final remoteAssessmentRepo = RemoteAssessmentRepository(apiClient);

    // Import sessions with their rep_datas and assessments
    final sessions = await gDatabase.getAllSessions();
    for (final s in sessions) {
      try {
        final dbReps = await gDatabase.getRepsForSession(s.id);
        RepeaterConfig? repeaterConfig;
        if (s.repeaterSets != null &&
            s.repeaterReps != null &&
            s.repeaterWorkTime != null &&
            s.repeaterRestTime != null &&
            s.repeaterSetRest != null &&
            s.repeaterSplitHand != null) {
          repeaterConfig = RepeaterConfig(
            sets: s.repeaterSets!,
            repsPerSet: s.repeaterReps!,
            workTime: s.repeaterWorkTime!,
            restTime: s.repeaterRestTime!,
            setRest: s.repeaterSetRest!,
            splitHand: s.repeaterSplitHand!,
          );
        }
        final session = SessionModel(
          id: s.id,
          name: s.name,
          notes: s.notes,
          date: s.date,
          isAssessment: s.isAssessment,
          sessionType: SessionType.values[s.sessionType],
          durationInSeconds: s.duration,
          repeaterConfig: repeaterConfig,
        );
        final reps = dbReps
            .map(
              (r) => RepDataModel(
                index: r.index,
                duration: r.duration,
                isRest: r.isRest,
                handSide: r.rightHand ? HandSide.right : HandSide.left,
                targetWeight: r.targetWeight,
                averageWeight: r.averageWeight,
                gripPosition: GripPosition.values[r.gripPosition],
              ),
            )
            .toList();
        final serverSessionId = await remoteRepo.saveSession(session, reps);

        if (s.isAssessment) {
          final dbAssessments = await gDatabase.getAssessmentsForSession(s.id);
          for (final a in dbAssessments) {
            try {
              await remoteAssessmentRepo.saveAssessment(
                AssessmentResultModel(
                  type: AssessmentType.values[a.type],
                  rightValue: a.rightValue,
                  leftValue: a.leftValue,
                  gripPosition: a.gripPosition != null
                      ? GripPosition.values[a.gripPosition!]
                      : null,
                ),
                serverSessionId,
              );
            } catch (e) {
              AppLoggerHelper.error(
                'Failed to import assessment for session ${s.id}: $e',
              );
            }
          }
        }
      } catch (e) {
        AppLoggerHelper.error('Failed to import session ${s.id}: $e');
      }
    }

    // Import trainings with their items
    final trainings = await gDatabase.getAllTrainings();
    for (final t in trainings) {
      try {
        await remoteRepo.saveTraining(t);
      } catch (e) {
        AppLoggerHelper.error('Failed to import training ${t.id}: $e');
      }
    }

    // Import pinned builtin trainings
    final pinnedIds = await gDatabase.getPinnedBuiltinTrainingIds();
    for (final id in pinnedIds) {
      try {
        await apiClient.pinBuiltinTrainingApi(id);
      } catch (e) {
        AppLoggerHelper.error('Failed to import pinned builtin $id: $e');
      }
    }

    // Import builtin training weights
    final weights = await gDatabase.getAllBuiltinTrainingWeights();
    for (final w in weights) {
      try {
        await apiClient.createBuiltinTrainingWeight({
          'id': w.id,
          'builtin_training_id': w.builtinTrainingId,
          'custom_weight_right': w.customWeightRight ?? 0.0,
          'custom_weight_left': w.customWeightLeft ?? 0.0,
        });
      } catch (e) {
        AppLoggerHelper.error(
          'Failed to import builtin weight ${w.builtinTrainingId}: $e',
        );
      }
    }

    AppLoggerHelper.info('Local data import complete');
  }

  Future<void> clearLocalDataAfterLogin() async {
    await gDatabase.wipeLocalData();
    ref.invalidate(sensorConfigsProvider);
    ref.invalidateSelf();
  }

  Future<void> _saveUserToDb(auth_models.User user) async {
    await gDatabase.saveCurrentUser(
      UsersCompanion.insert(
        id: user.id,
        email: user.email,
        firstname: user.firstname,
        lastname: user.lastname,
        emailVerified: drift.Value(user.emailVerified),
        isAdmin: drift.Value(user.isAdmin),
        isCoach: drift.Value(user.isCoach),
        coachValidated: drift.Value(user.coachValidated),
        // DateTime are in format "2006-01-02 15:04:05.999999999 +0000 UTC"
        createdAt: drift.Value(
          DateTime.parse(user.createdAt.replaceAll(" +0000 UTC", "")),
        ),
      ),
    );
  }
}
