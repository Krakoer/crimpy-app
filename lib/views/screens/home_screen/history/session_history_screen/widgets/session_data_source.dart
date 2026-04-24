import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Data source for Syncfusion calendar to display session appointments
class SessionDataSource extends CalendarDataSource {
  SessionDataSource(List<SessionModel> sessions) {
    appointments = sessions.map((session) {
      return Appointment(
        startTime: session.date,
        endTime: session.date.add(Duration(seconds: session.duration)),
        subject: session.name,
        color: Color(session.sessionType.colorValue),
        id: session.id,
      );
    }).toList();
  }
}
