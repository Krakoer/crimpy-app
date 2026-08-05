import 'package:crimpy/models/notification_preferences.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _weekdayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

/// Lets the user configure the daily reminder for the trainings their coach
/// scheduled: when it fires, on which days, and which days the flexible
/// "X times per week" trainings are reminded on.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Training reminders')),
      body: switch (preferences) {
        AsyncData(:final value) => _Content(preferences: value),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Content extends ConsumerWidget {
  final NotificationPreferences preferences;

  const _Content({required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = preferences.enabled;

    final permissionRevoked =
        enabled && ref.watch(reminderPermissionProvider).asData?.value == false;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (permissionRevoked) const _PermissionWarning(),
        SwitchListTile(
          title: const Text('Training reminders'),
          subtitle: const Text(
            'A daily notification listing what your coach scheduled',
          ),
          value: enabled,
          onChanged: (value) => _setEnabled(context, ref, value),
        ),
        const Divider(),
        _TimeTile(
          title: 'Reminder time',
          time: preferences.primaryTime,
          enabled: enabled,
          onChanged: (time) => ref
              .read(notificationPreferencesControllerProvider.notifier)
              .setPrimaryTime(time),
        ),
        SwitchListTile(
          title: const Text('Second reminder'),
          subtitle: const Text('Nudge again later in the day'),
          value: preferences.secondaryTime != null,
          onChanged: enabled
              ? (value) => ref
                    .read(notificationPreferencesControllerProvider.notifier)
                    .setSecondaryTime(value ? const ReminderTime(19, 0) : null)
              : null,
        ),
        if (preferences.secondaryTime != null)
          _TimeTile(
            title: 'Second reminder time',
            time: preferences.secondaryTime!,
            enabled: enabled,
            onChanged: (time) => ref
                .read(notificationPreferencesControllerProvider.notifier)
                .setSecondaryTime(time),
          ),
        const Divider(),
        _SectionTitle('Days'),
        _WeekdaySelector(
          selected: preferences.activeWeekdays,
          enabled: enabled,
          onChanged: (days) => ref
              .read(notificationPreferencesControllerProvider.notifier)
              .setActiveWeekdays(days),
        ),
        const Divider(),
        _FlexibleTrainings(preferences: preferences),
        if (enabled && hasBatteryOptimization) ...[
          const Divider(),
          _SectionTitle('Troubleshooting'),
          const _BatteryOptimizationTile(),
        ],
      ],
    );
  }

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final granted = await ref
        .read(notificationPreferencesControllerProvider.notifier)
        .setEnabled(value);
    if (granted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Notifications are blocked. Enable them for Crimpy in your device settings.',
        ),
      ),
    );
  }
}

/// Many Android makers stop background alarms to save battery, which delays or
/// drops reminders on a device that is otherwise set up correctly. Only the
/// user can lift that, and only from the system settings.
class _BatteryOptimizationTile extends StatelessWidget {
  const _BatteryOptimizationTile();

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.battery_saver),
    title: const Text('Reminders arriving late or not at all?'),
    subtitle: const Text(
      'Some phones pause background alarms to save battery. Allow Crimpy to '
      'run in the background to fix it.',
    ),
    trailing: const Icon(Icons.open_in_new),
    onTap: openBatteryOptimizationSettings,
  );
}

/// Reminders can be on here while the OS drops every one of them, which looks
/// exactly like the feature being broken.
class _PermissionWarning extends StatelessWidget {
  const _PermissionWarning();

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(
      Icons.notifications_off,
      color: CrimpyTheme.warningColor,
    ),
    title: const Text('Notifications are blocked'),
    subtitle: const Text(
      'Reminders are on, but your device settings prevent Crimpy from showing them.',
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: CrimpyTheme.textSecondary,
        letterSpacing: 0.8,
      ),
    ),
  );
}

class _TimeTile extends StatelessWidget {
  final String title;
  final ReminderTime time;
  final bool enabled;
  final ValueChanged<ReminderTime> onChanged;

  const _TimeTile({
    required this.title,
    required this.time,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    title: Text(title),
    trailing: Text(
      time.toString(),
      style: Theme.of(context).textTheme.titleMedium,
    ),
    onTap: enabled ? () => _pick(context) : null,
  );

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
    );
    if (picked == null) return;
    onChanged(ReminderTime(picked.hour, picked.minute));
  }
}

class _WeekdaySelector extends StatelessWidget {
  final Set<int> selected;
  final bool enabled;

  /// Days the user is allowed to pick. Days outside it are shown disabled
  /// rather than hidden, so the week keeps its shape.
  final Set<int> selectableDays;
  final ValueChanged<Set<int>> onChanged;

  const _WeekdaySelector({
    required this.selected,
    required this.enabled,
    required this.onChanged,
    this.selectableDays = allWeekdays,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Wrap(
      spacing: 8,
      children: [
        for (var day = 0; day < _weekdayLabels.length; day++) _chip(day),
      ],
    ),
  );

  Widget _chip(int day) {
    final selectable = selectableDays.contains(day);
    return FilterChip(
      label: Text(_weekdayLabels[day]),
      selected: selectable && selected.contains(day),
      onSelected: enabled && selectable ? (value) => _toggle(day, value) : null,
    );
  }

  void _toggle(int day, bool value) {
    // Days that fell out of the selectable set go with the first edit, so the
    // stored choice never keeps a day the plan would ignore.
    final updated = {...selected.where(selectableDays.contains)};
    if (value) {
      updated.add(day);
    } else {
      updated.remove(day);
    }
    // An empty selection would silently disable every reminder.
    if (updated.isEmpty) return;
    onChanged(updated);
  }
}

/// Flexible trainings carry no day of their own, so the user picks the days
/// they want to be reminded on. Unconfigured ones show their default spread.
class _FlexibleTrainings extends ConsumerWidget {
  final NotificationPreferences preferences;

  const _FlexibleTrainings({required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(programScheduleCacheProvider).asData?.value;
    if (schedule == null) return const SizedBox.shrink();

    final week = schedule.weekNumbered(
      schedule.program.currentWeekNumber(DateTime.now()),
    );
    final flexible = week?.timesPerWeekSessions ?? const <WeekSession>[];
    if (flexible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle('Flexible trainings'),
        for (final session in flexible)
          _FlexibleTrainingTile(
            session: session,
            preferences: preferences,
            enabled: preferences.enabled,
          ),
      ],
    );
  }
}

class _FlexibleTrainingTile extends ConsumerWidget {
  final WeekSession session;
  final NotificationPreferences preferences;
  final bool enabled;

  const _FlexibleTrainingTile({
    required this.session,
    required this.preferences,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = session.timesPerWeek ?? 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          enabled: enabled,
          title: Text(session.trainingTitle),
          subtitle: Text('$target x / week'),
        ),
        // A day the reminder never fires on cannot carry a flexible training
        // either: the plan drops it before it looks at these days.
        _WeekdaySelector(
          selected: preferences.flexibleDaysFor(session.trainingId, target),
          enabled: enabled,
          selectableDays: preferences.activeWeekdays,
          onChanged: (days) => ref
              .read(notificationPreferencesControllerProvider.notifier)
              .setFlexibleDays(session.trainingId, days),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
