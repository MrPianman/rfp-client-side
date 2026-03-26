class AppConfig {
  const AppConfig({
    required this.graphqlEndpoint,
    required this.authLogin,
    required this.authRefresh,
  });

  final Uri graphqlEndpoint;
  final Uri authLogin;
  final Uri authRefresh;

  static final AppConfig defaultConfig = AppConfig(
    graphqlEndpoint: Uri.parse('https://openhouseesck.online/graphql'),
    authLogin: Uri.parse('https://example.com/auth/login'),
    authRefresh: Uri.parse('https://example.com/auth/refresh'),
  );
}
