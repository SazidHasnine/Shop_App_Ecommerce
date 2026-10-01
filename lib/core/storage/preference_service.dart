import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_ecommerce/core/constants/api_constants.dart';

class PreferenceService {
  final SharedPreferences _prefs;

  PreferenceService._(this._prefs);

  static Future<PreferenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceService._(prefs);
  }

  // Auth token helpers
  String? getAuthToken() => _prefs.getString(ApiConstants.authTokenKey);

  Future<bool> setAuthToken(String token) =>
      _prefs.setString(ApiConstants.authTokenKey, token);

  Future<bool> clearAuthToken() => _prefs.remove(ApiConstants.authTokenKey);

  // Generic key-value helpers

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> setStringList(String key,  List<String> value) =>
        _prefs.setStringList(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clearAll() => _prefs.clear();
}