import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/services/run_screen_style_service.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('run screen style', () {
    test('a device that never picked one runs the fallback design', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer.test();

      expect(
        await container.read(runScreenStyleProvider.future),
        RunScreenStyle.fallback,
      );
    });

    test('the picked design is kept on the device', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer.test();
      await container.read(runScreenStyleProvider.future);

      await container
          .read(runScreenStyleProvider.notifier)
          .set(RunScreenStyle.ringAndTank);

      expect(
        container.read(runScreenStyleProvider).value,
        RunScreenStyle.ringAndTank,
      );
      expect(await RunScreenStyleService().load(), RunScreenStyle.ringAndTank);
    });

    test('a stored design is read back on the next launch', () async {
      SharedPreferences.setMockInitialValues({
        'run_screen_style': 'ring_and_tank',
      });
      final container = ProviderContainer.test();

      expect(
        await container.read(runScreenStyleProvider.future),
        RunScreenStyle.ringAndTank,
      );
    });

    test(
      'a design that no longer exists falls back instead of failing',
      () async {
        // Designs are being tried out, so a name stored by an older build is
        // not guaranteed to still name one.
        SharedPreferences.setMockInitialValues({
          'run_screen_style': 'dropped_design',
        });
        final container = ProviderContainer.test();

        expect(
          await container.read(runScreenStyleProvider.future),
          RunScreenStyle.fallback,
        );
      },
    );
  });
}
