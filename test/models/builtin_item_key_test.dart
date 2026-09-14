import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/builtin_training.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// MVC on both hands in every grip, so every builtin training is available.
List<AssessmentResultModel> maxForce() => [
  for (final grip in GripPosition.values)
    AssessmentResultModel(
      assessmentId: BuiltinAssessmentIds.maxForce,
      rightValue: 50,
      leftValue: 48,
      gripPosition: grip,
    ),
];

void main() {
  group('a generated builtin training', () {
    test('keys every step it prescribes', () {
      for (final builtin in builtinTrainings) {
        final training = builtin.generateNewFormatTraining(maxForce());
        expect(
          training,
          isNotNull,
          reason: '${builtin.name} generated nothing',
        );
        expect(
          training!.items,
          isNotEmpty,
          reason: '${builtin.name} prescribes nothing',
        );

        for (final item in training.items) {
          expect(
            item.reportKey,
            isNotEmpty,
            reason: '${builtin.name} step ${item.position} has no report key',
          );
          // Keyed, and still stored nowhere: an insert and the backend both
          // read the blank id as "this row does not exist yet".
          expect(
            item.id,
            isEmpty,
            reason: '${builtin.name} step ${item.position} claims a row',
          );
        }
      }
    });

    test('gives each step a key of its own', () {
      for (final builtin in builtinTrainings) {
        final items = builtin.generateNewFormatTraining(maxForce())!.items;
        final keys = items.map((i) => i.reportKey).toSet();

        expect(
          keys,
          hasLength(items.length),
          reason: '${builtin.name} reuses a key across its steps',
        );
      }
    });

    // A report is written on one run and read back on another, so the same
    // step has to answer to the same name every time it is generated.
    test('mints the same keys on every generation', () {
      for (final builtin in builtinTrainings) {
        final first = builtin.generateNewFormatTraining(maxForce())!.items;
        final second = builtin.generateNewFormatTraining(maxForce())!.items;

        expect(
          second.map((i) => i.reportKey),
          first.map((i) => i.reportKey),
          reason: '${builtin.name} renames its steps between generations',
        );
      }
    });

    // The keying half of #110: every generated step can be named by a report.
    // Whether one is collected is a separate question, and today it is not:
    // a builtin run names no prescription, so there is nowhere to store it.
    test('can be named by a report, a line per step', () {
      for (final builtin in builtinTrainings) {
        final items = builtin.generateNewFormatTraining(maxForce())!.items;

        expect(
          items.every(isReportable),
          isTrue,
          reason: '${builtin.name} has steps no report can name',
        );
        expect(
          reviewLines(items, const []),
          hasLength(items.length),
          reason: '${builtin.name} offers no line for some of its steps',
        );
      }
    });

    test('names its steps by a key the upload paths can spot', () {
      final items = builtinTrainings.first
          .generateNewFormatTraining(maxForce())!
          .items;

      expect(items.every((i) => isBuiltinItemKey(i.reportKey)), isTrue);
      expect(isBuiltinItemKey('7f1c9b1e-0000-4000-8000-000000000000'), isFalse);
    });
  });

  group('builtinItemKey', () {
    test('tells a nested step from the one beside it', () {
      expect(builtinItemKey('mvc', [1]), isNot(builtinItemKey('mvc', [1, 0])));
    });

    test('tells the same position of two builtins apart', () {
      expect(builtinItemKey('mvc', [0]), isNot(builtinItemKey('cf', [0])));
    });
  });
}
