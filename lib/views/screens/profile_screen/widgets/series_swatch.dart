import 'package:flutter/material.dart';

/// The line style an assessment chart draws a hand in. The hands of one metric
/// share its hue and are told apart by this, so a stat card and the chart under
/// it agree on which is which. See Krakoer/crimpy#164.
enum SeriesStroke {
  /// The left hand, or the one series of a single value assessment.
  solid,

  /// The right hand.
  dashed;

  /// The dash pattern a chart draws this stroke with, null for a solid line.
  List<double>? get chartDashArray => switch (this) {
    SeriesStroke.solid => null,
    SeriesStroke.dashed => const [6, 4],
  };
}

/// A short stroke in a series' hue and line style, under a stat card's label,
/// which is the legend of the chart below it.
class SeriesSwatch extends StatelessWidget {
  final Color color;
  final SeriesStroke stroke;

  const SeriesSwatch({required this.color, required this.stroke, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 4),
      painter: _SwatchPainter(color: color, stroke: stroke),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  final Color color;
  final SeriesStroke stroke;

  const _SwatchPainter({required this.color, required this.stroke});

  static const double _dash = 8;
  static const double _gap = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    if (stroke == SeriesStroke.solid) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }
    for (double x = 0; x < size.width; x += _dash + _gap) {
      final end = (x + _dash).clamp(0, size.width).toDouble();
      canvas.drawRect(Rect.fromLTRB(x, 0, end, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke;
}
