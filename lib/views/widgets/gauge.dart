import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import '../../theme/crimpy_theme.dart';

class Gauge extends ConsumerWidget {
  final double targetWeight;

  const Gauge(this.targetWeight, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceState = ref.watch(bleDataStreamProvider);
    final double fillPercentage = targetWeight == 0
        ? 0
        : min(100, (forceState.value!.last.value / targetWeight) * 100 * 0.67);
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: WeightGaugePainter(
          fillPercentage: fillPercentage,
          currentWeight: forceState.value != null
              ? forceState.value!.last.value
              : 0,
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
    final strokeWidth = 4.0;
    final innerRadius = radius - strokeWidth;
    final bool targetMatched = targetWeight <= currentWeight;

    // Paint for circle outline
    final outlinePaint = Paint()
      ..color = CrimpyTheme.gray300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Paint for light gray background
    final lightGrayPaint = Paint()
      ..color = CrimpyTheme.gray100
      ..style = PaintingStyle.fill;

    // Paint for dark gray fill
    final darkGrayPaint = Paint()
      ..color = targetMatched ? CrimpyTheme.primaryBlack : CrimpyTheme.gray600
      ..style = PaintingStyle.fill;

    // Draw light gray background circle
    canvas.drawCircle(center, innerRadius, lightGrayPaint);
    canvas.drawCircle(center, radius - (strokeWidth / 2), outlinePaint);

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
    canvas.drawCircle(center, innerRadius, darkGrayPaint);

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
      text: currentWeight.toStringAsFixed(
        currentWeight.truncateToDouble() == currentWeight ? 0 : 1,
      ),
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
      text: targetWeight.toStringAsFixed(
        targetWeight.truncateToDouble() == targetWeight ? 0 : 1,
      ),
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
