import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  bool _isSending = false;
  String? _errorMessage;
  String? _sentTo;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).requestPasswordReset(email);
      if (mounted) setState(() => _sentTo = email);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CrimpyTheme.spaceXl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: CrimpyTheme.spaceXxl),
                Text(
                  'Reset your password',
                  style: CrimpyTheme.title.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CrimpyTheme.spaceSm),
                Text(
                  'Enter the email you signed up with and we will send you a '
                  'link to choose a new password. The link is valid for one '
                  'hour.',
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CrimpyTheme.spaceXxl),
                if (_sentTo != null)
                  Container(
                    padding: const EdgeInsets.all(CrimpyTheme.spaceMd),
                    decoration: BoxDecoration(
                      color: CrimpyTheme.bgSuccess,
                      borderRadius: CrimpyTheme.corners,
                      border: Border.all(color: CrimpyTheme.statusSuccess),
                    ),
                    child: Text(
                      'If an account exists for $_sentTo, a reset link is on '
                      'its way. Open it, choose a new password, then come back '
                      'here to log in.',
                      style: TextStyle(
                        color: CrimpyTheme.textOn(CrimpyTheme.statusSuccess),
                      ),
                    ),
                  )
                else ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !_isSending,
                    decoration: const InputDecoration(
                      labelText: 'Email',
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
                    onFieldSubmitted: (_) => _handleSend(),
                  ),
                  const SizedBox(height: CrimpyTheme.spaceXl),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(CrimpyTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: CrimpyTheme.bgError,
                        borderRadius: CrimpyTheme.corners,
                        border: Border.all(color: CrimpyTheme.statusError),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: CrimpyTheme.statusErrorText),
                      ),
                    ),
                    const SizedBox(height: CrimpyTheme.spaceXl),
                  ],
                  ElevatedButton(
                    onPressed: _isSending ? null : _handleSend,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: CrimpyTheme.spaceLg,
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send reset link'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
