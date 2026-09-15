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

  // Round 1 caught every screen refreshing the provider it reads rather than
  // the one that fetches. Riverpod invalidates a provider alone and never what
  // it was derived from, so the derived one recomputes against the answer
  // already cached and the pull comes back with what was already on screen.
  testWidgets('a pull asks the provider that does the fetching', (
    tester,
  ) async {
    final filtered = FutureProvider<List<String>>(
      (ref) async => (await ref.watch(_items.future)).take(1).toList(),
    );

    await _pump(
      tester,
      Consumer(
        builder: (context, ref, _) {
          final list = ref.watch(filtered);
          return PullToRefresh(
            onRefresh: () async {
              ref.invalidate(_items);
              await ref.read(filtered.future);
            },
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

    await _pullDown(tester);

    // Two would mean only the derived provider recomputed.
    expect(_asked, 2);
  });

  // Round 2 caught the cards below the converted screens still reading through
  // AsyncData, asData and when(). A provider rebuilt because a dependency was
  // invalidated is a reload, so all three lose the value it is still carrying
  // and the card blanks itself for as long as the pull runs.
  group('a card whose provider is reloading', () {
    testWidgets('keeps what it holds when matched on the value', (
      tester,
    ) async {
      final derived = FutureProvider<String>(
        (ref) async => (await ref.watch(_items.future)).first,
      );
      late WidgetRef captured;

      await _pump(
        tester,
        Consumer(
          builder: (context, ref, _) {
            captured = ref;
            final held = ref.watch(derived);
            return switch (held) {
              AsyncValue(:final value?) => Text(value),
              _ => const Text('BLANK'),
            };
          },
        ),
      );

      expect(find.text('first'), findsOneWidget);

      captured.invalidate(_items);
      await tester.pump();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('BLANK'), findsNothing);
    });

    testWidgets('keeps what it holds when when() skips a reload', (
      tester,
    ) async {
      final derived = FutureProvider<String>(
        (ref) async => (await ref.watch(_items.future)).first,
      );
      late WidgetRef captured;

      await _pump(
        tester,
        Consumer(
          builder: (context, ref, _) {
            captured = ref;
            return ref
                .watch(derived)
                .when(
                  skipLoadingOnReload: true,
                  loading: () => const Text('BLANK'),
                  error: (_, _) => const Text('BLANK'),
                  data: Text.new,
                );
          },
        ),
      );

      expect(find.text('first'), findsOneWidget);

      captured.invalidate(_items);
      await tester.pump();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('BLANK'), findsNothing);
    });
  });

  group('a refresh that fails', () {
    // RefreshIndicator drops the future it is handed, so an onRefresh that
    // throws used to become an uncaught async error: one Sentry report per
    // pull, and nothing at all said to the athlete.
    testWidgets('says so rather than throwing into the framework', (
      tester,
    ) async {
      await _pump(
        tester,
        PullToRefresh(
          onRefresh: () async => throw StateError('no connection'),
          child: const RefreshableColumn(child: Text('Nothing logged yet')),
        ),
      );

      await _pullDown(tester);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Could not refresh'), findsOneWidget);
    });

    testWidgets('leaves what was on screen alone', (tester) async {
      await _pump(
        tester,
        PullToRefresh(
          onRefresh: () async => throw StateError('no connection'),
          child: const RefreshableColumn(child: Text('Nothing logged yet')),
        ),
      );

      await _pullDown(tester);

      expect(find.text('Nothing logged yet'), findsOneWidget);
    });
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

    // The padding sits outside the constrained child, so leaving it out of the
    // minimum made every padded column taller than the viewport by exactly the
    // padding, and the screen dragged up onto blank space.
    testWidgets('does not scroll by its own padding alone', (tester) async {
      await _pump(
        tester,
        const RefreshableColumn(
          padding: EdgeInsets.all(16),
          child: Text('Nothing logged yet'),
        ),
      );

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.maxScrollExtent, 0);
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
