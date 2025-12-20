import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_storage.dart';

enum AuthState { loggedOut, loggedIn }

class AuthSnapshot {
  const AuthSnapshot({
    required this.state,
    this.isRefreshing = false,
    this.error,
  });

  final AuthState state;
  final bool isRefreshing;
  final String? error;

  AuthSnapshot copyWith({
    AuthState? state,
    bool? isRefreshing,
    String? error,
  }) => AuthSnapshot(
        state: state ?? this.state,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        error: error,
      );
}

class AuthManager {
  AuthManager._();
  static final AuthManager instance = AuthManager._();

  final ValueNotifier<AuthState> status = ValueNotifier(AuthState.loggedOut);
  final ValueNotifier<bool> isPaused = ValueNotifier(false);
  final ValueNotifier<AuthSnapshot> view =
      ValueNotifier(const AuthSnapshot(state: AuthState.loggedOut));

  TokenPair? _tokens;
  Future<bool>? _refreshing;

  // Configurable endpoints.
  Uri refreshEndpoint = AppConfig.defaultConfig.authRefresh;
  Uri loginEndpoint = AppConfig.defaultConfig.authLogin;

  Future<void> init() async {
    _tokens = await TokenStorage.read();
    status.value = _tokens == null ? AuthState.loggedOut : AuthState.loggedIn;
    view.value = view.value.copyWith(
      state: status.value,
      isRefreshing: false,
      error: null,
    );
  }

  String? get accessToken => _tokens?.accessToken;
  String? get refreshToken => _tokens?.refreshToken;

  Future<void> loginWithCredentials({
    required String username,
    required String password,
    bool persist = true,
  }) async {
    final response = await http.post(
      loginEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final access = json['accessToken'] as String?;
    final refresh = json['refreshToken'] as String?;
    if (access == null || refresh == null) {
      throw const FormatException('Missing tokens in login response');
    }
    await setTokens(
      TokenPair(accessToken: access, refreshToken: refresh),
      persist: persist,
    );
  }

  Future<void> setTokens(TokenPair? pair, {bool persist = true}) async {
    _tokens = pair;
    if (pair == null) {
      await TokenStorage.clear();
      status.value = AuthState.loggedOut;
      view.value = view.value.copyWith(state: AuthState.loggedOut, error: null);
    } else {
      if (persist) {
        await TokenStorage.write(pair);
      }
      status.value = AuthState.loggedIn;
      view.value = view.value.copyWith(state: AuthState.loggedIn, error: null);
    }
  }

  Future<bool> refreshTokens() async {
    final token = refreshToken;
    if (token == null || token.isEmpty) return false;

    if (_refreshing != null) return _refreshing!;

    _refreshing = _refreshTokens(token);
    final success = await _refreshing!;
    _refreshing = null;
    return success;
  }

  Future<bool> _refreshTokens(String token) async {
    isPaused.value = true;
    view.value = view.value.copyWith(isRefreshing: true, error: null);
    try {
      final newPair = await _requestRefresh(token);
      await setTokens(newPair);
      return true;
    } catch (_) {
      await setTokens(null);
      view.value = view.value.copyWith(error: 'Session expired');
      return false;
    } finally {
      isPaused.value = false;
      view.value = view.value.copyWith(isRefreshing: false);
    }
  }

  Future<TokenPair> _requestRefresh(String token) async {
    final response = await http.post(
      refreshEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Refresh failed (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final access = json['accessToken'] as String?;
    final refresh = json['refreshToken'] as String?;
    if (access == null || refresh == null) {
      throw const FormatException('Missing tokens in refresh response');
    }
    return TokenPair(accessToken: access, refreshToken: refresh);
  }
}
