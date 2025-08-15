import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [SecureStorageService] flutter secure storage for secure token store
/// [SecureStorageService] method follows Singleton Pattern
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _storage;

  SecureStorageService._internal()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  /// [write] a value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// [read] a value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// [delete] a value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// [clear] a value
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// [containsKey] check if a key exists
  Future<bool> containsKey(String key) async {
    final Map<String, String> all = await _storage.readAll();
    return all.containsKey(key);
  }
}

///============================ >
/*
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<activity
android:name="io.flutter.plugins.flutter_secure_storage.FlutterSecureStorageActivity"
android:exported="false"

needs to be added on the manifest file of the project

/>*/
