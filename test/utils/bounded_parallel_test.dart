import 'package:crimpy/utils/bounded_parallel.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts how many tasks were running at the same moment, so a run can be
/// checked for the bound rather than only for its results.
class _ConcurrencyWitness {
  int inFlight = 0;
  int peakInFlight = 0;
  final List<int> startOrder = [];

  /// A task that stays outstanding for a few event loop turns, which is what
  /// gives an unbounded run the chance to start everything at once.
  Future<T> Function() task<T>(int index, T Function() result) {
    return () async {
      startOrder.add(index);
      inFlight++;
      if (inFlight > peakInFlight) peakInFlight = inFlight;
      try {
        for (var turn = 0; turn < 3; turn++) {
          await Future<void>.delayed(Duration.zero);
        }
        return result();
      } finally {
        inFlight--;
      }
    };
  }
}

void main() {
  group('inParallel', () {
    test('keeps the results in the order the tasks were given', () async {
      // The later tasks finish first, so a run that collected results as they
      // landed rather than by index would come back close to reversed.
      final results = await inParallel([
        for (var index = 0; index < 12; index++)
          () async {
            await Future<void>.delayed(Duration(milliseconds: 12 - index));
            return 'task-$index';
          },
      ]);

      expect(results, [for (var index = 0; index < 12; index++) 'task-$index']);
    });

    test('answers with an empty list for no tasks', () async {
      final results = await inParallel(<Future<int> Function()>[]);

      expect(results, isEmpty);
    });

    test('rethrows what a task threw', () async {
      await expectLater(
        inParallel([
          () async => 0,
          () async {
            await Future<void>.delayed(Duration.zero);
            throw StateError('task 1 failed');
          },
          () async => 2,
        ]),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'task 1 failed',
          ),
        ),
      );
    });

    test('lets the tasks a failed one did not take run to the end', () async {
      final finished = <int>[];

      await expectLater(
        inParallel([
          () async {
            await Future<void>.delayed(Duration.zero);
            throw StateError('first task failed');
          },
          for (var index = 1; index < 5; index++)
            () async {
              await Future<void>.delayed(Duration.zero);
              finished.add(index);
              return index;
            },
        ], concurrency: 2),
        throwsA(isA<StateError>()),
      );

      expect(finished, [1, 2, 3, 4]);
    });

    test(
      'keeps six tasks outstanding by default, no more and no fewer',
      () async {
        final witness = _ConcurrencyWitness();

        final results = await inParallel([
          for (var index = 0; index < 30; index++)
            witness.task(index, () => index),
        ]);

        expect(results, [for (var index = 0; index < 30; index++) index]);
        expect(witness.peakInFlight, 6);
        // The pool takes the tasks from the front, so the first batch is the
        // first six and nothing further starts before one of them is done.
        expect(witness.startOrder.take(6), [0, 1, 2, 3, 4, 5]);
      },
    );

    test('honours a concurrency the caller asks for', () async {
      final witness = _ConcurrencyWitness();

      await inParallel([
        for (var index = 0; index < 10; index++)
          witness.task(index, () => index),
      ], concurrency: 3);

      expect(witness.peakInFlight, 3);
    });

    test('refuses a concurrency below one', () async {
      // An assert would be stripped out of a release build and the run would
      // answer a list of nulls instead of naming what was wrong.
      await expectLater(
        inParallel([() async => 1], concurrency: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('runs fewer workers than the bound when there is less work', () async {
      final witness = _ConcurrencyWitness();

      await inParallel([
        for (var index = 0; index < 2; index++)
          witness.task(index, () => index),
      ]);

      expect(witness.peakInFlight, 2);
    });
  });
}
