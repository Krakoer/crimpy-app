import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class AnalysisErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  const AnalysisErrorScreen({
    this.errorMessage,
    this.onRetry,
    this.onDiscard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analysis Error")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 24),
              Text(
                "Analysis Failed",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "We couldn't analyze your critical force data. This could be due to insufficient data quality or technical issues.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (errorMessage != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CrimpyTheme.bgError,
                    border: Border.all(
                      color: CrimpyTheme.statusError,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "Error details: $errorMessage",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CrimpyTheme.textOn(CrimpyTheme.statusError),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 32),
              Text(
                "Your session data has been saved for debugging purposes.",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text("Retry Analysis"),
            ),
          TextButton.icon(
            onPressed: onDiscard ?? () => Navigator.of(context).pop(),
            icon: Icon(Icons.close),
            label: Text("Close"),
          ),
        ],
      ),
    );
  }
}
