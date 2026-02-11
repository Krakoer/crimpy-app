import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_constants.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_painter_base.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_styles.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_text_painter.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_utils.dart';
import 'package:flutter/material.dart';

/// Custom painter for split hand repeater waveform visualization
/// Shows separate sections for right and left hands
class SplitHandRepeaterWaveformPainter extends CustomPainter {
  final RepeaterModel repeater;

  SplitHandRepeaterWaveformPainter({required this.repeater});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate rest between hands
    final repDuration = repeater.workTime + repeater.restTime;
    final handSetDuration = repeater.repsBySet * repDuration;
    final restBetweenHands = (repeater.restBteweenSets - handSetDuration) ~/ 2;

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
    final labelStyle = WaveformStyles.createLabelStyle();
    final timeStyle = WaveformStyles.createTimeStyle();

    // Draw right hand section
    double currentX = WaveformConstants.padding;
    _drawHandSection(
      canvas: canvas,
      size: size,
      startX: currentX,
      width: availableWidth * 0.4,
      top: rightWaveformTop,
      height: rightWaveformHeight,
      handLabel: 'Right Hand',
      totalReps: repeater.repsBySet,
      workTime: repeater.workTime,
      restTime: repeater.restTime,
      handColor: CrimpyTheme.accentOrange,
      labelStyle: labelStyle,
      timeStyle: timeStyle,
      targetWeight: rightWeight,
    );

    // Draw rest between hands
    currentX += availableWidth * 0.4;
    _drawRestBetweenHands(
      canvas: canvas,
      currentX: currentX,
      width: availableWidth * 0.1,
      waveformTop: waveformTop,
      baseWaveformHeight: baseWaveformHeight,
      rightWaveformTop: rightWaveformTop,
      rightWaveformHeight: rightWaveformHeight,
      restDuration: restBetweenHands,
      timeStyle: timeStyle,
    );

    // Draw left hand section
    currentX += availableWidth * 0.1;
    _drawHandSection(
      canvas: canvas,
      size: size,
      startX: currentX,
      width: availableWidth * 0.4,
      top: leftWaveformTop,
      height: leftWaveformHeight,
      handLabel: 'Left Hand',
      totalReps: repeater.repsBySet,
      workTime: repeater.workTime,
      restTime: repeater.restTime,
      handColor: CrimpyTheme.accentTeal,
      labelStyle: labelStyle,
      timeStyle: timeStyle,
      targetWeight: leftWeight,
    );

    // Draw final rest indicator
    currentX += availableWidth * 0.4;
    WaveformPainterBase.drawRestPeriod(
      canvas,
      currentX,
      0.1 * availableWidth,
      rightWaveformTop,
      rightWaveformHeight,
      WaveformStyles.createRestPaint(),
    );
  }

  /// Draws a complete hand section with simplified 3-rep visualization
  void _drawHandSection({
    required Canvas canvas,
    required Size size,
    required double startX,
    required double width,
    required double top,
    required double height,
    required String handLabel,
    required int totalReps,
    required int workTime,
    required int restTime,
    required Color handColor,
    required TextStyle labelStyle,
    required TextStyle timeStyle,
    required double targetWeight,
  }) {
    const repsToShow = 3;

    // Calculate widths
    final availableWidth = width - WaveformConstants.cutWidth;
    final singleRepWidth = availableWidth / repsToShow;
    final repDuration = workTime + restTime;
    final workWidth = (workTime / repDuration) * singleRepWidth;
    final restWidth = (restTime / repDuration) * singleRepWidth;

    // Create paints
    final workPaint = WaveformStyles.createWorkPaint();
    final restPaint = WaveformStyles.createRestPaint();

    // Draw hand label
    WaveformTextPainter.paintTextCenteredInWidth(
      canvas: canvas,
      text: handLabel,
      style: labelStyle.copyWith(color: handColor),
      startX: startX,
      width: width,
      y: top - 35,
    );

    // Draw reps count
    WaveformTextPainter.paintTextCenteredInWidth(
      canvas: canvas,
      text: '$totalReps reps',
      style: timeStyle,
      startX: startX,
      width: width,
      y: top - 20,
    );

    // Draw weight label
    if (targetWeight > 0) {
      final weightText = '${targetWeight.toStringAsFixed(1)}kg';
      final weightSize = WaveformTextPainter.measureText(
        text: weightText,
        style: timeStyle,
      );
      WaveformTextPainter.paintText(
        canvas: canvas,
        text: weightText,
        style: WaveformStyles.createWeightStyle(handColor),
        position: Offset(startX - 2, top - weightSize.height - 2),
      );
    }

    // Draw simplified waveform
    double currentX = startX;
    for (int i = 0; i < repsToShow; i++) {
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

      // Draw rest period with optional cut
      if (i < repsToShow - 1) {
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

      // Draw time annotations on first rep only
      if (i == 0) {
        // Work time
        WaveformTextPainter.paintCenteredText(
          canvas: canvas,
          text: '${workTime}s',
          style: timeStyle,
          centerX: currentX - restWidth - workWidth / 2,
          y: top + height + 5,
        );

        // Rest time
        WaveformTextPainter.paintCenteredText(
          canvas: canvas,
          text: '${restTime}s',
          style: timeStyle,
          centerX: currentX - restWidth / 2,
          y: top + height + 5,
        );
      }
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
    if (i == 1) {
      // Second rep: draw split rest with cut symbol
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

  /// Draws the rest period between hands
  void _drawRestBetweenHands({
    required Canvas canvas,
    required double currentX,
    required double width,
    required double waveformTop,
    required double baseWaveformHeight,
    required double rightWaveformTop,
    required double rightWaveformHeight,
    required int restDuration,
    required TextStyle timeStyle,
  }) {
    WaveformPainterBase.drawRestPeriod(
      canvas,
      currentX,
      width,
      rightWaveformTop,
      rightWaveformHeight,
      WaveformStyles.createRestPaint(),
    );

    // Draw rest duration label
    final restLabel = formatDurationHMS(restDuration);
    WaveformTextPainter.paintCenteredText(
      canvas: canvas,
      text: restLabel,
      style: WaveformStyles.createRestLabelStyle(),
      centerX: currentX + width / 2,
      y: waveformTop + baseWaveformHeight + 5,
    );
  }

  @override
  bool shouldRepaint(SplitHandRepeaterWaveformPainter oldDelegate) {
    return oldDelegate.repeater != repeater;
  }
}
