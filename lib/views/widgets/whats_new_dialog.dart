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
            // The release notes shipped with the build, read once.
            // ignore: keep_the_held_value
            appInfoAsync.when(
              data: (appInfo) => Text(
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
              'Coach programs',
              'Follow the program your coach assigned you, week by week, with today\'s trainings on the home screen.',
            ),
            _buildFeatureItem(
              context,
              'Run any training',
              'Circuits, groups, timed and rep-based exercises can all be run, with or without a force sensor.',
            ),
            _buildFeatureItem(
              context,
              'Guided workouts',
              'Audio countdown cues, an on-target indicator and coach comments shown during each step.',
            ),
            _buildFeatureItem(
              context,
              'Screen stays awake',
              'The screen no longer turns off in the middle of a workout.',
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
