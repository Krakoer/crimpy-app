import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Asks how many reps an AMRAP turned out to be. The step prescribes no count,
/// so nothing but the athlete knows it, and the run cannot move on until they
/// say. Returns null when they back out, which leaves the step where it was.
Future<int?> showOpenRepsDialog(BuildContext context, String label) =>
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OpenRepsDialog(label: label),
    );

/// Owns the field the count is typed into, so it lives exactly as long as the
/// dialog does. Disposing it when the dialog's future completes would take it
/// away while the route is still animating out and still building the field.
class _OpenRepsDialog extends StatefulWidget {
  final String label;

  const _OpenRepsDialog({required this.label});

  @override
  State<_OpenRepsDialog> createState() => _OpenRepsDialogState();
}

class _OpenRepsDialogState extends State<_OpenRepsDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final entered = int.tryParse(_controller.text.trim());
    if (entered != null && entered >= 0) Navigator.of(context).pop(entered);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('How many did you manage?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Reps',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(onPressed: _submit, child: const Text('Save')),
    ],
  );
}

/// Confirms that the athlete is dropping out of an emom, since it ends the
/// block: the rounds it still had queued are not played.
Future<bool> confirmEmomDropOut(BuildContext context, int roundsDone) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Stop this block?'),
      content: Text(
        roundsDone == 0
            ? 'No round is recorded as completed and the block ends here.'
            : '$roundsDone completed ${roundsDone == 1 ? 'round' : 'rounds'} '
                  'are recorded and the block ends here.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep going'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: CrimpyTheme.statusError),
          child: const Text('Stop'),
        ),
      ],
    ),
  );
  return answer ?? false;
}
