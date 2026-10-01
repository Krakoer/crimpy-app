import 'dart:io';

import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/finished_run_draft_repository.dart';
import 'package:crimpy/viewmodels/finished_run_draft_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TrainingReviewDraft _draft(String owner, {String title = 'Repeaters'}) =>
    TrainingReviewDraft(
      owner: owner,
      template: Training(id: 't1', title: title),
      results: const [],
      startedAt: DateTime(2026, 9, 28, 18, 30),
    );

void main() {
  late Directory directory;
  late FileFinishedRunDraftRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('run_draft_test');
    repository = FileFinishedRunDraftRepository(
      directory: () async => directory,
    );
  });

  tearDown(() => directory.delete(recursive: true));

  File draftFile() => File('${directory.path}/finished_run_draft.json');

  test('has nothing to offer before a run finished', () async {
    expect(await repository.read(), isNull);
  });

  test('reads back the draft it kept, in place of the one before', () async {
    await repository.write(_draft('user-1', title: 'First'));
    await repository.write(_draft('user-1', title: 'Second'));

    final back = await repository.read();

    expect(back?.title, 'Second');
    // The write goes through a file renamed over the draft, which it leaves
    // behind only when it was cut short.
    expect(File('${draftFile().path}.partial').existsSync(), isFalse);
  });

  test('forgets the draft once it is cleared', () async {
    await repository.write(_draft('user-1'));

    await repository.clear();

    expect(await repository.read(), isNull);
    expect(draftFile().existsSync(), isFalse);
  });

  // A launch must never fail over a draft it cannot read, and must not offer
  // it again on every launch after.
  test('drops a draft it cannot read', () async {
    await draftFile().writeAsString('{"version": 1, "owner"');

    expect(await repository.read(), isNull);
    expect(draftFile().existsSync(), isFalse);
  });

  group('unsavedFinishedRun', () {
    ProviderContainer containerFor(String owner) => ProviderContainer.test(
      overrides: [
        finishedRunDraftRepositoryProvider.overrideWithValue(repository),
        runDraftOwnerProvider.overrideWith((ref) async => owner),
      ],
    );

    test('offers the draft to the athlete who ran it', () async {
      await repository.write(_draft('user-1'));

      final offered = await containerFor(
        'user-1',
      ).read(unsavedFinishedRunProvider.future);

      expect(offered?.title, 'Repeaters');
    });

    // Saving it under whoever is signed in now would file the run into another
    // athlete's history, or into the store the guest just left.
    test('keeps the draft of someone else without offering it', () async {
      await repository.write(_draft('user-1'));

      final offered = await containerFor(
        FinishedRunDraft.guestOwner,
      ).read(unsavedFinishedRunProvider.future);

      expect(offered, isNull);
      expect(await repository.read(), isNotNull);
    });
  });
}
