import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emails the signed-in athlete a link to choose a new password. Shown only
/// with an account: a guest has no password to reset.
class ResetPasswordTile extends ConsumerStatefulWidget {
  const ResetPasswordTile({super.key});

  @override
  ConsumerState<ResetPasswordTile> createState() => _ResetPasswordTileState();
}

class _ResetPasswordTileState extends ConsumerState<ResetPasswordTile> {
  bool _isSending = false;

  Future<void> _confirmAndSend(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password?'),
        content: Text(
          'We will email a link to $email to choose a new password. The link '
          'is valid for one hour. Once the new password is set, every device '
          'signed in to your account is signed out, this one included.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authStateProvider.notifier).requestPasswordReset(email);
      messenger.showSnackBar(
        SnackBar(content: Text('Reset link sent to $email')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.lock_reset),
      title: const Text('Reset password'),
      subtitle: const Text('Get an email with a link to choose a new one'),
      trailing: _isSending
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _isSending ? null : () => _confirmAndSend(user.email),
    );
  }
}
