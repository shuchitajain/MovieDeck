import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// JSON cache with TTL for offline support.
/// Caches trending movies, AI recommendations, etc.
class CacheService {
  static CacheService? _instance;

  CacheService._();
  static CacheService get instance => _instance ??= CacheService._();

  Directory? _cacheDir;

  Future<Directory> get _dir async {
    _cacheDir ??= Directory(
        '${(await getApplicationDocumentsDirectory()).path}/app_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    return _cacheDir!;
  }

  String _keyToFileName(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

  /// Write JSON data with TTL (default 1 hour).
  Future<void> write(String key, dynamic data,
      {Duration ttl = const Duration(hours: 1)}) async {
    try {
      final dir = await _dir;
      final file = File('${dir.path}/${_keyToFileName(key)}.json');
      final wrapper = {
        'data': data,
        'expiresAt': DateTime.now().add(ttl).millisecondsSinceEpoch,
      };
      await file.writeAsString(jsonEncode(wrapper));
    } catch (e) {
      debugPrint('Cache write error: $e');
    }
  }

  /// Read cached data. Returns null if expired or missing.
  Future<dynamic> read(String key) async {
    try {
      final dir = await _dir;
      final file = File('${dir.path}/${_keyToFileName(key)}.json');
      if (!await file.exists()) return null;
      final wrapper = jsonDecode(await file.readAsString());
      final expiresAt = wrapper['expiresAt'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await file.delete();
        return null;
      }
      return wrapper['data'];
    } catch (e) {
      debugPrint('Cache read error: $e');
      return null;
    }
  }

  /// Check if valid cache exists.
  Future<bool> has(String key) async {
    return await read(key) != null;
  }

  /// Clear all cached data.
  Future<void> clearAll() async {
    try {
      final dir = await _dir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }
}
