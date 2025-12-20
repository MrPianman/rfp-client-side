import 'package:flutter/material.dart';
import '../services/auth_manager.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.loggedInBuilder});

  final WidgetBuilder loggedInBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthSnapshot>(
      valueListenable: AuthManager.instance.view,
      builder: (context, snapshot, _) {
        final child = snapshot.state == AuthState.loggedIn
            ? loggedInBuilder(context)
            : const LoginPage();

        final paused = snapshot.isRefreshing;
        return Stack(
          children: [
            AbsorbPointer(absorbing: paused, child: child),
            if (paused)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .scrim
                        .withValues(alpha: 0.4),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Refreshing session...'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
