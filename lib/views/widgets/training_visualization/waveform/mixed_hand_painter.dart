import 'dart:math';

import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_constants.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_painter_base.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_styles.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_text_painter.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_utils.dart';
import 'package:flutter/material.dart';

/// Custom painter for mixed hand repeater waveform visualization
/// Shows alternating hands with work/rest pattern
class MixedHandRepeaterWaveformPainter extends CustomPainter {
  final RepeaterModel repeater;

  MixedHandRepeaterWaveformPainter({required this.repeater});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate dimensions
    final baseWaveformHeight =
        size.height * WaveformConstants.waveformHeightRatio;
    final waveformTop = size.height * WaveformConstants.waveformTopRatio;
    final availableWidth = size.width - (WaveformConstants.padding * 2);

    // Calculate height multipliers
    // Use right weight as fallback for left if not specified
    final rightWeight = repeater.weightRight ?? 0.0;
    final leftWeight = repeater.weightLeft ?? rightWeight;
    final multipliers = WaveformUtils.calculateHeightMultipliers(
      rightWeight: rightWeight,
      leftWeight: leftWeight,
    );

    final rightWaveformHeight = baseWaveformHeight * multipliers.right;
    final rightWaveformTop = WaveformUtils.calculateWaveformTop(
      baseTop: waveformTop,
      baseHeight: baseWaveformHeight,
      heightMultiplier: multipliers.right,
    );

    final leftWaveformHeight = baseWaveformHeight * multipliers.left;
    final leftWaveformTop = WaveformUtils.calculateWaveformTop(
      baseTop: waveformTop,
      baseHeight: baseWaveformHeight,
      heightMultiplier: multipliers.left,
    );

    // Text styles
    final timeStyle = WaveformStyles.createTimeStyle();

    // Calculate widths
    final setWidth = availableWidth * 0.8 - WaveformConstants.cutWidth;
    final singleRepWidth = setWidth / 5;
    final repDuration = repeater.workTime + repeater.restTime;
    final workWidth = (repeater.workTime / repDuration) * singleRepWidth;
    final restWidth = (repeater.restTime / repDuration) * singleRepWidth;

    // Create paints
    final workPaint = WaveformStyles.createWorkPaint();
    final restPaint = WaveformStyles.createRestPaint();

    // Draw reps count
    final repsText =
        '${repeater.repsBySet * 2} reps total (${repeater.repsBySet} by hand)';
    WaveformTextPainter.paintTextCenteredInWidth(
      canvas: canvas,
      text: repsText,
      style: timeStyle,
      startX: WaveformConstants.padding,
      width: availableWidth,
      y: min(rightWaveformTop, leftWaveformTop) - 20,
    );

    // Draw first 4 reps (2 right, 2 left alternating)
    double currentX = WaveformConstants.padding;
    for (int i = 0; i < 4; i++) {
      final isRight = i % 2 == 0;
      final top = isRight ? rightWaveformTop : leftWaveformTop;
      final height = isRight ? rightWaveformHeight : leftWaveformHeight;

      _drawRepAnnotations(
        canvas: canvas,
        i: i,
        isRight: isRight,
        currentX: currentX,
        workWidth: workWidth,
        restWidth: restWidth,
        top: top,
        height: height,
        timeStyle: timeStyle,
        rightWeight: rightWeight,
        leftWeight: leftWeight,
      );

      // Draw work period
      WaveformPainterBase.drawWorkPeriod(
        canvas,
        currentX,
        workWidth,
        top,
        height,
        workPaint,
      );
      currentX += workWidth;

      // Draw rest period with cut if needed
      if (i <= 3) {
        currentX = _drawRestWithOptionalCut(
          canvas: canvas,
          currentX: currentX,
          restWidth: restWidth,
          i: i,
          top: top,
          height: height,
          restPaint: restPaint,
        );
      }
    }

    // Draw the last rep (5th rep, left hand)
    WaveformPainterBase.drawWorkPeriod(
      canvas,
      currentX,
      workWidth,
      leftWaveformTop,
      leftWaveformHeight,
      workPaint,
    );
    currentX += workWidth;

