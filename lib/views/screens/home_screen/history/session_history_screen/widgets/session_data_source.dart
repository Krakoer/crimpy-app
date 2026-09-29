import 'package:crimpy/models/session.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// Data source for Syncfusion calendar to display session appointments
class SessionDataSource extends CalendarDataSource {
  SessionDataSource(List<SessionModel> sessions) {
    appointments = sessions.map((session) {
      // Marked on the day the list files it under, so tapping the day with the
      // mark filters to the session rather than to nothing. The month view
      // shows a mark per day and no time, so the time of day is not lost.
      final start = session.trainingDay;
      return Appointment(
        startTime: start,
        endTime: start.add(Duration(seconds: session.duration)),
        subject: session.name,
        color: CrimpyTheme.activityColor(session.activity),
        id: session.id,
      );
    }).toList();
  }
}
