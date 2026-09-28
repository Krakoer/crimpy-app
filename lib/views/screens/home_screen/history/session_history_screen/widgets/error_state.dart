import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: CrimpyTheme.statusError,
          ),
          const SizedBox(height: CrimpyTheme.spaceLg),
          Text(
            'Error loading sessions',
            style: CrimpyTheme.title.copyWith(color: CrimpyTheme.textStrong),
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          Text(
            error,
            style: CrimpyTheme.body.copyWith(color: CrimpyTheme.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CrimpyTheme.spaceLg),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
