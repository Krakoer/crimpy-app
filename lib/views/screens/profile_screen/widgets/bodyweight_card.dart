import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the body weight used to turn percent of bodyweight loads into
/// kilograms, and lets the user enter or measure it.
class BodyweightCard extends ConsumerWidget {
  const BodyweightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyweight = ref.watch(bodyweightProvider);
    final value = bodyweight.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Body weight',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value == null
                        ? 'Not set. Needed for loads set in % of body weight.'
                        : '${value.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            bodyweight.isLoading && value == null
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : value == null
                ? ElevatedButton(
                    onPressed: () => showBodyweightDialog(context),
                    child: const Text('Set'),
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showBodyweightDialog(context),
                  ),
          ],
        ),
      ),
    );
  }
}
