import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class SessionRawDataCard extends StatelessWidget {
  final List<BleDataPoint> dataPoints;

  const SessionRawDataCard({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeading('Raw Data'),
              Text(
                '${dataPoints.length} data points',
                style: CrimpyTheme.bodySmall.copyWith(
                  color: CrimpyTheme.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: CrimpyTheme.spaceLg),
          Text(
            'Data collection period: ${DateFormat('HH:mm:ss').format(dataPoints.first.timestamp)} - ${DateFormat('HH:mm:ss').format(dataPoints.last.timestamp)}',
            style: CrimpyTheme.bodySmall,
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          Text(
            'Sample rate: ${(dataPoints.length / (dataPoints.last.timestamp.difference(dataPoints.first.timestamp).inSeconds)).toStringAsFixed(1)} Hz',
            style: CrimpyTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
