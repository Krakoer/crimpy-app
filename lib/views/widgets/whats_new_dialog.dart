import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
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
          Icon(
            Icons.new_releases,
            color: CrimpyTheme.markOn(CrimpyTheme.newsMark),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
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
                style: CrimpyTheme.title.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CrimpyTheme.textOn(CrimpyTheme.newsMark),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: CrimpyTheme.spaceLg),
            _buildFeatureItem(
              context,
              'Critical Force by the published definition',
              'Critical Force is now the mean force of your last 6 pulls, as in Tindeq, Lattice and the research, and only force inside each 7 second pull counts. New results read about 40 % higher than the ones before, which are kept as they were and not recomputed.',
            ),
            _buildFeatureItem(
              context,
              'Critical Force starts on your first pull',
              'After the countdown the test waits for you to take the edge, so a late start no longer costs you part of pull 1. You can also finish after pull 16 and keep the result.',
            ),
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
            const SizedBox(height: CrimpyTheme.spaceSm),
            Text(
              'Thank you for using Crimpy!',
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Got it'),
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
      padding: const EdgeInsets.only(bottom: CrimpyTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: CrimpyTheme.markOn(CrimpyTheme.statusSuccess),
            size: 20,
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CrimpyTheme.titleSmall.copyWith(
                    color: CrimpyTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: CrimpyTheme.spaceXs),
                Text(
                  description,
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
