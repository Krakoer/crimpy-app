import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_constants.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_styles.dart';
import 'package:flutter/material.dart';

/// Base class with shared drawing utilities for waveform painters
abstract class WaveformPainterBase {
  /// Draws the ellipsis cut symbol to indicate skipped repetitions
  static void drawCutSymbol(
    Canvas canvas,
    double x,
    double top,
    double height,
  ) {
    final cutPaint = WaveformStyles.createCutPaint();

    // Draw two parallel diagonal lines like //
    // Positioned vertically in the middle with slight angle
    final lineLength = height * WaveformConstants.cutLineLengthRatio;
    final startY = top + (height - lineLength / 2);
    final endY = startY + lineLength;

    // Left line
    canvas.drawLine(
      Offset(
        x -
            WaveformConstants.cutLineSpacing / 2 -
            WaveformConstants.cutHorizontalOffset,
        startY,
      ),
      Offset(
        x -
            WaveformConstants.cutLineSpacing / 2 +
            WaveformConstants.cutHorizontalOffset,
        endY,
      ),
      cutPaint,
    );

    // Right line
    canvas.drawLine(
      Offset(
        x +
            WaveformConstants.cutLineSpacing / 2 -
            WaveformConstants.cutHorizontalOffset,
        startY,
      ),
      Offset(
        x +
            WaveformConstants.cutLineSpacing / 2 +
            WaveformConstants.cutHorizontalOffset,
        endY,
      ),
      cutPaint,
    );
  }

  /// Draws a work period as a high bar
  static void drawWorkPeriod(
    Canvas canvas,
    double startX,
    double width,
    double top,
    double height,
    Paint paint,
  ) {
    final workPath =
        Path()
          ..moveTo(startX, top + height)
          ..lineTo(startX, top)
          ..lineTo(startX + width, top)
          ..lineTo(startX + width, top + height);
    canvas.drawPath(workPath, paint);
  }

  /// Draws a rest period as a low horizontal line
  static void drawRestPeriod(
    Canvas canvas,
    double startX,
    double width,
    double top,
    double height,
    Paint paint,
  ) {
    final restPath =
        Path()
          ..moveTo(startX, top + height)
          ..lineTo(startX + width, top + height);
    canvas.drawPath(restPath, paint);
  }
}
