import 'package:flutter/material.dart';
import '../services/auth_manager.dart';
import '../services/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _saving = false;
  String? _error;
  bool _rememberMe = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final user = _userController.text.trim();
    final pass = _passwordController.text.trim();

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (user.isEmpty || pass.isEmpty) {
        // Bypass: allow quick sign-in without hitting the backend.
        await AuthManager.instance.setTokens(
          const TokenPair(accessToken: 'demo-access', refreshToken: 'demo-refresh'),
          persist: _rememberMe,
        );
      } else {
        await AuthManager.instance.loginWithCredentials(
          username: user,
          password: pass,
          persist: _rememberMe,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 520),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign in', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Leave both fields empty to use demo mode.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saving ? null : _login(),
                    autofillHints: const [AutofillHints.password],
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    title: const Text('Remember me'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _login,
                      child: _saving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
