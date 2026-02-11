import 'package:flutter/material.dart';

/// Utility class for painting text on waveform visualizations
class WaveformTextPainter {
  WaveformTextPainter._();

  /// Paints text at the specified position
  static void paintText({
    required Canvas canvas,
    required String text,
    required TextStyle style,
    required Offset position,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, position);
  }

  /// Paints centered text at the specified x position and y position
  static void paintCenteredText({
    required Canvas canvas,
    required String text,
    required TextStyle style,
    required double centerX,
    required double y,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, y));
  }

  /// Paints text centered horizontally within a given width
  static void paintTextCenteredInWidth({
    required Canvas canvas,
    required String text,
    required TextStyle style,
    required double startX,
    required double width,
    required double y,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(startX + (width - textPainter.width) / 2, y),
    );
  }

  /// Gets the dimensions of text without painting it
  static Size measureText({required String text, required TextStyle style}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }
}
