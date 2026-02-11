import 'package:crimpy/views/widgets/training_visualization/waveform/waveform_constants.dart';

/// Utility functions for waveform calculations
class WaveformUtils {
  WaveformUtils._();

  /// Calculates height multipliers for right and left hands based on their weights
  /// Returns a record with (rightMultiplier, leftMultiplier)
  static ({double right, double left}) calculateHeightMultipliers({
    required double rightWeight,
    required double leftWeight,
  }) {
    final maxWeight = rightWeight > leftWeight ? rightWeight : leftWeight;

    if (maxWeight == 0) {
      return (right: 1.0, left: 1.0);
    }

    if (rightWeight > leftWeight) {
      return (
        right: WaveformConstants.fullHeightMultiplier,
        left: WaveformConstants.reducedHeightMultiplier,
      );
    } else if (leftWeight > rightWeight) {
      return (
        right: WaveformConstants.reducedHeightMultiplier,
        left: WaveformConstants.fullHeightMultiplier,
      );
    }

    // Equal weights
    return (right: 1.0, left: 1.0);
  }

  /// Calculates the vertical position for a waveform based on height multiplier
  static double calculateWaveformTop({
    required double baseTop,
    required double baseHeight,
    required double heightMultiplier,
  }) {
    final actualHeight = baseHeight * heightMultiplier;
    return baseTop + (baseHeight - actualHeight);
  }
}
