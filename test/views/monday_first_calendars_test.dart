import 'package:crimpy/utils/monday_first_localizations.dart';
import 'package:crimpy/views/screens/home_screen/history/session_history_screen/widgets/calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Weeks open on Monday in every calendar the app draws, whatever the device's
// locale. en_US is the case that matters: its weeks start on Sunday, and the
// Material date picker follows the localizations it is handed.
const _usEnglish = Locale('en', 'US');

/// Sunday 4 October 2026. The month opens on a Thursday, so the 5th is a
/// Monday and the 4th the Sunday before it.
final _shownDay = DateTime(2026, 10, 4);

Future<void> _pumpPicker(
  WidgetTester tester, {
  List<LocalizationsDelegate<dynamic>>? delegates,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: _usEnglish,
      localizationsDelegates: delegates,
      home: Scaffold(
        body: CalendarDatePicker(
          initialDate: _shownDay,
          firstDate: DateTime(2026),
          lastDate: DateTime(2027),
          onDateChanged: (_) {},
        ),
      ),
    ),
  );
}

double _columnOf(WidgetTester tester, String text) =>
    tester.getCenter(find.text(text).first).dx;

void main() {
  testWidgets('the Material picker alone starts an en_US week on Sunday', (
    tester,
  ) async {
    await _pumpPicker(tester);

    final context = tester.element(find.byType(CalendarDatePicker));
    expect(MaterialLocalizations.of(context).firstDayOfWeekIndex, 0);
    expect(_columnOf(tester, '4'), lessThan(_columnOf(tester, '5')));
  });

  testWidgets('with the app localizations an en_US week starts on Monday', (
    tester,
  ) async {
    await _pumpPicker(tester, delegates: crimpyLocalizationsDelegates);

    final context = tester.element(find.byType(CalendarDatePicker));
    expect(MaterialLocalizations.of(context).firstDayOfWeekIndex, 1);
    // Monday the 5th sits under the first column heading, M, and Sunday the
    // 4th closes the row before it rather than opening this one.
    expect(_columnOf(tester, '5'), _columnOf(tester, 'M'));
    expect(_columnOf(tester, '4'), greaterThan(_columnOf(tester, '5')));
    expect(_columnOf(tester, '11'), _columnOf(tester, '4'));
  });

  testWidgets('a British English device starts the week on Monday too', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'GB'),
        localizationsDelegates: crimpyLocalizationsDelegates,
        home: const SizedBox(),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    expect(MaterialLocalizations.of(context).firstDayOfWeekIndex, 1);
  });

  testWidgets('the session history calendar starts the week on Monday', (
    tester,
  ) async {
    final controller = CalendarController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        locale: _usEnglish,
        localizationsDelegates: crimpyLocalizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CalendarCard(
              sessions: const [],
              calendarController: controller,
              selectedDate: null,
              onClearFilter: () {},
              onDateTap: (_) {},
            ),
          ),
        ),
      ),
    );

    final calendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    expect(calendar.firstDayOfWeek, DateTime.monday);
  });
}
