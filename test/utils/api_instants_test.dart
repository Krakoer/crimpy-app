import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// Every assertion here is written against the instant rather than the wall
// clock, because the machine running the suite decides what local means. What
// is being checked is that the zone was dropped at the boundary, not that it
// was dropped by any particular number of hours.
void main() {
  final instant = DateTime.utc(2026, 8, 27, 9, 12, 3);

  group('an instant the API sends', () {
    test('is read as the local time it happened at', () {
      final parsed = parseApiInstant('2026-08-27T09:12:03Z');

      expect(parsed.isUtc, false);
      expect(parsed.isAtSameMomentAs(instant), true);
    });

    test('keeps the offset when the API spells one out', () {
      final parsed = parseApiInstant('2026-08-27T11:12:03+02:00');

      expect(parsed.isUtc, false);
      expect(parsed.isAtSameMomentAs(instant), true);
    });

    test('is null rather than a throw when it is absent or malformed', () {
      expect(tryParseApiInstant(null), isNull);
      expect(tryParseApiInstant('not a date'), isNull);
      expect(
        tryParseApiInstant('2026-08-27T09:12:03Z')!.isAtSameMomentAs(instant),
        true,
      );
    });
  });

  group('a session read back off the API', () {
    SessionModel parse(String date) => SessionModel.fromJson({
      'id': 'session-1',
      'name': 'Critical force',
      'date': date,
      'origin': 'played',
    });

    test('is dated at the local time it was recorded at', () {
      final session = parse('2026-08-27T09:12:03Z');

      expect(session.date.isUtc, false);
      expect(session.date.isAtSameMomentAs(instant), true);
    });

    // The overview card and the raw data card below it read the same session,
    // one off the date and one off the curve, so a conversion applied to one
    // and not the other puts the two halves of the screen hours apart. This is
    // how the remote repository assembles them.
    test('starts its curve at the instant the session is dated', () {
      const samples = {
        't0': '2026-08-27T09:12:03Z',
        'ms': [0, 125],
        'kg': [12.5, 13.0],
      };
      final session = SessionModel.fromJson({
        'id': 'session-1',
        'name': 'Critical force',
        'date': '2026-08-27T09:12:03Z',
        'origin': 'played',
        'samples': samples,
      }, dataPoints: ForceCurve.fromJson(samples));

      final firstPoint = session.dataPoints!.first.timestamp;
      expect(firstPoint.isUtc, false);
      expect(firstPoint.isAtSameMomentAs(session.date), true);
      expect(
        DateFormat('HH:mm').format(session.date),
        DateFormat('HH:mm').format(firstPoint),
      );
    });
  });

  group('a program read back off the API', () {
    Program parse() => Program.fromJson({
      'id': 'program-1',
      'coach_id': 'coach-1',
      'user_id': 'user-1',
      'name': 'Base',
      'start_date': '2026-08-31',
      'created_at': '2026-08-27T09:12:03Z',
      'updated_at': '2026-08-27T09:12:03Z',
    });

    test('carries its timestamps as local instants', () {
      final program = parse();

      expect(program.createdAt.isUtc, false);
      expect(program.createdAt.isAtSameMomentAs(instant), true);
      expect(program.updatedAt.isAtSameMomentAs(instant), true);
    });

    // A start date is a calendar date with no zone to convert from. Running it
    // through the instant boundary would move it a day west of UTC, and the
    // week arithmetic hangs off it.
    test('keeps its start date on the day the API named', () {
      final startDate = parse().startDate;

      expect(startDate.year, 2026);
      expect(startDate.month, 8);
      expect(startDate.day, 31);
    });

    // The cache writes a program back out through toJson and reads it in again
    // through fromJson, so the two have to agree on the shape. The API is the
    // stricter of the two readers: it rejects a start date that is not
    // YYYY-MM-DD outright.
    test('writes its start date back in the shape the API takes', () {
      expect(parse().toJson()['start_date'], '2026-08-31');
    });

    test('survives the round trip through the cache', () {
      final cached = Program.fromJson(parse().toJson());

      expect(cached.startDate, parse().startDate);
      expect(cached.createdAt.isAtSameMomentAs(instant), true);
      expect(cached.updatedAt.isAtSameMomentAs(instant), true);
    });
  });
}
