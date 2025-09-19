// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../viewmodels/ble_view_model.dart';
// import '../models/training_model.dart';
// import 'session_detail_screen.dart';

// class SessionsScreen extends ConsumerWidget {
//   const SessionsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final sessionsAsync = ref.watch(sessionsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Saved Sessions'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => ref.refresh(sessionsProvider),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           final _ = ref.refresh(sessionsProvider);
//         },
//         child: sessionsAsync.when(
//           data: (sessions) {
//             if (sessions.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.history, size: 60, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'No saved sessions yet',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Connect to a device and record data',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.builder(
//               itemCount: sessions.length,
//               itemBuilder: (context, index) {
//                 final session = sessions[index];
//                 return _buildSessionCard(context, session, ref);
//               },
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error:
//               (e, stack) => Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       color: Colors.red,
//                       size: 48,
//                     ),
//                     const SizedBox(height: 16),
//                     Text('Error loading sessions: $e'),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () => ref.refresh(sessionsProvider),
//                       child: const Text('Try Again'),
//                     ),
//                   ],
//                 ),
//               ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSessionCard(
//     BuildContext context,
//     TrainingModel session,
//     WidgetRef ref,
//   ) {
//     final dateFormat = DateFormat('MMM d, yyyy');
//     final timeFormat = DateFormat('h:mm a');

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SessionDetailScreen(sessionId: session.id!),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       session.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   // PopupMenuButton<String>(
//                   //   onSelected: (value) {
//                   //     if (value == 'delete') {
//                   //       _showDeleteConfirmation(context, session, ref);
//                   //     }
//                   //   },
//                   //   itemBuilder:
//                   //       (context) => [
//                   //         const PopupMenuItem(
//                   //           value: 'delete',
//                   //           child: Row(
//                   //             children: [
//                   //               Icon(Icons.delete, color: Colors.red),
//                   //               SizedBox(width: 8),
//                   //               Text(
//                   //                 'Delete',
//                   //                 style: TextStyle(color: Colors.red),
//                   //               ),
//                   //             ],
//                   //           ),
//                   //         ),
//                   //       ],
//                   // ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               if (session.notes != null && session.notes!.isNotEmpty)
//                 Text(
//                   session.notes!,
//                   style: TextStyle(color: Colors.grey[600]),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
//                   const SizedBox(width: 4),
//                   Text(
//                     dateFormat.format(session.date),
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                   const SizedBox(width: 16),
//                   Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
//                   const SizedBox(width: 4),
//                   Text(
//                     timeFormat.format(session.date),
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // void _showDeleteConfirmation(
//   //   BuildContext context,
//   //   SessionModel session,
//   //   WidgetRef ref,
//   // ) {
//   //   showDialog(
//   //     context: context,
//   //     builder:
//   //         (context) => AlertDialog(
//   //           title: const Text('Delete Session'),
//   //           content: Text(
//   //             'Are you sure you want to delete "${session.title}"?',
//   //           ),
//   //           actions: [
//   //             TextButton(
//   //               onPressed: () => Navigator.of(context).pop(),
//   //               child: const Text('Cancel'),
//   //             ),
//   //             TextButton(
//   //               onPressed: () async {
//   //                 Navigator.of(context).pop();
//   //                 try {
//   //                   await ref
//   //                       .read(bleRepositoryProvider)
//   //                       .deleteSession(session.id!);
//   //                   final _ = ref.refresh(sessionsProvider);
//   //                   if (context.mounted) {
//   //                     ScaffoldMessenger.of(context).showSnackBar(
//   //                       const SnackBar(
//   //                         content: Text('Session deleted successfully'),
//   //                       ),
//   //                     );
//   //                   }
//   //                 } catch (e) {
//   //                   if (context.mounted) {
//   //                     ScaffoldMessenger.of(context).showSnackBar(
//   //                       SnackBar(
//   //                         content: Text('Error deleting session: $e'),
//   //                         backgroundColor: Colors.red,
//   //                       ),
//   //                     );
//   //                   }
//   //                 }
//   //               },
//   //               style: TextButton.styleFrom(foregroundColor: Colors.red),
//   //               child: const Text('Delete'),
//   //             ),
//   //           ],
//   //         ),
//   //   );
//   // }
// }
