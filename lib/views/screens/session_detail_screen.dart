// // lib/views/session_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import '../viewmodels/ble_view_model.dart';
// import '../models/ble_data_model.dart';
// import 'package:intl/intl.dart';

// class SessionDetailScreen extends ConsumerWidget {
//   final int sessionId;

//   const SessionDetailScreen({Key? key, required this.sessionId})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final sessionAsync = ref.watch(sessionWithDataProvider(sessionId));

//     return Scaffold(
//       appBar: AppBar(title: const Text('Session Details')),
//       body: sessionAsync.when(
//         data: (session) {
//           if (session == null) {
//             return const Center(child: Text('Session not found'));
//           }

//           final dataPoints = session.dataPoints ?? [];

//           if (dataPoints.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.warning_amber_rounded,
//                     size: 60,
//                     color: Colors.orange[300],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'No data available for this session',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final dateFormat = DateFormat('MMMM d, yyyy');
//           final timeFormat = DateFormat('h:mm a');

//           return Column(
//             children: [
//               // Session info card
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           session.name,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         if (session.notes != null &&
//                             session.notes!.isNotEmpty) ...[
//                           Text(
//                             session.notes!,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 14,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               dateFormat.format(session.date),
//                               style: TextStyle(color: Colors.grey[600]),
//                             ),
//                             const SizedBox(width: 16),
//                             Icon(
//                               Icons.access_time,
//                               size: 14,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               timeFormat.format(session.date),
//                               style: TextStyle(color: Colors.grey[600]),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Data Points: ${dataPoints.length}',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // Stats card
//               if (dataPoints.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           _buildStatItem(
//                             'Min',
//                             _findMinValue(dataPoints).toStringAsFixed(2),
//                             Icons.arrow_downward,
//                             Colors.blue,
//                           ),
//                           _buildStatItem(
//                             'Max',
//                             _findMaxValue(dataPoints).toStringAsFixed(2),
//                             Icons.arrow_upward,
//                             Colors.red,
//                           ),
//                           _buildStatItem(
//                             'Avg',
//                             _calculateAverage(dataPoints).toStringAsFixed(2),
//                             Icons.show_chart,
//                             Colors.green,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//               // Chart
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SfCartesianChart(
//                     primaryXAxis: DateTimeAxis(
//                       intervalType: DateTimeIntervalType.auto,
//                       majorGridLines: const MajorGridLines(width: 0),
//                       title: AxisTitle(text: 'Time'),
//                     ),
//                     primaryYAxis: NumericAxis(
//                       axisLine: const AxisLine(width: 0),
//                       majorTickLines: const MajorTickLines(size: 0),
//                       title: AxisTitle(text: 'Value'),
//                     ),
//                     legend: Legend(isVisible: false),
//                     tooltipBehavior: TooltipBehavior(enable: true),
//                     zoomPanBehavior: ZoomPanBehavior(
//                       enablePinching: true,
//                       enablePanning: true,
//                       enableDoubleTapZooming: true,
//                     ),
//                     series: <CartesianSeries>[
//                       LineSeries<BleDataPoint, DateTime>(
//                         dataSource: dataPoints,
//                         xValueMapper: (BleDataPoint data, _) => data.timestamp,
//                         yValueMapper: (BleDataPoint data, _) => data.value,
//                         name: 'Value',
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error:
//             (e, stack) => Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, color: Colors.red, size: 48),
//                   const SizedBox(height: 16),
//                   Text('Error loading session: $e'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed:
//                         () => ref.refresh(sessionWithDataProvider(sessionId)),
//                     child: const Text('Try Again'),
//                   ),
//                 ],
//               ),
//             ),
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Icon(icon, color: color),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: color,
//             fontSize: 16,
//           ),
//         ),
//         Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//       ],
//     );
//   }

//   double _findMinValue(List<BleDataPoint> dataPoints) {
//     return dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
//   }

//   double _findMaxValue(List<BleDataPoint> dataPoints) {
//     return dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
//   }

//   double _calculateAverage(List<BleDataPoint> dataPoints) {
//     final sum = dataPoints.fold<double>(0, (sum, point) => sum + point.value);
//     return sum / dataPoints.length;
//   }
// }
