import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static SecureStorage? _instance;
  SharedPreferences? _prefs;

  SecureStorage._();

  static SecureStorage get instance {
    _instance ??= SecureStorage._();
    return _instance!;
  }

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> read(String key) async {
    await _ensureInitialized();
    return _prefs?.getString(key);
  }

  Future<bool> write(String key, String value) async {
    await _ensureInitialized();
    return await _prefs?.setString(key, value) ?? false;
  }

  Future<bool> delete(String key) async {
    await _ensureInitialized();
    return await _prefs?.remove(key) ?? false;
  }

  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs?.containsKey(key) ?? false;
  }

  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs?.clear();
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage.instance;
});