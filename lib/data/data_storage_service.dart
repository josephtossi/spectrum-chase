import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// keys : top_users_statistics, user_statistics
class DataStorageManager {
  SharedPreferences _prefs;

  DataStorageManager(this._prefs);

  Future<void> setMap(String key, Map<dynamic, dynamic> value) async {
    await _prefs.setString(key, json.encode(value));
  }

  Future<void> setList(String key, List<dynamic> value) async {
    await _prefs.setString(key, json.encode(value.toSet().toList()));
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Getters
  List<dynamic> getList(String key) {
    String jsonString = _prefs.getString(key) ?? '[]';
    return List<dynamic>.from(json.decode(jsonString));
  }

  Map<String, dynamic> getMap(String key) {
    String jsonString = _prefs.getString(key) ?? '{}';
    return Map<String, dynamic>.from(json.decode(jsonString));
  }

  String getString(String key) {
    return _prefs.getString(key) ?? '';
  }

  int getInt(String key) {
    return _prefs.getInt(key) ?? 0;
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }
}
