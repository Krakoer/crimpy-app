import 'package:crimpy/models/session.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

/// Data source for Syncfusion calendar to display session appointments
class SessionDataSource extends CalendarDataSource {
  SessionDataSource(List<SessionModel> sessions) {
    appointments = sessions.map((session) {
      return Appointment(
        startTime: session.date,
        endTime: session.date.add(Duration(seconds: session.duration)),
        subject: session.name,
        color: CrimpyTheme.activityColor(session.activity),
        id: session.id,
      );
    }).toList();
  }
}
