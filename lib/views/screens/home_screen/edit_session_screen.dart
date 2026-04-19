import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session.notes ?? '');
    _selectedDate = widget.session.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.session.date);
    _durationMinutes = widget.session.duration ~/ 60;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.session.sessionType.colorValue);
    final isCrimpySession = widget.session.sessionType == SessionType.crimpy;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCrimpySession
              ? 'Edit Notes'
              : 'Edit ${widget.session.sessionType.displayName}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info message for Crimpy sessions
              if (isCrimpySession) ...[
                Card(
                  color: color.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Only notes can be edited for Crimpy training sessions',
                            style: TextStyle(fontSize: 13, color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Date picker (disabled for Crimpy sessions)
              Card(
                child: ListTile(
                  enabled: !isCrimpySession,
                  leading: Icon(
                    Icons.calendar_today,
                    color: isCrimpySession ? Colors.grey : color,
                  ),
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  ),
                  trailing: isCrimpySession
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: isCrimpySession ? null : _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Time picker (disabled for Crimpy sessions)
              Card(
                child: ListTile(
                  enabled: !isCrimpySession,
                  leading: Icon(
                    Icons.access_time,
                    color: isCrimpySession ? Colors.grey : color,
                  ),
                  title: const Text('Time'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: isCrimpySession
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: isCrimpySession ? null : _selectTime,
                ),
              ),
              const SizedBox(height: 16),

              // Duration input (disabled for Crimpy sessions)
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
                            color: isCrimpySession ? Colors.grey : color,
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
                        enabled: !isCrimpySession,
                        initialValue: _durationMinutes.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          suffixText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: isCrimpySession
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
                          if (!isCrimpySession) {
                            _durationMinutes = int.parse(value!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
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
                          Icon(Icons.notes, color: color),
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
                child: Text(
                  isCrimpySession ? 'Update Notes' : 'Update Session',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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

    // Combine selected date with selected time
    final sessionDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedSession = SessionModel(
      id: widget.session.id,
      name: widget.session.name,
      isAssessment: widget.session.isAssessment,
      sessionType: widget.session.sessionType,
      durationInSeconds: _durationMinutes * 60,
      date: sessionDateTime,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      reps: widget.session.reps,
      dataPoints: widget.session.dataPoints,
    );

    try {
      // Update session in database
      await ref.read(sessionsProvider.notifier).updateSession(updatedSession);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.session.sessionType.displayName} session updated!',
            ),
            backgroundColor: Color(widget.session.sessionType.colorValue),
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
