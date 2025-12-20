import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'config/app_config.dart';
import 'services/auth_manager.dart';
import 'services/graphql_service.dart';
import 'pages/auth_gate.dart';
import 'pages/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.defaultConfig;
  await AuthManager.instance.init();
  await GraphQLService.instance.init(config: config);
  AuthManager.instance.refreshEndpoint = config.authRefresh;
  AuthManager.instance.loginEndpoint = config.authLogin;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: ThemeController.instance.grandmaMode,
          builder: (context, grandmaMode, _) {
            return MaterialApp(
              title: 'RFP',
              themeMode: mode,
              theme: AppTheme.light(grandmaMode: grandmaMode),
              darkTheme: AppTheme.dark(grandmaMode: grandmaMode),
              home: AuthGate(loggedInBuilder: (_) => const RootShell()),
            );
          },
        );
      },
    );
  }
}
