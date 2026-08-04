import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'date_filter_banner.dart';
import 'session_data_source.dart';

class CalendarCard extends StatelessWidget {
  final List<SessionModel> sessions;
  final CalendarController calendarController;
  final DateTime? selectedDate;
  final VoidCallback onClearFilter;
  final Function(DateTime?) onDateTap;

  const CalendarCard({
    super.key,
    required this.sessions,
    required this.calendarController,
    required this.selectedDate,
    required this.onClearFilter,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          if (selectedDate != null)
            DateFilterBanner(
              selectedDate: selectedDate!,
              onClearFilter: onClearFilter,
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SfCalendar(
              firstDayOfWeek: DateTime.monday,
              view: CalendarView.month,
              controller: calendarController,
              dataSource: SessionDataSource(sessions),
              initialSelectedDate: selectedDate,
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                showAgenda: false,
              ),
              headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              todayHighlightColor: CrimpyTheme.primaryOrange,
              selectionDecoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: CrimpyTheme.primaryOrange, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell &&
                    details.date != null) {
                  // Toggle: if same date is tapped, clear filter
                  if (selectedDate != null &&
                      DateUtils.isSameDay(selectedDate, details.date)) {
                    onDateTap(null);
                  } else {
                    onDateTap(details.date);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
