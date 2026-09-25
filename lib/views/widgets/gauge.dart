import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/utils/format.dart';
import '../../theme/crimpy_theme.dart';

class Gauge extends ConsumerWidget {
  final double targetWeight;
  final double size;

  /// Whether the run feeding the gauge is suspended. The sensor stream is muted
  /// for the whole pause, so the last sample is stale: showing it would read as
  /// a hold the athlete is not doing.
  final bool paused;

  const Gauge(
    this.targetWeight, {
    this.size = 300,
    this.paused = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(bleDataStreamProvider).value;
    final currentWeight = (paused || points == null || points.isEmpty)
        ? 0.0
        : points.last.value;
    final double fillPercentage = targetWeight == 0
        ? 0
        : min(100.0, (currentWeight / targetWeight) * 100 * 0.67);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: WeightGaugePainter(
          fillPercentage: fillPercentage,
          currentWeight: currentWeight,
          targetWeight: targetWeight,
        ),
      ),
    );
  }
}

class WeightGaugePainter extends CustomPainter {
  final double fillPercentage;
  final double currentWeight;
  final double targetWeight;

  WeightGaugePainter({
    required this.fillPercentage,
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final centerText = Offset(size.width / 2, size.height / 3);
    final radius = min(size.width, size.height) / 2;
    final bool targetMatched = targetWeight <= currentWeight;

    // The empty tank. It needs no outline of its own: the timer ring around it
    // is a closed circle in every state, so it already bounds the shape.
    final lightGrayPaint = Paint()
      ..color = CrimpyTheme.gray100
      ..style = PaintingStyle.fill;

    // Paint for the liquid fill: turns green once the target is reached.
    final darkGrayPaint = Paint()
      ..color = targetMatched ? CrimpyTheme.statusSuccess : CrimpyTheme.gray600
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, lightGrayPaint);

    // Save canvas state before clipping
    canvas.save();

    // Create clipping path for the "liquid" fill
    final fillHeight = (fillPercentage / 100) * size.height;
    final clipRect = Rect.fromLTWH(
      0,
      size.height - fillHeight,
      size.width,
      fillHeight,
    );
    canvas.clipRect(clipRect);

    // Draw dark gray fill inside the clipped area
    canvas.drawCircle(center, radius, darkGrayPaint);

    // Restore canvas to remove clipping
    canvas.restore();

    // Text settings
    const textStyle = TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: CrimpyTheme.primaryBlack,
    );
    const targetTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: CrimpyTheme.primaryBlack,
    );
    const unitTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: CrimpyTheme.primaryBlack,
    );

    // Draw current weight text
    _drawTextWithColorTransition(
      canvas: canvas,
      text: formatKilograms(currentWeight),
      position: Offset(centerText.dx, centerText.dy - 24),
      textStyle: textStyle,
      fillPercentage: fillPercentage,
      size: size,
    );

    // Draw divider line with color transition
    _drawDividerWithColorTransition(
      canvas: canvas,
      position: Offset(centerText.dx, centerText.dy),
      width: 150,
      fillPercentage: fillPercentage,
      size: size,
    );

    // Draw target weight text
    _drawTextWithColorTransition(
      canvas: canvas,
      text: formatKilograms(targetWeight),
      position: Offset(centerText.dx, centerText.dy + 20),
      textStyle: targetTextStyle,
      fillPercentage: fillPercentage,
      size: size,
    );

    // Draw "kg" unit
    _drawTextWithColorTransition(
      canvas: canvas,
      text: "kg",
      position: Offset(centerText.dx, centerText.dy + 45),
      textStyle: unitTextStyle,
      fillPercentage: fillPercentage,
      size: size,
    );

    // "ON TARGET" cue once the target weight is reached.
    if (targetMatched && targetWeight > 0) {
      final onTargetPainter = TextPainter(
        text: const TextSpan(
          text: "ON TARGET",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: CrimpyTheme.statusSuccess,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      onTargetPainter.paint(
        canvas,
        Offset(
          center.dx - onTargetPainter.width / 2,
          size.height - onTargetPainter.height - radius / 4,
        ),
      );
    }
  }

  void _drawTextWithColorTransition({
    required Canvas canvas,
    required String text,
    required Offset position,
    required TextStyle textStyle,
    required double fillPercentage,
    required Size size,
  }) {
    // Draw black text for the entire content
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate the position to center the text
    final textX = position.dx - textPainter.width / 2;
    final textY = position.dy - textPainter.height / 2;
    final textPosition = Offset(textX, textY);

    // Draw the black text
    textPainter.paint(canvas, textPosition);

    // Calculate the fill line position
    final fillLineY = size.height - (fillPercentage / 100 * size.height);

    // If the fill line intersects with the text, draw the white portion
    if (fillLineY <= textY + textPainter.height && fillLineY >= textY) {
      // Save canvas state before clipping
      canvas.save();

      // Create clipping rectangle for the part that should be white
      final whiteClipRect = Rect.fromLTWH(
        0,
        fillLineY,
        size.width,
        size.height - fillLineY,
      );
      canvas.clipRect(whiteClipRect);

      // Draw white text in the clipped area
      final whiteTextSpan = TextSpan(
        text: text,
        style: textStyle.copyWith(color: CrimpyTheme.primaryWhite),
      );
      final whiteTextPainter = TextPainter(
        text: whiteTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      whiteTextPainter.layout();
      whiteTextPainter.paint(canvas, textPosition);

      // Restore canvas to remove clipping
      canvas.restore();
    }
    // If the text is completely below the fill line, make it all white
    else if (fillLineY <= textY) {
      final whiteTextSpan = TextSpan(
        text: text,
        style: textStyle.copyWith(color: CrimpyTheme.primaryWhite),
      );
      final whiteTextPainter = TextPainter(
        text: whiteTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      whiteTextPainter.layout();
      whiteTextPainter.paint(canvas, textPosition);
    }
  }

  void _drawDividerWithColorTransition({
    required Canvas canvas,
    required Offset position,
    required double width,
    required double fillPercentage,
    required Size size,
  }) {
    final dividerY = position.dy;
    final dividerHeight = 3.0;

    // Draw black divider
    final dividerRect = Rect.fromCenter(
      center: Offset(position.dx, dividerY),
      width: width,
      height: dividerHeight,
    );
    canvas.drawRect(dividerRect, Paint()..color = CrimpyTheme.primaryBlack);

    // Calculate the fill line position
    final fillLineY = size.height - (fillPercentage / 100 * size.height);

    // If the fill line is above the divider, draw the white portion
    if (fillLineY <= dividerY + dividerHeight / 2) {
      // Save canvas state before clipping
      canvas.save();

      // Create clipping rectangle for the part that should be white
      final whiteClipRect = Rect.fromLTWH(
        0,
        fillLineY,
        size.width,
        size.height - fillLineY,
      );
      canvas.clipRect(whiteClipRect);

      // Draw white divider in the clipped area
      canvas.drawRect(dividerRect, Paint()..color = CrimpyTheme.primaryWhite);

      // Restore canvas to remove clipping
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(WeightGaugePainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.currentWeight != currentWeight ||
        oldDelegate.targetWeight != targetWeight;
  }
}
