import 'package:crimpy/logger.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/repositories/finished_run_draft_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderSubscription;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'finished_run_draft_view_model.g.dart';

/// Where a finished run waits for its review to be saved. Krakoer/crimpy#146.
@Riverpod(keepAlive: true)
FinishedRunDraftRepository finishedRunDraftRepository(Ref ref) =>
    FileFinishedRunDraftRepository();

/// Who a run finished now belongs to: the signed in user, or the guest.
///
/// Read once the auth state has settled, never from the cold start's loading
/// state, which would name the guest for an athlete who is signed in.
@Riverpod(keepAlive: true)
Future<String> runDraftOwner(Ref ref) async {
  final user = await ref.watch(authStateProvider.future);
  return user?.id ?? FinishedRunDraft.guestOwner;
}

/// The draft a launch offers back: the one left on the device, when it belongs
/// to whoever is using the app now. A draft of someone else is left where it
/// is rather than offered or dropped, so it is still there when they sign back
/// in, unless a run finished meanwhile took its place.
///
/// Read once, by a launch, while the sign in may still be settling. [owner]
/// listens to [runDraftOwnerProvider] until the answer is in, so a sign in that
/// settles again meanwhile rebuilds it and the answer names the right owner; a
/// bare read would wait on a build that was thrown away. Closed once read.
Future<FinishedRunDraft?> unsavedFinishedRun({
  required ProviderSubscription<Future<String>> owner,
  required FinishedRunDraftRepository repository,
}) async {
  try {
    final draft = await repository.read();
    if (draft == null || draft.owner != await owner.read()) return null;
    return draft;
  } finally {
    owner.close();
  }
}

/// Who the run that just finished belongs to, or null when that cannot be
/// told. The run then goes to its review without being kept: ending a run must
/// not hang on the sign in, and a draft filed under a guessed owner could be
/// offered to the wrong athlete.
Future<String?> finishedRunOwner(Future<String> owner) async {
  try {
    return await owner;
  } catch (error) {
    AppLoggerHelper.error('Could not tell who ran the finished run', error);
    return null;
  }
}

/// Keeps [draft] on the device before its review is shown. A write that fails
/// is logged and the review goes ahead: the run is still on screen, and losing
/// only the safety net is better than losing the review too.
Future<void> keepFinishedRun(
  FinishedRunDraftRepository repository,
  FinishedRunDraft draft,
) async {
  try {
    await repository.write(draft);
  } catch (error) {
    AppLoggerHelper.error('Could not keep the finished run', error);
  }
}

/// Forgets the draft once its run is saved or discarded. A failure is logged:
/// the worst it costs is the run being offered back once more.
Future<void> forgetFinishedRun(FinishedRunDraftRepository repository) async {
  try {
    await repository.clear();
  } catch (error) {
    AppLoggerHelper.error('Could not forget the finished run', error);
  }
}
