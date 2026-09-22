import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/models/session_rpe.dart';
import 'package:crimpy/views/widgets/session_rpe_picker.dart';

class EditSessionScreen extends ConsumerStatefulWidget {
  final SessionModel session;

  const EditSessionScreen({super.key, required this.session});

  @override
  ConsumerState<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends ConsumerState<EditSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _durationMinutes;
  late SessionRpeAnswer _rpe;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session.notes ?? '');
    _selectedDate = widget.session.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.session.date);
    _durationMinutes = widget.session.duration ~/ 60;
    _rpe = SessionRpeAnswer.of(
      rpe: widget.session.rpe,
      rpeFailed: widget.session.rpeFailed,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = CrimpyTheme.activityColor(widget.session.activity);
    // The icons sit on a white Card, where climbing's gold reads 2.25:1 and
    // misses the 3:1 mark floor. The tint and the fill below keep the accent,
    // since a ground is not a mark. See Krakoer/crimpy#128.
    final markColor = CrimpyTheme.markOn(color);
    final textColor = CrimpyTheme.activityTextColor(widget.session.activity);
    // A played session owns its date, duration and reps: they are what the run
    // measured, so only the notes are open for editing. What was trained has no
    // say in it, which is why this reads the origin and not the activity.
    final isPlayedSession = widget.session.origin.isPlayed;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.session.activity.displayName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info message for played sessions
              if (isPlayedSession) ...[
                Card(
                  color: color.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: textColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Only the notes and the RPE can be edited for a session played in the app',
                            style: TextStyle(fontSize: 13, color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Date picker (disabled for played sessions)
              Card(
                child: ListTile(
                  enabled: !isPlayedSession,
                  leading: Icon(
                    Icons.calendar_today,
                    color: isPlayedSession ? CrimpyTheme.textMuted : markColor,
                  ),
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  ),
                  trailing: isPlayedSession
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: isPlayedSession ? null : _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Time picker (disabled for played sessions)
              Card(
                child: ListTile(
                  enabled: !isPlayedSession,
                  leading: Icon(
                    Icons.access_time,
                    color: isPlayedSession ? CrimpyTheme.textMuted : markColor,
                  ),
                  title: const Text('Time'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: isPlayedSession
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: isPlayedSession ? null : _selectTime,
                ),
              ),
              const SizedBox(height: 16),

              // Duration input (disabled for played sessions)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: isPlayedSession
                                ? CrimpyTheme.textMuted
                                : markColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        enabled: !isPlayedSession,
                        initialValue: _durationMinutes.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          suffixText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: isPlayedSession
                            ? null
                            : (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a duration';
                                }
                                final minutes = int.tryParse(value);
                                if (minutes == null || minutes <= 0) {
                                  return 'Please enter a valid duration';
                                }
                                return null;
                              },
                        onSaved: (value) {
                          if (!isPlayedSession) {
                            _durationMinutes = int.parse(value!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Offered whatever the origin: the RPE is what the athlete
              // reported about the session, not something the run measured, and
              // forgetting it at the end of a run is the normal case this
              // screen exists to fix.
              SessionRpePicker(
                answer: _rpe,
                onChanged: (answer) => setState(() => _rpe = answer),
                subtitle:
                    'How much recovery did this session cost you? '
                    'You can answer now even if you skipped it at the time.',
              ),
              const SizedBox(height: 16),

              // Notes input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes, color: markColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'Add any details about your session...',
                        ),
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _updateSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Session',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    // Empty rather than null: null would read as "leave the notes alone" and
    // make clearing them impossible.
    final notes = _notesController.text;

    // A played session owns its date and duration, and the form only shows them
    // read only, so the edit carries the notes and nothing else. Leaving the
    // other fields out of copyWith keeps the values the run measured, down to
    // the seconds the pickers would have dropped.
    final edited = widget.session.origin.isPlayed
        ? widget.session.copyWith(notes: notes)
        : widget.session.copyWith(
            durationInSeconds: _durationMinutes * 60,
            date: DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            ),
            notes: notes,
          );

    // Applied apart from copyWith, which carries a field over when it is given
    // none and so cannot take an answer back.
    final updatedSession = edited.withSessionRpe(
      rpe: _rpe.rpe,
      rpeFailed: _rpe.failed,
    );

    try {
      // Update session in database
      await ref.read(sessionsProvider.notifier).updateSession(updatedSession);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.session.activity.displayName} session updated!',
            ),
            backgroundColor: CrimpyTheme.activityColor(widget.session.activity),
          ),
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Pop detail screen too to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating session: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
