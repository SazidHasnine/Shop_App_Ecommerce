import 'dart:convert';

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

  String? getRefreshToken() => _prefs.getString(ApiConstants.refreshTokenKey);

  Future<bool> setRefreshToken(String token) =>
      _prefs.setString(ApiConstants.refreshTokenKey, token);

  Future<bool> clearRefreshToken() =>
      _prefs.remove(ApiConstants.refreshTokenKey);

  Map<String, dynamic>? getUserData() {
    final raw = _prefs.getString(ApiConstants.userDataKey);
    if(raw == null || raw.isEmpty) return null;
    
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch(_) {
      return null;
    }
   }

   Future<bool> setUserData(Map<String, dynamic> userMap) =>
    _prefs.setString(ApiConstants.userDataKey, jsonEncode(userMap));

  Future<bool> clearUserData() => _prefs.remove(ApiConstants.userDataKey);

  Future<void> clearAuthSession() async {
    await clearAuthToken();
    await clearRefreshToken();
    await clearUserData();
  }

  // Generic key-value helpers
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> setStringList(String key,  List<String> value) =>
        _prefs.setStringList(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clearAll() => _prefs.clear();

  // cart cache
  Future<bool> setCartCache(List<Map<String, dynamic>> items) async {
    return await _prefs.setString(
      ApiConstants.cachedCartKey,
      jsonEncode(items),
    );
  }

  List<Map<String, dynamic>> getCartCache() {
    final raw = _prefs.getString(ApiConstants.cachedCartKey);
    if(raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic> ;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch(_){
      return [];
    }
  }

  int? getColudCartId() => _prefs.getInt(ApiConstants.cloudCartIdKey);

  Future<bool> setColudCartId(int? id) async {
    if(id == null) {
      return await _prefs.remove(ApiConstants.cloudCartIdKey);
    }
    return await _prefs.setInt(ApiConstants.cloudCartIdKey, id);
  }

  DateTime? getLastCartSync() {
    final millis = _prefs.getInt(ApiConstants.lastCartSyncKey);
    return millis != null ? DateTime.fromMicrosecondsSinceEpoch(millis) : null ;
  }

  Future<bool> setLastCartSync(DateTime time) async {
    return await _prefs.setInt(
      ApiConstants.lastCartSyncKey,
      time.millisecondsSinceEpoch,
    );
  }

  bool hasPendingCartSync() =>
      _prefs.getBool(ApiConstants.pendingCartSyncKey) ?? false;

  Future<bool> setPendingCartSync(bool pending) async {
    return await _prefs.setBool(ApiConstants.pendingCartSyncKey, pending);
  }
}