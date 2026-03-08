import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyOrgId = 'organization_id';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<void> saveOrganizationId(String orgId) async {
    await _storage.write(key: _keyOrgId, value: orgId);
  }

  static Future<String?> getOrganizationId() async {
    return await _storage.read(key: _keyOrgId);
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyOrgId);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyAccessToken);
  }
}