    // Draw rest between sets
    _drawRestBetweenSets(
      canvas: canvas,
      currentX: currentX,
      availableWidth: availableWidth,
      waveformTop: waveformTop,
      baseWaveformHeight: baseWaveformHeight,
      rightWaveformTop: rightWaveformTop,
      rightWaveformHeight: rightWaveformHeight,
      timeStyle: timeStyle,
    );
  }

  /// Draws weight and time annotations for the first two reps
  void _drawRepAnnotations({
    required Canvas canvas,
    required int i,
    required bool isRight,
    required double currentX,
    required double workWidth,
    required double restWidth,
    required double top,
    required double height,
    required TextStyle timeStyle,
    required double rightWeight,
    required double leftWeight,
  }) {
    // Draw hand side label and weight annotation on first rep of each hand
    if (i == 0 || i == 1) {
      final weight = isRight ? rightWeight : leftWeight;
      final handLabel = isRight ? 'R' : 'L';
      final handColor = isRight
          ? CrimpyTheme.accentOrange
          : CrimpyTheme.accentTeal;

      // Draw hand side label
      final handLabelStyle = WaveformStyles.createLabelStyle().copyWith(
        color: handColor,
        fontSize: 12,
      );
      final handLabelSize = WaveformTextPainter.measureText(
        text: handLabel,
        style: handLabelStyle,
      );
      WaveformTextPainter.paintCenteredText(
        canvas: canvas,
        text: handLabel,
        style: handLabelStyle,
        centerX: currentX + workWidth / 2,
        y: top - handLabelSize.height - 18,
      );

      // Draw weight annotation below hand label
      final weightText = '${weight.toStringAsFixed(1)}kg';
      WaveformTextPainter.paintCenteredText(
        canvas: canvas,
        text: weightText,
        style: WaveformStyles.createWeightStyle(CrimpyTheme.errorColor),
        centerX: currentX + workWidth / 2,
        y:
            top -
            WaveformTextPainter.measureText(
              text: weightText,
              style: timeStyle,
            ).height -
            2,
      );
    }

    // Draw time annotations on first rep only
    if (i == 0) {
      // Work time
      WaveformTextPainter.paintCenteredText(
        canvas: canvas,
        text: '${repeater.workTime}s',
        style: timeStyle,
        centerX: currentX + workWidth / 2,
        y: top + height + 5,
      );

      // Rest time
      WaveformTextPainter.paintCenteredText(
        canvas: canvas,
        text: '${repeater.restTime}s',
        style: timeStyle,
        centerX: currentX + workWidth + restWidth / 2,
        y: top + height + 5,
      );
    }
  }

  /// Draws rest period with optional cut symbol for ellipsis
  double _drawRestWithOptionalCut({
    required Canvas canvas,
    required double currentX,
    required double restWidth,
    required int i,
    required double top,
    required double height,
    required Paint restPaint,
  }) {
    if (i == 3) {
      // Second to last rep: draw split rest with cut symbol
      WaveformPainterBase.drawRestPeriod(
        canvas,
        currentX,
        restWidth,
        top,
        height,
        restPaint,
      );
      currentX += restWidth;

      // Draw cut symbol
      final cutCenterX = currentX + (WaveformConstants.cutWidth / 2);
      WaveformPainterBase.drawCutSymbol(canvas, cutCenterX, top, height);
      currentX += WaveformConstants.cutWidth;

      WaveformPainterBase.drawRestPeriod(
        canvas,
        currentX,
        restWidth,
        top,
        height,
        restPaint,
      );
      currentX += restWidth;
    } else {
      // Normal rest period
      WaveformPainterBase.drawRestPeriod(
        canvas,
        currentX,
        restWidth,
        top,
        height,
        restPaint,
      );
      currentX += restWidth;
    }

    return currentX;
  }

  /// Draws the rest period between sets
  void _drawRestBetweenSets({
    required Canvas canvas,
    required double currentX,
    required double availableWidth,
    required double waveformTop,
    required double baseWaveformHeight,
    required double rightWaveformTop,
    required double rightWaveformHeight,
    required TextStyle timeStyle,
  }) {
    WaveformPainterBase.drawRestPeriod(
      canvas,
      currentX,
      0.2 * availableWidth,
      rightWaveformTop,
      rightWaveformHeight,
      WaveformStyles.createRestPaint(),
    );

    // Draw rest duration label
    final restLabel = formatDurationHMS(repeater.restBteweenSets);
    WaveformTextPainter.paintCenteredText(
      canvas: canvas,
      text: restLabel,
      style: WaveformStyles.createRestLabelStyle(),
      centerX: currentX + availableWidth * 0.1,
      y: waveformTop + baseWaveformHeight + 5,
    );
  }

  @override
  bool shouldRepaint(MixedHandRepeaterWaveformPainter oldDelegate) {
    return oldDelegate.repeater != repeater;
  }
}
