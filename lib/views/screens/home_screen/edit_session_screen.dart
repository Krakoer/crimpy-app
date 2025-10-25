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
  late int _durationMinutes;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session.notes ?? '');
    _selectedDate = widget.session.date;
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.session.sessionType.displayName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date picker
              Card(
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: color),
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Duration input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: color),
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
                        initialValue: _durationMinutes.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          suffixText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
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
                          _durationMinutes = int.parse(value!);
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

  Future<void> _updateSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final updatedSession = SessionModel(
      id: widget.session.id,
      name: widget.session.name,
      isAssessment: widget.session.isAssessment,
      sessionType: widget.session.sessionType,
      durationInSeconds: _durationMinutes * 60,
      date: _selectedDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      reps: widget.session.reps,
      dataPoints: widget.session.dataPoints,
    );

    try {
      // Update session in database
      await ref
          .read(sessionsProvider(null).notifier)
          .updateSession(updatedSession);

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
