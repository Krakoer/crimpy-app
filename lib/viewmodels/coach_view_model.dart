import 'package:crimpy/logger.dart';
import 'package:crimpy/models/coach_enrollment.dart';
import 'package:crimpy/repositories/coach_enrollment_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_view_model.g.dart';

/// Enrollment repository, or null in guest mode: an athlete with no account
/// has no coach to be enrolled with.
@Riverpod(keepAlive: true)
CoachEnrollmentRepository? coachEnrollmentRepository(Ref ref) {
  if (!ref.watch(isAuthenticatedProvider)) return null;
  return CoachEnrollmentRepository(ref.watch(apiClientProvider));
}

/// The coach this athlete is enrolled with, null when they have none.
///
/// A failed fetch also answers null rather than throwing: every caller so far
/// only decides whether to offer something coach related, and an offline
/// launch should drop the offer, not fail around it.
@Riverpod(keepAlive: true)
Future<CoachEnrollment?> coachEnrollment(Ref ref) async {
  final repository = ref.watch(coachEnrollmentRepositoryProvider);
  if (repository == null) return null;
  try {
    return await repository.getEnrollment();
  } catch (error) {
    AppLoggerHelper.warning('Coach enrollment fetch failed: $error');
    return null;
  }
}
