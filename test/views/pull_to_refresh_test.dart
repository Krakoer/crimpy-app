import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// How many times the provider below has been asked, so a test can say whether
/// a pull actually fetched again rather than only moving the spinner.
int _asked = 0;

final _items = FutureProvider<List<String>>((ref) async {
  _asked++;
  return ['first', 'second'];
});

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

/// The gesture a pull is: down from the top, far enough to pass the trigger.
Future<void> _pullDown(WidgetTester tester) async {
  await tester.fling(find.byType(Scrollable), const Offset(0, 400), 1000);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => _asked = 0);

  testWidgets('a pull asks the provider again', (tester) async {
    await _pump(
      tester,
      Consumer(
        builder: (context, ref, _) {
          final list = ref.watch(_items);
          return PullToRefresh(
            onRefresh: () => ref.refresh(_items.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                for (final item in list.value ?? const <String>[]) Text(item),
              ],
            ),
          );
        },
      ),
    );

    expect(_asked, 1);
    expect(find.text('first'), findsOneWidget);

    await _pullDown(tester);

    expect(_asked, 2);
  });

  // The failure this is here to catch: matching AsyncData rather than a held
  // value swaps the list for a spinner the moment the pull starts, so the
  // athlete watches their own data disappear while asking for more of it.
  testWidgets('a pull leaves what is on screen there', (tester) async {
    await _pump(
      tester,
      Consumer(
        builder: (context, ref, _) {
          final list = ref.watch(_items);
          return PullToRefresh(
            onRefresh: () => ref.refresh(_items.future),
            child: switch (list) {
              AsyncValue(:final value?) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [for (final item in value) Text(item)],
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          );
        },
      ),
    );

    expect(find.text('first'), findsOneWidget);

    await tester.fling(find.byType(Scrollable), const Offset(0, 400), 1000);
    await tester.pump();

    // Mid refresh: the list is still readable rather than replaced.
    expect(find.text('first'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
  });

  group('RefreshableColumn', () {
    // An empty history is the state a pull is most worth making, and a column
    // that fits on screen sends no scroll notification for the indicator.
    testWidgets('scrolls although its child fits', (tester) async {
      await _pump(
        tester,
        const RefreshableColumn(child: Text('Nothing logged yet')),
      );

      final scrollable = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollable.physics, isA<AlwaysScrollableScrollPhysics>());
    });

    testWidgets('can be pulled when it holds nothing worth scrolling', (
      tester,
    ) async {
      var refreshed = false;

      await _pump(
        tester,
        PullToRefresh(
          onRefresh: () async => refreshed = true,
          child: const RefreshableColumn(child: Text('Nothing logged yet')),
        ),
      );

      await _pullDown(tester);

      expect(refreshed, isTrue);
    });
  });
}
