import 'package:hive_flutter/hive_flutter.dart';

class HiveCacheService {
  static final _box = Hive.box('offline_cache');

  static Future<void> cacheData(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static dynamic getCachedData(String key) {
    return _box.get(key);
  }
}
