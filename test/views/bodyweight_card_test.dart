import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/bodyweight_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubBodyweight extends BodyweightController {
  _StubBodyweight(this._stored);

  final double? _stored;

  @override
  Future<double?> build() async => _stored;
}

Future<void> _pump(
  WidgetTester tester, {
  required double? weight,
  required bool pending,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bodyweightProvider.overrideWith(() => _StubBodyweight(weight)),
        bodyweightPendingProvider.overrideWith((ref) async => pending),
      ],
      child: const MaterialApp(home: Scaffold(body: BodyweightCard())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // The card is the only place an athlete learns their coach has not got the
  // weight yet, since the run works either way and nothing else says so.
  testWidgets('says when a weight has not reached Crimpy', (tester) async {
    await _pump(tester, weight: 71.4, pending: true);

    expect(find.text('71.4 kg'), findsOneWidget);
    expect(find.textContaining('Your coach will see it'), findsOneWidget);
  });

  testWidgets('says nothing once the weight is filed', (tester) async {
    await _pump(tester, weight: 71.4, pending: false);

    expect(find.text('71.4 kg'), findsOneWidget);
    expect(find.textContaining('Your coach will see it'), findsNothing);
  });

  // Nothing to be waiting for, so nothing to say about waiting.
  testWidgets('says nothing about sending when there is no weight', (
    tester,
  ) async {
    await _pump(tester, weight: null, pending: true);

    expect(find.textContaining('Your coach will see it'), findsNothing);
  });
}
