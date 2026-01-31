import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:flutter/material.dart';

/// Waveform visualization for split-hand repeater training
/// Shows work/rest pattern with annotations for timing and weights
class RepeaterWaveformVisualization extends StatelessWidget {
  final RepeaterModel repeater;

  const RepeaterWaveformVisualization({super.key, required this.repeater});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter:
            repeater.splitHand
                ? SplitHandRepeaterWaveformPainter(repeater: repeater)
                : MixedHandRepeaterWaveformPainter(repeater: repeater),
        size: const Size(double.infinity, 180),
      ),
    );
  }
}

/// Custom painter for the mixed hand waveform visualization
class MixedHandRepeaterWaveformPainter extends CustomPainter {
  final RepeaterModel repeater;

  MixedHandRepeaterWaveformPainter({required this.repeater});

  @override
  void paint(Canvas canvas, Size size) {
    // Dimensions
    final baseWaveformHeight = size.height * 0.5;
    final waveformTop = size.height * 0.25;
    final padding = 20.0;
    final availableWidth = size.width - (padding * 2);

    // Compute height multipliers based on target weights
    final rightWeight = repeater.weightRight ?? 0.0;
    final leftWeight = repeater.weightLeft ?? 0.0;
    final maxWeight = rightWeight > leftWeight ? rightWeight : leftWeight;

    double rightHeightMultiplier = 1.0;
    double leftHeightMultiplier = 1.0;

    if (maxWeight > 0) {
      if (rightWeight > leftWeight) {
        rightHeightMultiplier = 1.0;
        leftHeightMultiplier = 0.75;
      } else if (leftWeight > rightWeight) {
        rightHeightMultiplier = 0.75;
        leftHeightMultiplier = 1.0;
      }
      // If equal, both remain 1.0
    }

    final timeStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: CrimpyTheme.textSecondary,
    );

    double currentX = padding;
    final rightWaveformHeight = baseWaveformHeight * rightHeightMultiplier;
    final rightWaveformTop =
        waveformTop + (baseWaveformHeight - rightWaveformHeight);
    final leftWaveformHeight = baseWaveformHeight * leftHeightMultiplier;
    final leftWaveformTop =
        waveformTop + (baseWaveformHeight - leftWaveformHeight);

    final cutWidth = 8.0;
    final setWidth = availableWidth * 0.8 - cutWidth;
    final singleRepWidth = setWidth / 5;
    final repDuration = repeater.workTime + repeater.restTime;
    final workWidth = (repeater.workTime / repDuration) * singleRepWidth;
    final restWidth = (repeater.restTime / repDuration) * singleRepWidth;

    final workPaint =
        Paint()
          ..color = CrimpyTheme.errorColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final restPaint =
        Paint()
          ..color = CrimpyTheme.successColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final isRight = i % 2 == 0;
      final top = isRight ? rightWaveformTop : leftWaveformTop;
      final height = isRight ? rightWaveformHeight : leftWaveformHeight;

