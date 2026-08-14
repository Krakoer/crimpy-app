import 'package:crimpy/views/screens/trainings/training_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The repeater editor holds one configuration row per rep, so the count fields
/// resize the grid and the row fields have to keep showing what is in it. Only
/// saving touches a provider, so the screen pumps without any database.
void main() {
  // The editor is a tall scrolling form and its list only builds what fits, so
  // the surface is made large enough to hold every row at once.
  Future<void> pumpEditor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 12000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: UnifiedTrainingCreationScreen(
            mode: TrainingCreationMode.repeater,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder fieldWithLabel(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(TextFormField));

  Finder edgeFields() => fieldWithLabel('Edge (mm)');

  // Read what the field actually displays, not what the model holds: the whole
  // point of these tests is that the two can disagree.
  String textOf(WidgetTester tester, Finder field) => tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .controller
      .text;

  Future<void> showPerRepRows(WidgetTester tester) async {
    await tester.tap(find.text('Vary per rep'));
    await tester.pumpAndSettle();
  }

  group('repeater editor row counts', () {
    // Retyping 6 as 12 goes through 1. Resampling on that intermediate value
    // collapsed every row into one and re-expanded it, losing what was typed.
    testWidgets('keeps the per-rep rows while a count is being retyped', (
      tester,
    ) async {
      await pumpEditor(tester);
      await showPerRepRows(tester);

      expect(edgeFields(), findsNWidgets(6));
      await tester.enterText(edgeFields().at(0), '25');
      await tester.enterText(edgeFields().at(1), '24');
      await tester.enterText(edgeFields().at(2), '23');
      await tester.pumpAndSettle();

      final reps = fieldWithLabel('Reps / set');
      await tester.enterText(reps, '1');
      await tester.pumpAndSettle();
      expect(
        edgeFields(),
        findsNWidgets(6),
        reason: 'an intermediate count must not resize the grid',
      );

      await tester.enterText(reps, '12');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(edgeFields(), findsNWidgets(12));
      expect(textOf(tester, edgeFields().at(0)), '25');
      expect(textOf(tester, edgeFields().at(1)), '24');
      expect(textOf(tester, edgeFields().at(2)), '23');
    });

    // A TextFormField seeds its controller from initialValue once, so a row
    // whose value moved under it kept showing the old number and saved another.
    testWidgets('shows the resampled values after the grid shrinks', (
      tester,
    ) async {
      await pumpEditor(tester);
      await showPerRepRows(tester);

      await tester.enterText(edgeFields().at(0), '25');
      await tester.enterText(edgeFields().at(1), '24');
      await tester.pumpAndSettle();

      final reps = fieldWithLabel('Reps / set');
      await tester.enterText(reps, '2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(edgeFields(), findsNWidgets(2));
      expect(textOf(tester, edgeFields().at(0)), '25');
      expect(textOf(tester, edgeFields().at(1)), '24');
    });

    // Copying a row rewrites the rows below it, which the fields showing those
    // rows have to follow.
    testWidgets('shows the copied values in the rows below', (tester) async {
      await pumpEditor(tester);
      await showPerRepRows(tester);

      await tester.enterText(edgeFields().at(0), '25');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Copy to the rows below').first);
      await tester.pumpAndSettle();

      expect(textOf(tester, edgeFields().at(1)), '25');
      expect(textOf(tester, edgeFields().at(5)), '25');
    });
  });

  group('manual editor tree', () {
    Future<void> pumpManualEditor(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 12000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UnifiedTrainingCreationScreen(
              mode: TrainingCreationMode.manual,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Adds an item of the named type through the add sheet and accepts its
    /// editor with the defaults.
    Future<void> addItem(WidgetTester tester, String type, Finder add) async {
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.tap(find.text(type));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    /// Picks an action out of an item card's overflow menu.
    Future<void> itemAction(WidgetTester tester, String action) async {
      await tester.tap(find.byTooltip('Actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
    }

    testWidgets('adds a titled circuit holding a hang rep', (tester) async {
      await pumpManualEditor(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Circuit'));
      await tester.pumpAndSettle();

      await tester.enterText(fieldWithLabel('Title (optional)'), 'Pull block');
      await tester.enterText(fieldWithLabel('Rest between items (s)'), '15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Pull block'), findsOneWidget);
      expect(
        find.text('3 cycles - 15s between items - 120s between cycles'),
        findsOneWidget,
      );

      // A circuit only takes hang reps, so its sheet offers that one option.
      await addItem(tester, 'Hang rep', find.text('Add item'));
      expect(find.text('Hang rep'), findsOneWidget);
    });

    testWidgets('duplicates an item next to the one it was copied from', (
      tester,
    ) async {
      await pumpManualEditor(tester);
      await addItem(tester, 'Hang rep', find.byType(FloatingActionButton));
      expect(find.text('Hang rep'), findsOneWidget);

      await itemAction(tester, 'Duplicate');

      expect(find.text('Hang rep'), findsNWidgets(2));
    });

    testWidgets('deleting a container asks before taking its children', (
      tester,
    ) async {
      await pumpManualEditor(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Group'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await addItem(tester, 'Hang rep', find.text('Add item'));

      await itemAction(tester, 'Delete');
      expect(
        find.text('The 1 item(s) it holds are deleted with it.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Group'), findsOneWidget);

      await itemAction(tester, 'Delete');
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.text('Group'), findsNothing);
    });

    testWidgets('a cleared number keeps the dialog open instead of reverting', (
      tester,
    ) async {
      await pumpManualEditor(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Circuit'));
      await tester.pumpAndSettle();

      await tester.enterText(fieldWithLabel('Rest between cycles (s)'), '');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The dialog stays up on its error rather than saving the old 120 behind
      // a field reading empty.
      expect(find.text('Enter a number'), findsOneWidget);
      expect(find.text('Circuit'), findsOneWidget);

      await tester.enterText(fieldWithLabel('Rest between cycles (s)'), '60');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('3 cycles - 60s between cycles'), findsOneWidget);
    });

    // The numbers a circuit carries are the point of its card, so they have to
    // survive the width of a real phone rather than only the wide test surface.
    testWidgets('a circuit shows its rests in full at phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UnifiedTrainingCreationScreen(
              mode: TrainingCreationMode.manual,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Circuit'));
      await tester.pumpAndSettle();
      await tester.enterText(fieldWithLabel('Rest between items (s)'), '15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The row of buttons this card used to carry left the text about 100dp
      // of a 360dp screen. The width it gets is what the assertion guards; the
      // line count cannot be, since the test font is far wider than a real one.
      const detail = '3 cycles - 15s between items - 120s between cycles';
      final paragraph = tester.renderObject<RenderParagraph>(find.text(detail));
      expect(paragraph.size.width, greaterThan(180));
    });

    testWidgets('a group takes circuits and reps, a circuit only reps', (
      tester,
    ) async {
      // The option subtitles name what is on offer without colliding with the
      // titles of the cards already on screen.
      const rep = 'A single hang';
      const cycle = 'Repeat a set of items several times';
      const group = 'Gather items under a title';

      await pumpManualEditor(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(group));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      expect(find.text(rep), findsOneWidget);
      expect(find.text(cycle), findsOneWidget);
      expect(find.text(group), findsNothing);

      await tester.tap(find.text(cycle));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // A container renders its children above its own add button, so the
      // nested circuit's button comes first.
      await tester.tap(find.text('Add item').first);
      await tester.pumpAndSettle();
      expect(find.text(rep), findsOneWidget);
      expect(find.text(cycle), findsNothing);
    });
  });
}
