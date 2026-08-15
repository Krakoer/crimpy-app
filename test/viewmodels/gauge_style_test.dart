import 'package:crimpy/models/gauge_style.dart';
import 'package:crimpy/services/gauge_style_service.dart';
import 'package:crimpy/viewmodels/gauge_style_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('gauge style', () {
    test('a device that never picked one runs the fallback design', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer.test();

      expect(
        await container.read(gaugeStyleProvider.future),
        GaugeStyle.fallback,
      );
    });

    test('the picked design is kept on the device', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer.test();
      await container.read(gaugeStyleProvider.future);

      await container.read(gaugeStyleProvider.notifier).set(GaugeStyle.circle);

      expect(container.read(gaugeStyleProvider).value, GaugeStyle.circle);
      expect(await GaugeStyleService().load(), GaugeStyle.circle);
    });

    test('a stored design is read back on the next launch', () async {
      SharedPreferences.setMockInitialValues({'gauge_style': 'circle'});
      final container = ProviderContainer.test();

      expect(
        await container.read(gaugeStyleProvider.future),
        GaugeStyle.circle,
      );
    });

    test(
      'a design that no longer exists falls back instead of failing',
      () async {
        // Designs are being tried out, so a name stored by an older build is not
        // guaranteed to still name one.
        SharedPreferences.setMockInitialValues({
          'gauge_style': 'dropped_design',
        });
        final container = ProviderContainer.test();

        expect(
          await container.read(gaugeStyleProvider.future),
          GaugeStyle.fallback,
        );
      },
    );
  });
}
