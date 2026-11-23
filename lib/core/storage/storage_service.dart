import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 访问令牌存系统安全存储：Android Keystore / iOS Keychain。
/// 首次启动会把旧版 SharedPreferences 里的明文令牌迁移过来并删除，迁移只发生一次。
class StorageService {
  StorageService(this._secure, this._prefs);

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';

  Future<String?> token() async {
    final value = await _secure.read(key: _tokenKey);
    if (value != null) return value;

    // 一次性迁移：旧版本把 JWT 明文放 SharedPreferences
    final legacy = _prefs.getString(_tokenKey);
    if (legacy == null || legacy.isEmpty) return null;
    await _secure.write(key: _tokenKey, value: legacy);
    await _prefs.remove(_tokenKey);
    return legacy;
  }

  Future<void> saveToken(String token) async {
    await _secure.write(key: _tokenKey, value: token);
    await _prefs.remove(_tokenKey); // 防止旧值残留
  }

  Future<void> clearToken() async {
    await _secure.delete(key: _tokenKey);
    await _prefs.remove(_tokenKey);
  }
}
