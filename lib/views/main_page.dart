import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/views/screens/assessments/assessments_list_screen/assessments_list_screen.dart';
import 'package:crimpy/views/screens/profile_screen/profile_screen.dart';
import 'package:crimpy/views/widgets/ble/tare_dialog.dart';
import 'package:crimpy/views/screens/chart_screen.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/trainings_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/views/screens/home_screen/home_screen.dart';
import 'package:crimpy/views/screens/settings_screen/settings_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../viewmodels/ble_view_model.dart';
import '../viewmodels/app_info_view_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/notification_view_model.dart';
import '../viewmodels/training_view_model.dart';
import '../viewmodels/coach_view_model.dart';
import 'widgets/ble/connection_dialog.dart';
import 'widgets/coach_notification_dialog.dart';
import 'widgets/whats_new_dialog.dart';

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isSelected
        ? primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 2,
              color: isSelected ? primary : Colors.transparent,
            ),
            const SizedBox(height: 10),
            FaIcon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with WidgetsBindingObserver {
  int currentPageIndex = 0;
  final _pageViewController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkForUpdates();
      // After the release notes rather than beside them: both are dialogs, and
      // the athlete should not be answering two of them at once.
      await _askForCoachNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Coming back to the app is the moment the plan may have gone stale: a day
    // has passed, or a training was logged elsewhere. The cached schedule goes
    // with it, since its three week window is pinned at the time it was built
    // and the coach may have published a new week since.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(programScheduleCacheProvider);
      ref.invalidate(trainingReminderSyncProvider);
      // A reply written while the app was in the background only shows up on
      // the next fetch, so the history is what has to be refreshed here. Guest
      // mode has no coach to answer, and nothing else here needs the refetch.
      if (ref.read(isAuthenticatedProvider)) ref.invalidate(sessionsProvider);
    }
  }

  /// Asks which hour to postpone the reminder to. An hour already gone means
  /// tomorrow, so picking 8am in the evening still does something sensible.
  Future<void> _askSnoozeTime() async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      helpText: 'Remind me again at',
    );
    if (picked == null || !mounted) return;

    var when = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );
    final tomorrow = !when.isAfter(now);
    if (tomorrow) {
      when = DateTime(
        now.year,
        now.month,
        now.day + 1,
        picked.hour,
        picked.minute,
      );
    }

    await ref
        .read(notificationPreferencesControllerProvider.notifier)
        .snoozeUntil(when);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder postponed to ${picked.format(context)}'
          '${tomorrow ? ' tomorrow' : ''}',
        ),
      ),
    );
  }

  /// Asks a coached athlete to allow the notifications their coach's answers
  /// are delivered through, explaining what they are before the OS sheet does
  /// not. Answered once per reason: an athlete who declines is not asked again
  /// for the same one on the next launch.
  Future<void> _askForCoachNotifications() async {
    final prompt = await ref.read(
      pendingCoachNotificationPromptProvider.future,
    );
    if (prompt == null || !mounted) return;

    final enrollment = await ref.read(coachEnrollmentProvider.future);
    if (enrollment == null || !mounted) return;

    // Recorded before the OS is asked: whichever way the athlete answers, and
    // whatever the sheet does after, they have now been asked this once.
    await ref.read(coachNotificationPromptServiceProvider).markAsked(prompt);
    if (!mounted) return;

    final wanted = await showDialog<bool>(
      context: context,
      builder: (context) => CoachNotificationDialog(
        prompt: prompt,
        coachName: enrollment.coachName,
      ),
    );
    if (wanted != true || !mounted) return;

    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (!mounted) return;

    if (granted) {
      // The announcer skipped every answer it could not deliver, so the unread
      // ones are still waiting to be raised.
      ref.invalidate(reminderPermissionProvider);
      ref.invalidate(coachReplySyncProvider);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Notifications are blocked. Enable them for Crimpy in your device settings.',
        ),
      ),
    );
  }

  /// Check if the app has been updated and show the "What's New" dialog
  Future<void> _checkForUpdates() async {
    final whatsNewManager = ref.read(whatsNewProvider);
    final shouldShow = await whatsNewManager.shouldShowWhatsNew();

    if (shouldShow && mounted) {
      await showDialog(
        context: context,
        builder: (context) => const WhatsNewDialog(),
      );
      // Mark this version as seen
      await whatsNewManager.markVersionSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    // Keeps the reminder plan in step with the settings, the coach program and
    // the logged sessions for as long as the app is running.
    ref.watch(trainingReminderSyncProvider);
    // Tells the athlete about an answer their coach wrote, for as long as the
    // app is running.
    ref.watch(coachReplySyncProvider);
    // Snoozing from the notification brings the app up so the hour can be
    // picked, which cannot happen from the notification itself.
    ref.listen(snoozeRequestsProvider, (_, next) {
      if (next.hasValue) _askSnoozeTime();
    });

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              _NavItem(
                icon: FontAwesomeIcons.house,
                label: 'Home',
                isSelected: currentPageIndex == 0,
                onTap: () => _pageViewController.jumpToPage(0),
              ),
              _NavItem(
                icon: FontAwesomeIcons.fire,
                label: 'Trainings',
                isSelected: currentPageIndex == 1,
                onTap: () => _pageViewController.jumpToPage(1),
              ),
              _NavItem(
                icon: FontAwesomeIcons.chartSimple,
                label: 'Assess.',
                isSelected: currentPageIndex == 2,
                onTap: () => _pageViewController.jumpToPage(2),
              ),
              _NavItem(
                icon: FontAwesomeIcons.user,
                label: 'Profile',
                isSelected: currentPageIndex == 3,
                onTap: () => _pageViewController.jumpToPage(3),
              ),
              _NavItem(
                icon: FontAwesomeIcons.gear,
                label: 'Settings',
                isSelected: currentPageIndex == 4,
                onTap: () => _pageViewController.jumpToPage(4),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          const [
            'Crimpy',
            'Trainings',
            'Assessments',
            'Profile',
            'Settings',
          ][currentPageIndex],
        ),
        actions: [
          // Live data button when connected
          IconButton(
            onPressed:
                ref.watch(connectionStateProvider) !=
                    BleConnectionState.connected
                ? null
                : () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (ctx) => ChartScreen())),
            icon: Icon(FontAwesomeIcons.chartLine),
          ),
          // Connection status icon in app bar
          IconButton(
            icon: Icon(_getConnectionIcon(connectionState)),
            onPressed: () => _showConnectionDialog(context),
          ),
        ],
      ),
      body: PageView(
        controller: _pageViewController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: <Widget>[
          HomeScreen(),
          TrainingScreen(
            goToAssessments: () => _pageViewController.jumpToPage(2),
          ),
          AssessmentsScreen(),
          ClimbingProfileScreen(
            goToAssessments: () => _pageViewController.jumpToPage(2),
          ),
          SettingsScreen(),
        ],
      ),
    );
  }

  IconData _getConnectionIcon(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return Icons.bluetooth_connected;
      case BleConnectionState.connecting:
        return Icons.bluetooth_searching;
      case BleConnectionState.failed:
        return Icons.bluetooth_disabled;
      case BleConnectionState.disconnected:
        return Icons.bluetooth_disabled;
    }
  }

  void _showConnectionDialog(BuildContext context) async {
    final isConnected = await showDialog(
      context: context,
      builder: (context) => const ConnectionDialog(),
    );
    if (isConnected != null && isConnected && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => const TareDialog(),
        barrierDismissible: false,
      );
    }
  }
}
