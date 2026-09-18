import 'package:crimpy/services/bodyweight_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('bodyweight service pending slot', () {
    test('a measurement is read back as it was written', () async {
      final service = BodyweightService();
      final monday = DateTime.utc(2026, 9, 14, 7, 30);

      await service.markPending(68.5, monday);
      final stored = await service.pending();

      expect(stored, isNotNull);
      expect(stored!.weightKg, 68.5);
      expect(stored.measuredAt.isAtSameMomentAs(monday), isTrue);
    });

    // The weight and the date lived under two keys, written across an await.
    // A read landing between them saw the new weight under the previous
    // measurement's date, and the flush loop filed that pair: a weight the
    // athlete never had on that day, in the series the coach reads ratios
    // against.
    test(
      'a read during a write never sees a weight under the wrong date',
      () async {
        final service = BodyweightService();
        final monday = DateTime.utc(2026, 9, 14, 7, 30);
        final wednesday = DateTime.utc(2026, 9, 16, 7, 30);
        await service.markPending(68.5, monday);

        final writing = service.markPending(78.5, wednesday);
        final duringWrite = await service.pending();
        await writing;

        expect(duringWrite, isNotNull);
        final pair = (duringWrite!.weightKg, duringWrite.measuredAt);
        expect(
          pair == (68.5, monday) || pair == (78.5, wednesday),
          isTrue,
          reason:
              'Read a torn slot: ${duringWrite.weightKg} kg '
              'measured ${duringWrite.measuredAt}',
        );
      },
    );

    test(
      'a slot holding nonsense reads as empty rather than throwing',
      () async {
        SharedPreferences.setMockInitialValues({
          'bodyweight_pending': 'not json',
        });

        expect(await BodyweightService().pending(), isNull);
      },
    );

    test('clearing removes the whole slot', () async {
      final service = BodyweightService();
      await service.markPending(68.5, DateTime.utc(2026, 9, 14));

      await service.clearPending();

      expect(await service.pending(), isNull);
    });
  });
}
