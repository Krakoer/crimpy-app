import 'dart:io';

import 'package:crimpy/logger.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/utils/dummy_data_generator.dart';
import 'package:crimpy/viewmodels/app_info_view_model.dart';
import 'package:crimpy/views/widgets/whats_new_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void showDebugModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _DebugModalContent(),
  );
}

class _DebugModalContent extends ConsumerWidget {
  const _DebugModalContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Debug',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 24),
              _AppVersionSection(),
              const Divider(height: 24),
              _ReportBugButton(),
              const SizedBox(height: 8),
              _SendLogsButton(),
              if (kDebugMode) ...[
                const Divider(height: 24),
                _DebugToolsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportBugButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => SentryFeedbackWidget.show(context),
        icon: const Icon(FontAwesomeIcons.bullhorn, size: 14),
        label: const Text('Report a bug'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
      ),
    );
  }
}

class _SendLogsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _sendLogs(context, appInfo.asData?.value),
        icon: const Icon(FontAwesomeIcons.envelope, size: 14),
        label: const Text('Send debug logs'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
      ),
    );
  }

  Future<void> _sendLogs(BuildContext context, AppInfo? appInfo) async {
    try {
      final logContent = AppLoggerHelper.getLogsAsText();
      final tempDir = await getTemporaryDirectory();
      final logFile = File('${tempDir.path}/crimpy_debug_logs.txt');
      await logFile.writeAsString(logContent);

      final version = appInfo?.fullVersion ?? 'unknown';
      final mailOptions = MailOptions(
        subject: 'Crimpy debug logs - $version',
        body: 'Debug logs from Crimpy $version attached.',
        recipients: ['contact@crimpy.app'],
        attachments: [logFile.path],
        isHTML: false,
      );

      await FlutterMailer.send(mailOptions);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open email app: $e')));
    }
  }
}

class _AppVersionSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ref
          .watch(appInfoProvider)
          .when(
            data: (appInfo) => Row(
              children: [
                Icon(
                  FontAwesomeIcons.circleInfo,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Crimpy ${appInfo.version} (${appInfo.buildNumber})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Text('Unable to load version info'),
          ),
    );
  }
}

class _DebugToolsSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DebugToolsSection> createState() => _DebugToolsSectionState();
}

class _DebugToolsSectionState extends ConsumerState<_DebugToolsSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Debug Tools',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showWhatsNewDialog,
            icon: const Icon(Icons.new_releases),
            label: const Text("Show What's New Dialog"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _generateDummyData,
            icon: const Icon(Icons.data_array),
            label: const Text('Generate Dummy Data'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _clearAllData,
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Clear All Data'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showWhatsNewDialog() {
    Navigator.of(context).pop();
    showDialog(context: context, builder: (ctx) => const WhatsNewDialog());
  }

  void _generateDummyData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Dummy Data'),
        content: const Text(
          'This will populate your database with sample sessions, trainings, and assessments. '
          'This is useful for testing and taking screenshots.\n\nContinue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final trainingRepository = LocalTrainingRepository();
      final generator = DummyDataGenerator(trainingRepository);
      await generator.generateAllDummyData();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dummy data generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating dummy data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will DELETE all sessions and custom trainings from your database. '
          'This action cannot be undone!\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final trainingRepository = LocalTrainingRepository();
      final generator = DummyDataGenerator(trainingRepository);
      await generator.clearAllData();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
