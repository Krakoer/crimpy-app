import 'package:crimpy/services/local_data_migration.dart';
import 'package:crimpy/logger.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/auth/forgot_password_screen.dart';
import 'package:crimpy/views/screens/auth/registration_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Names what is left to import, leaving out the parts there are none of: a
  /// retry after a partial run often has only one kind of row still to go, and
  /// offering to import "0 session(s)" reads like a bug.
  String _localDataSummary(LocalImportStatus status) {
    final parts = [
      if (status.sessionCount > 0) '${status.sessionCount} session(s)',
      if (status.trainingCount > 0) '${status.trainingCount} training(s)',
      if (status.otherCount > 0) '${status.otherCount} saved preference(s)',
    ];
    if (parts.length == 1) return parts.single;
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }

  void _showImportFailure(int failures) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$failures item(s) could not be imported. Your local data was kept.',
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);

      // Check for local data before login so we can offer import
      final localStatus = await authNotifier.checkLocalDataBeforeLogin();

      await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (localStatus.hasData) {
        final shouldImport = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Import local data?'),
            content: Text(
              'You have ${_localDataSummary(localStatus)} stored locally. '
              'Import them to your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Skip'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (!mounted) return;

        // Local data is only cleared once it is safely on the server. Skipping
        // the import, or a partial failure, keeps the local copy intact.
        if (shouldImport == true) {
          setState(() => _isLoading = true);
          final failures = await authNotifier.importLocalDataToApi();
          if (!mounted) return;
          // The import wrote to the account through the API, behind the
          // providers that had already read it: signing in flips
          // isAuthenticated, which rebuilds the repositories and lets the
          // screens fetch, and that happens before the upload rather than
          // after. Whatever went up is invisible until these are dropped.
          //
          // Dropped on both branches. A partial failure still imported the
          // rows that did not fail, and it is the branch that never reaches
          // clearLocalDataAfterLogin, so it is the one where nothing else
          // cycles the graph.
          ref.invalidate(assessmentHistoryProvider);
          ref.invalidate(trainingLibraryProvider);
          ref.invalidate(builtinTrainingCatalogProvider);
          ref.invalidate(sessionsProvider);
          if (failures == 0) {
            await authNotifier.clearLocalDataAfterLogin();
          } else {
            _showImportFailure(failures);
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        AppLoggerHelper.error(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(
                                initialEmail: _emailController.text.trim(),
                              ),
                            ),
                          ),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CrimpyTheme.bgError,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CrimpyTheme.statusError),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: CrimpyTheme.statusErrorText),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen(),
                                ),
                              );
                            },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
