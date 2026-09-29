import 'dart:math' as math;

import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/consistency.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/consistency_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/session_history_screen/session_history_screen.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The last two weeks of the plan, one mark per day, on the home screen.
///
/// No streak, no score, no badge and no "11 of 14" in the header: the strip is
/// the summary, and a count is the first step towards a streak. The aggregate
/// exists only in what a screen reader says, phrased as a description. A missed
/// day is a hollow circle, never a red cross, and a day before the plan is a
/// hairline, since nobody failed a day they had no plan for. Tapping it opens
/// the history. See Krakoer/crimpy#154.
class ConsistencyStripCard extends ConsumerWidget {
  const ConsistencyStripCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read off what the state holds, so a pull keeps the strip on screen
    // rather than dropping it for the length of the fetch.
    final days = ref.watch(programConsistencyProvider).value;
    if (days == null || days.isEmpty) return const SizedBox.shrink();
    return ConsistencyStrip(
      days: days,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SessionHistoryScreen())),
    );
  }
}

/// The card itself, from the days it draws.
class ConsistencyStrip extends StatelessWidget {
  final List<ConsistencyDay> days;
  final VoidCallback? onTap;

  const ConsistencyStrip({required this.days, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final axis = CrimpyTheme.labelSmall.copyWith(
      color: CrimpyTheme.textSecondary,
    );
    return HomeCard(
      title: 'Last 14 days',
      onTap: onTap,
      raised: false,
      child: Column(
        children: [
          // One element for the whole strip: fourteen focusable marks would be
          // fourteen swipes to get past it. The card's heading names it.
          Semantics(
            value: describeConsistency(days),
            hint: 'Opens the history',
            button: onTap != null,
            excludeSemantics: true,
            child: CustomPaint(
              size: const Size.fromHeight(_ConsistencyPainter.height),
              painter: _ConsistencyPainter(days),
            ),
          ),
          const SizedBox(height: CrimpyTheme.spaceXs),
          ExcludeSemantics(
            child: Row(
              children: [
                Text(formatDayMonth(days.first.day), style: axis),
                const Spacer(),
                Text('TODAY', style: axis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the marks, oldest on the left, in cells of equal width so the strip
/// fits any screen without a pitch of its own.
class _ConsistencyPainter extends CustomPainter {
  final List<ConsistencyDay> days;

  _ConsistencyPainter(this.days);

  /// The mark plus the room under it for today's tick.
  static const double height = 24;
  static const double _maxMark = 16;
  static const double _stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / days.length;
    final mark = math.min(_maxMark, cell - 4);
    final radius = mark / 2;
    for (var index = 0; index < days.length; index++) {
      final center = Offset(cell * index + cell / 2, radius + 1);
      _paintMark(canvas, center, radius, days[index]);
      if (index == days.length - 1) _paintTodayTick(canvas, center, radius);
    }
  }

  void _paintMark(
    Canvas canvas,
    Offset center,
    double radius,
    ConsistencyDay day,
  ) {
    final kept = Paint()..color = CrimpyTheme.dayKept;
    final owed = Paint()
      ..color = CrimpyTheme.dayOwed
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    switch (day.mark) {
      case ConsistencyMark.beforePlan:
        canvas.drawLine(
          center.translate(-radius, 0),
          center.translate(radius, 0),
          Paint()
            ..color = CrimpyTheme.dayUntracked
            ..strokeWidth = _stroke,
        );
      case ConsistencyMark.rest:
        canvas.drawCircle(
          center,
          radius / 4,
          Paint()..color = CrimpyTheme.dayOwed,
        );
      case ConsistencyMark.missed:
        canvas.drawCircle(center, radius - _stroke / 2, owed);
      case ConsistencyMark.partial:
        final disc = Rect.fromCircle(center: center, radius: radius);
        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(
            disc.left,
            disc.top,
            disc.width * day.fraction,
            disc.height,
          ),
        );
        canvas.drawCircle(center, radius, kept);
        canvas.restore();
        canvas.drawCircle(center, radius - _stroke / 2, owed);
      case ConsistencyMark.kept:
        canvas.drawCircle(center, radius, kept);
      case ConsistencyMark.climbed:
        // A full disc with a peak cut out of it: a whole day, not a hangboard
        // one.
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = CrimpyTheme.activityColor(SessionActivity.climbing),
        );
        final peak = Path()
          ..moveTo(center.dx - radius * 0.55, center.dy + radius * 0.35)
          ..lineTo(center.dx, center.dy - radius * 0.45)
          ..lineTo(center.dx + radius * 0.55, center.dy + radius * 0.35)
          ..close();
        canvas.drawPath(peak, Paint()..color = CrimpyTheme.bgPrimary);
      case ConsistencyMark.assessed:
        // A full disc bored through the middle, the way a test reads elsewhere.
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = CrimpyTheme.assessmentColor,
        );
        canvas.drawCircle(
          center,
          radius * 0.38,
          Paint()..color = CrimpyTheme.bgPrimary,
        );
    }
  }

  /// An under-tick rather than a ring: at 8 in the morning, nothing done yet
  /// today is not a failure, and a ring would read as one being pointed at.
  void _paintTodayTick(Canvas canvas, Offset center, double radius) {
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius + 4),
      Offset(center.dx + radius, center.dy + radius + 4),
      Paint()
        ..color = CrimpyTheme.current
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_ConsistencyPainter old) => old.days != days;
}
