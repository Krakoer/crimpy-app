import 'package:crimpy/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/main_page.dart';
import 'theme/crimpy_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Riverpod retries every failed provider indefinitely by default. Requests
/// that fail because the device is offline would otherwise keep backing off in
/// the background for the whole session, so cap the attempts.
Duration? boundedRetry(int retryCount, Object error) {
  const maxAttempts = 3;
  if (retryCount >= maxAttempts) return null;
  return Duration(milliseconds: 500 * (1 << retryCount));
}

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();
  FlutterBluePlus.setLogLevel(LogLevel.warning, color: true);
  AppLoggerHelper.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Debug and profile builds are the ones run from the editor, where every error
  // is already on screen. Reporting them would only add noise to Sentry.
  if (!kReleaseMode) {
    runApp(ProviderScope(retry: boundedRetry, child: const MyApp()));
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://3fb9714e651c93e73c5c03493392c336@o4510493921705984.ingest.de.sentry.io/4510750311514192';
        // Keeps the month long beta test separable from production in Sentry.
        // appFlavor is null for the desktop targets, which build no flavors.
        options.environment = appFlavor ?? 'unflavored';
        // Adds request headers and IP for users, for more info visit:
        // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
        options.sendDefaultPii = true;
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;
        // The sampling rate for profiling is relative to tracesSampleRate
        // Setting to 1.0 will profile 100% of sampled transactions:
        // options.profilesSampleRate = 1.0;
      },
      appRunner: () => runApp(
        ProviderScope(
          retry: boundedRetry,
          child: SentryWidget(child: const MyApp()),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'crimpy',
      theme: CrimpyTheme.lightTheme,
      home: MainPage(),
    );
  }
}
