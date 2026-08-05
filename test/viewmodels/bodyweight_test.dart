import 'package:crimpy/services/bodyweight_service.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bodyweight', () {
    test('is unknown until it is entered', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer.test();

      expect(await container.read(bodyweightProvider.future), isNull);
    });

    test('a saved weight is kept on the device', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer.test();
      await container.read(bodyweightProvider.future);

      await container.read(bodyweightProvider.notifier).set(68.5);

      expect(container.read(bodyweightProvider).value, 68.5);
      expect(await BodyweightService().load(), 68.5);
    });

    test('a stored weight is read back on the next launch', () async {
      SharedPreferences.setMockInitialValues({'bodyweight_kg': 72.0});
      final container = ProviderContainer.test();

      expect(await container.read(bodyweightProvider.future), 72.0);
    });
  });
}
