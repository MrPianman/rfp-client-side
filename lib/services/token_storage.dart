import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({required this.accessToken, required this.refreshToken});
}

class TokenStorage {
  TokenStorage._();
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device),
  );

  static Future<TokenPair?> read() async {
    final access = await _storage.read(key: _keyAccess);
    final refresh = await _storage.read(key: _keyRefresh);
    if (access == null || refresh == null) return null;
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  static Future<void> write(TokenPair pair) async {
    await _storage.write(key: _keyAccess, value: pair.accessToken);
    await _storage.write(key: _keyRefresh, value: pair.refreshToken);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }
}
