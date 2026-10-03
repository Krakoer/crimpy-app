import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/repositories/finished_run_draft_repository.dart';
import 'package:crimpy/viewmodels/finished_run_draft_view_model.dart';
import 'package:flutter_riverpod/misc.dart';

/// Holds the finished run in memory: the file store reaches for the documents
/// directory, which no test binding answers, and would hold every run screen
/// waiting on it.
class MemoryRunDrafts extends FinishedRunDraftRepository {
  FinishedRunDraft? draft;

  MemoryRunDrafts([this.draft]);

  @override
  Future<FinishedRunDraft?> read() async => draft;

  @override
  Future<void> write(FinishedRunDraft draft) async => this.draft = draft;

  @override
  Future<void> clear() async => draft = null;
}

/// What a screen that keeps or forgets a finished run needs to run in a test:
/// an in-memory store, and an owner that does not wait on the stored sign in.
List<Override> runDraftOverrides([MemoryRunDrafts? drafts]) => [
  finishedRunDraftRepositoryProvider.overrideWithValue(
    drafts ?? MemoryRunDrafts(),
  ),
  runDraftOwnerProvider.overrideWith(
    (ref) async => FinishedRunDraft.guestOwner,
  ),
];
