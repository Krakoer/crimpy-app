import 'package:crimpy/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/main_page.dart';
import 'theme/crimpy_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();
  FlutterBluePlus.setLogLevel(LogLevel.warning, color: true);
  AppLoggerHelper.initialize();

  // Only initialize Sentry in release mode
  if (kDebugMode) {
    runApp(const ProviderScope(child: MyApp()));
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://3fb9714e651c93e73c5c03493392c336@o4510493921705984.ingest.de.sentry.io/4510750311514192';
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
      appRunner:
          () =>
              runApp(SentryWidget(child: const ProviderScope(child: MyApp()))),
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
