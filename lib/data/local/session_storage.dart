import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// DRY helper for session persistence — replaces repeated App.fss.write calls.
class SessionStorage {
  final FlutterSecureStorage _storage;

  const SessionStorage(this._storage);

  Future<void> saveUser(User user) async {
    await _storage.write(key: 'uid', value: user.uid);
    await _storage.write(key: 'email', value: user.email);
    await _storage.write(key: 'name', value: user.displayName);
  }

  Future<String?> readName() => _storage.read(key: 'name');

  Future<void> clearAll() => _storage.deleteAll();
}
