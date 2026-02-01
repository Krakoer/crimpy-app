import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/app_info_view_model.dart';

/// Dialog that shows what's new in the latest version of the app
class WhatsNewDialog extends ConsumerWidget {
  const WhatsNewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfoAsync = ref.watch(appInfoProvider);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.new_releases, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('What\'s New'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appInfoAsync.when(
              data:
                  (appInfo) => Text(
                    'Version ${appInfo.version}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              '📅 Calendar View',
              'Navigate your training sessions with the new calendar view and prev/next week buttons',
            ),
            _buildFeatureItem(
              context,
              '📊 Waveform Visualization',
              'See waveform visualization for repeater trainings to better understand your performance',
            ),
            _buildFeatureItem(
              context,
              '⚡ Preparation Reps',
              'Trainings now include preparation reps at the start with clear PREPARATION text',
            ),
            _buildFeatureItem(
              context,
              '📱 Enhanced Navigation',
              'Smoother navigation with swipe support and removed animation lag',
            ),
            _buildFeatureItem(
              context,
              '🐛 Bug Reporter',
              'Easily report bugs and send feedback directly from the settings screen',
            ),
            _buildFeatureItem(
              context,
              '✏️ Edit Session Times',
              'Set custom times when logging sessions and edit them later',
            ),
            _buildFeatureItem(
              context,
              '🗑️ Delete Sessions',
              'Added ability to delete sessions you no longer need',
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for using Crimpy!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Got it!'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
