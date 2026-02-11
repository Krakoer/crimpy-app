import 'package:flutter/material.dart';
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
              Text(
                'Raw Data',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${dataPoints.length} data points',
                style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Data collection period: ${DateFormat('HH:mm:ss').format(dataPoints.first.timestamp)} - ${DateFormat('HH:mm:ss').format(dataPoints.last.timestamp)}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Sample rate: ${(dataPoints.length / (dataPoints.last.timestamp.difference(dataPoints.first.timestamp).inSeconds)).toStringAsFixed(1)} Hz',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
