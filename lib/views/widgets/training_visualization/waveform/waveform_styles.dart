import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_constants.dart';
import 'package:flutter/material.dart';

/// Paint and text style factory for waveform visualizations
class WaveformStyles {
  WaveformStyles._();

  /// Paint for work periods
  static Paint createWorkPaint() {
    return Paint()
      ..color = CrimpyTheme.errorColor
      ..strokeWidth = WaveformConstants.strokeWidth
      ..style = PaintingStyle.stroke;
  }

  /// Paint for rest periods
  static Paint createRestPaint() {
    return Paint()
      ..color = CrimpyTheme.successColor
      ..strokeWidth = WaveformConstants.strokeWidth
      ..style = PaintingStyle.stroke;
  }

  /// Paint for cut symbols
  static Paint createCutPaint() {
    return Paint()
      ..color = CrimpyTheme.textMuted
      ..strokeWidth = WaveformConstants.cutSymbolStrokeWidth
      ..style = PaintingStyle.stroke;
  }

  /// Text style for labels (hand names, etc.)
  static TextStyle createLabelStyle() {
    return TextStyle(
      fontSize: WaveformConstants.labelFontSize,
      fontWeight: FontWeight.w600,
      color: CrimpyTheme.textPrimary,
    );
  }

  /// Text style for time annotations
  static TextStyle createTimeStyle() {
    return TextStyle(
      fontSize: WaveformConstants.timeFontSize,
      fontWeight: FontWeight.w500,
      color: CrimpyTheme.textSecondary,
    );
  }

  /// Text style for weight annotations
  static TextStyle createWeightStyle(Color handColor) {
    return createTimeStyle().copyWith(
      fontWeight: FontWeight.w600,
      color: handColor,
    );
  }

  /// Text style for rest duration labels
  static TextStyle createRestLabelStyle() {
    return createTimeStyle().copyWith(
      color: CrimpyTheme.successColor,
      fontWeight: FontWeight.w600,
    );
  }
}
