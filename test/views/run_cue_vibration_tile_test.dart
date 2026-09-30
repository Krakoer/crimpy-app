// ignore_for_file: scoped_providers_should_specify_dependencies
// A test container is the root container. The rule is about a scope nested
// under another one, where an override the parent cannot see is a bug.

import 'package:crimpy/repositories/run_cue_preferences_repository.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/run_cue_vibration_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the settings switch turns the vibration off', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: RunCueVibrationTile())),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(await SharedPreferencesRunCuePreferences().vibrates(), isFalse);
  });
}