      // If first rep of the hand, print weight and time
      if (i == 0 || i == 1) {
        // Weight annotation
        final weightText =
            '${isRight ? repeater.weightRight!.toStringAsFixed(1) : repeater.weightLeft!.toStringAsFixed(1)}kg';
        final weightPainter = TextPainter(
          text: TextSpan(
            text: weightText,
            style: timeStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: CrimpyTheme.errorColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        weightPainter.paint(
          canvas,
          Offset(
            currentX + workWidth / 2 - weightPainter.width / 2,
            top - weightPainter.height - 2,
          ),
        );
      }
      if (i == 0) {
        // Work time annotation
        final workTimePainter = TextPainter(
          text: TextSpan(text: '${repeater.workTime}s', style: timeStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        workTimePainter.paint(
          canvas,
          Offset(
            currentX - workTimePainter.width / 2 + workWidth / 2,
            top + height + 5,
          ),
        );

        // Rest time annotation
        final restTimePainter = TextPainter(
          text: TextSpan(text: '${repeater.restTime}s', style: timeStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        restTimePainter.paint(
          canvas,
          Offset(
            currentX - restTimePainter.width / 2 + workWidth + restWidth / 2,
            top + height + 5,
          ),
        );
      }
      // Draw work period (high)
      final workPath = Path();
      workPath.moveTo(currentX, top + height);
      workPath.lineTo(currentX, top);
      workPath.lineTo(currentX + workWidth, top);
      workPath.lineTo(currentX + workWidth, top + height);
      canvas.drawPath(workPath, workPaint);
      currentX += workWidth;

      // If last rep, don't draw a rest
      if (i == 4) {
      }
      // If second to last rep, draw line cut in rest to indicate elipse
      else if (i == 3) {
        final restPath = Path();
        restPath.moveTo(currentX, top + height);
        restPath.lineTo(currentX + restWidth, top + height);
        canvas.drawPath(restPath, restPaint);
        currentX += restWidth;

        // Draw cut symbol after first rep if needed
        final cutCenterX = currentX + (cutWidth / 2);
        _drawCutSymbol(canvas, cutCenterX, top, height);
        currentX += cutWidth;

        final restPath2 = Path();
        restPath2.moveTo(currentX, top + height);
        restPath2.lineTo(currentX + restWidth, top + height);
        canvas.drawPath(restPath2, restPaint);
        currentX += restWidth;
      }
      // If first rep, draw normal rest
      else {
        final restPath = Path();
        restPath.moveTo(currentX, top + height);
        restPath.lineTo(currentX + restWidth, top + height);
        canvas.drawPath(restPath, restPaint);
        currentX += restWidth;
      }
    }

    // Draw the last rep of the set (a left hand)
    final workPath = Path();
    workPath.moveTo(currentX, leftWaveformTop + leftWaveformHeight);
    workPath.lineTo(currentX, leftWaveformTop);
    workPath.lineTo(currentX + workWidth, leftWaveformTop);
    workPath.lineTo(currentX + workWidth, leftWaveformTop + leftWaveformHeight);
    canvas.drawPath(workPath, workPaint);
    currentX += workWidth;

    // Draw rest between set
    final restPath = Path();
    restPath.moveTo(currentX, rightWaveformTop + rightWaveformHeight);
    restPath.lineTo(
      currentX + 0.2 * availableWidth,
      rightWaveformTop + rightWaveformHeight,
    );
    canvas.drawPath(
      restPath,
      Paint()
        ..color = CrimpyTheme.successColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    // Print rest between set text
    final restLabel = formatDurationHMS(repeater.restBteweenSets);
    final restPainter = TextPainter(
      text: TextSpan(
        text: restLabel,
        style: timeStyle.copyWith(
          color: CrimpyTheme.successColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    restPainter.paint(
      canvas,
      Offset(
        currentX + availableWidth * 0.1 - restPainter.width / 2,
        waveformTop + baseWaveformHeight + 5,
      ),
    );

    // Draw reps count
    final repsText =
        '${repeater.repsBySet * 2} reps total (${repeater.repsBySet} by hand)';
    final repsPainter = TextPainter(
      text: TextSpan(text: repsText, style: timeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    repsPainter.paint(
      canvas,
      Offset(
        padding + (availableWidth - repsPainter.width) / 2,
        rightWaveformTop - 20,
      ),
    );
  }

  void _drawCutSymbol(Canvas canvas, double x, double top, double height) {
    final cutPaint =
        Paint()
          ..color = CrimpyTheme.textMuted
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw two parallel diagonal lines like //
    // Positioned vertically in the middle with slight angle
    final lineSpacing = 4.0;
    final lineLength = height * 0.1;
    final horizontalOffset = 2.0; // Small horizontal offset for diagonal

    final startY = top + (height - lineLength / 2);
    final endY = startY + lineLength;

    // Left line
    canvas.drawLine(
      Offset(x - lineSpacing / 2 - horizontalOffset, startY),
      Offset(x - lineSpacing / 2 + horizontalOffset, endY),
      cutPaint,
    );

    // Right line
    canvas.drawLine(
      Offset(x + lineSpacing / 2 - horizontalOffset, startY),
      Offset(x + lineSpacing / 2 + horizontalOffset, endY),
      cutPaint,
    );
  }

  @override
  bool shouldRepaint(MixedHandRepeaterWaveformPainter oldDelegate) {
    return oldDelegate.repeater != repeater;
  }
}

/// Custom painter for the split hand waveform visualization
class SplitHandRepeaterWaveformPainter extends CustomPainter {
  final RepeaterModel repeater;

  SplitHandRepeaterWaveformPainter({required this.repeater});

  @override
  void paint(Canvas canvas, Size size) {
    // Compute rest between hands
    final repDuration = repeater.workTime + repeater.restTime;
    final handSetDuration = repeater.repsBySet * repDuration;
    final restBetweenHands = (repeater.restBteweenSets - handSetDuration) ~/ 2;

    // Dimensions
    final baseWaveformHeight = size.height * 0.5;
    final waveformTop = size.height * 0.25;
    final padding = 20.0;
    final availableWidth = size.width - (padding * 2);

    // Compute height multipliers based on target weights
    final rightWeight = repeater.weightRight ?? 0.0;
    final leftWeight = repeater.weightLeft ?? 0.0;
    final maxWeight = rightWeight > leftWeight ? rightWeight : leftWeight;

    double rightHeightMultiplier = 1.0;
    double leftHeightMultiplier = 1.0;

    if (maxWeight > 0) {
      if (rightWeight > leftWeight) {
        rightHeightMultiplier = 1.0;
        leftHeightMultiplier = 0.75;
      } else if (leftWeight > rightWeight) {
        rightHeightMultiplier = 0.75;
        leftHeightMultiplier = 1.0;
      }
      // If equal, both remain 1.0
    }

    // Text styles
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: CrimpyTheme.textPrimary,
    );

    final timeStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: CrimpyTheme.textSecondary,
    );

    // Draw right hand section
    double currentX = padding;
    final rightWaveformHeight = baseWaveformHeight * rightHeightMultiplier;
    final rightWaveformTop =
        waveformTop + (baseWaveformHeight - rightWaveformHeight);
    _drawSimplifiedHandSection(
      canvas,
      size,
      currentX,
      availableWidth * 0.4,
      rightWaveformTop,
      rightWaveformHeight,
      'Right Hand',
      repeater.repsBySet,
      repeater.workTime,
      repeater.restTime,
      CrimpyTheme.accentOrange,
      labelStyle,
      timeStyle,
      rightWeight,
    );

    // Draw rest between hands
    currentX += availableWidth * 0.4;
    final restPath = Path();
    restPath.moveTo(currentX, rightWaveformTop + rightWaveformHeight);
    restPath.lineTo(
      currentX + 0.1 * availableWidth,
      rightWaveformTop + rightWaveformHeight,
    );
    canvas.drawPath(
      restPath,
      Paint()
        ..color = CrimpyTheme.successColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    final restLabel = formatDurationHMS(restBetweenHands);
    final restPainter = TextPainter(
      text: TextSpan(
        text: restLabel,
        style: timeStyle.copyWith(
          color: CrimpyTheme.successColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    restPainter.paint(
      canvas,
      Offset(
        currentX + availableWidth * 0.05 - restPainter.width / 2,
        waveformTop + baseWaveformHeight + 5,
      ),
    );
    currentX += availableWidth * 0.1;

    // Draw left hand section
    final leftWaveformHeight = baseWaveformHeight * leftHeightMultiplier;
    final leftWaveformTop =
        waveformTop + (baseWaveformHeight - leftWaveformHeight);
    _drawSimplifiedHandSection(
      canvas,
      size,
      currentX,
      availableWidth * 0.4,
      leftWaveformTop,
      leftWaveformHeight,
      'Left Hand',
      repeater.repsBySet,
      repeater.workTime,
      repeater.restTime,
      CrimpyTheme.accentTeal,
      labelStyle,
      timeStyle,
      leftWeight,
    );
    currentX += availableWidth * 0.4;

    final restPath2 = Path();
    restPath2.moveTo(currentX, rightWaveformTop + rightWaveformHeight);
    restPath2.lineTo(
      currentX + 0.1 * availableWidth,
      rightWaveformTop + rightWaveformHeight,
    );
    canvas.drawPath(
      restPath2,
      Paint()
        ..color = CrimpyTheme.successColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  /// Draw a hand section with 3 reps
  void _drawSimplifiedHandSection(
    Canvas canvas,
    Size size,
    double startX,
    double width,
    double top,
    double height,
    String handLabel,
    int totalReps,
    int workTime,
    int restTime,
    Color handColor,
    TextStyle labelStyle,
    TextStyle timeStyle,
    double targetWeight,
  ) {
    final repsToShow = 3;

    // Calculate widths - add padding on sides
    final cutWidth = 8.0;
    final availableWidth = width - cutWidth;
    final singleRepWidth = availableWidth / repsToShow;
    final repDuration = workTime + restTime;
    final workWidth = (workTime / repDuration) * singleRepWidth;
    final restWidth = (restTime / repDuration) * singleRepWidth;

    // Paint configurations
    final workPaint =
        Paint()
          ..color = CrimpyTheme.errorColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final restPaint =
        Paint()
          ..color = CrimpyTheme.successColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    // Draw hand label at top
    final labelPainter = TextPainter(
      text: TextSpan(
        text: handLabel,
        style: labelStyle.copyWith(color: handColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(startX + (width - labelPainter.width) / 2, top - 35),
    );

    // Draw reps count
    final repsText = '$totalReps reps';
    final repsPainter = TextPainter(
      text: TextSpan(text: repsText, style: timeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    repsPainter.paint(
      canvas,
      Offset(startX + (width - repsPainter.width) / 2, top - 20),
    );

    // Draw weight label beside the top of the waveform
    if (targetWeight > 0) {
      final weightText = '${targetWeight.toStringAsFixed(1)}kg';
      final weightPainter = TextPainter(
        text: TextSpan(
          text: weightText,
          style: timeStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: handColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      weightPainter.paint(
        canvas,
        Offset(startX - 2, top - weightPainter.height - 2),
      );
    }

    // Draw simplified waveform - start with padding
    double currentX = startX;

    for (int i = 0; i < repsToShow; i++) {
      // Draw work period (high)
      final workPath = Path();
      workPath.moveTo(currentX, top + height);
      workPath.lineTo(currentX, top);
      workPath.lineTo(currentX + workWidth, top);
      workPath.lineTo(currentX + workWidth, top + height);
      canvas.drawPath(workPath, workPaint);
      currentX += workWidth;

      // If last rep, don't draw a rest
      if (i == repsToShow - 1) {
      }
      // If second rep, draw line cut in rest to indicate elipse
      else if (i == 1) {
        final restPath = Path();
        restPath.moveTo(currentX, top + height);
        restPath.lineTo(currentX + restWidth, top + height);
        canvas.drawPath(restPath, restPaint);
        currentX += restWidth;

        // Draw cut symbol after first rep if needed
        final cutCenterX = currentX + (cutWidth / 2);
        _drawCutSymbol(canvas, cutCenterX, top, height);
        currentX += cutWidth;

        final restPath2 = Path();
        restPath2.moveTo(currentX, top + height);
        restPath2.lineTo(currentX + restWidth, top + height);
        canvas.drawPath(restPath2, restPaint);
        currentX += restWidth;
      }
      // If first rep, draw normal rest
      else {
        final restPath = Path();
        restPath.moveTo(currentX, top + height);
        restPath.lineTo(currentX + restWidth, top + height);
        canvas.drawPath(restPath, restPaint);
        currentX += restWidth;
      }

      // Draw time annotation on first rep only
      if (i == 0) {
        // Work time annotation
        final workTimePainter = TextPainter(
          text: TextSpan(text: '${workTime}s', style: timeStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        workTimePainter.paint(
          canvas,
          Offset(
            currentX - workTimePainter.width / 2 - restWidth - workWidth / 2,
            top + height + 5,
          ),
        );

        // Rest time annotation
        final restTimePainter = TextPainter(
          text: TextSpan(text: '${restTime}s', style: timeStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        restTimePainter.paint(
          canvas,
          Offset(
            currentX - restTimePainter.width / 2 - restWidth / 2,
            top + height + 5,
          ),
        );
      }
    }
  }

  void _drawCutSymbol(Canvas canvas, double x, double top, double height) {
    final cutPaint =
        Paint()
          ..color = CrimpyTheme.textMuted
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw two parallel diagonal lines like //
    // Positioned vertically in the middle with slight angle
    final lineSpacing = 4.0;
    final lineLength = height * 0.1;
    final horizontalOffset = 2.0; // Small horizontal offset for diagonal

    final startY = top + (height - lineLength / 2);
    final endY = startY + lineLength;

    // Left line
    canvas.drawLine(
      Offset(x - lineSpacing / 2 - horizontalOffset, startY),
      Offset(x - lineSpacing / 2 + horizontalOffset, endY),
      cutPaint,
    );

    // Right line
    canvas.drawLine(
      Offset(x + lineSpacing / 2 - horizontalOffset, startY),
      Offset(x + lineSpacing / 2 + horizontalOffset, endY),
      cutPaint,
    );
  }

  @override
  bool shouldRepaint(SplitHandRepeaterWaveformPainter oldDelegate) {
    return oldDelegate.repeater != repeater;
  }
}
