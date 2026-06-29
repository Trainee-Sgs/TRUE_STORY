import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  SessionManager
///  Single place to read / write / clear ALL SharedPreferences for this app.
///
///  Keys stored
///  ┌──────────────────┬──────────┬─────────────────────────────────────────┐
///  │ Key              │ Type     │ Source                                  │
///  ├──────────────────┼──────────┼─────────────────────────────────────────┤
///  │ is_logged_in     │ bool     │ set true on login, removed on logout    │
///  │ cid              │ int      │ hardcoded constant (21472147)           │
///  │ uid              │ String   │ user-entered 6-digit login ID           │
///  │ user_name        │ String   │ API response → name                     │
///  │ auth_token       │ String   │ API response → auth_token               │
///  │ device_id        │ String   │ device_info_plus (splash)               │
///  │ lt               │ double   │ geolocator latitude  (splash)           │
///  │ ln               │ double   │ geolocator longitude (splash)           │
///  └──────────────────┴──────────┴─────────────────────────────────────────┘
/// ─────────────────────────────────────────────────────────────────────────────
class SessionManager {

  // ── Private key constants ──────────────────────────────────────────────────
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kCid        = 'cid';
  static const _kUid        = 'uid';
  static const _kUserName   = 'user_name';
  static const _kAuthToken  = 'auth_token';
  static const _kDeviceId   = 'device_id';
  static const _kLt         = 'lt';
  static const _kLn         = 'ln';

  // ── Save device info (called from SplashScreen) ────────────────────────────
  static Future<void> saveDeviceInfo({
    required String deviceId,
    required double lt,
    required double ln,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDeviceId, deviceId);
    await prefs.setDouble(_kLt,       lt);
    await prefs.setDouble(_kLn,       ln);

    debugPrint('┌─────────────────────────────────┐');
    debugPrint('│      DEVICE INFO SAVED          │');
    debugPrint('├─────────────────────────────────┤');
    debugPrint('│ device_id : $deviceId');
    debugPrint('│ lt        : $lt');
    debugPrint('│ ln        : $ln');
    debugPrint('└─────────────────────────────────┘');
  }

  // ── Save login session (called from LoginScreen on success) ───────────────
  static Future<void> saveLoginSession({
    required int    cid,
    required String uid,
    required String userName,
    required String authToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool  (_kIsLoggedIn, true);
    await prefs.setInt   (_kCid,        cid);
    await prefs.setString(_kUid,        uid);
    await prefs.setString(_kUserName,   userName);
    await prefs.setString(_kAuthToken,  authToken);

    debugPrint('┌─────────────────────────────────┐');
    debugPrint('│       LOGIN SESSION SAVED       │');
    debugPrint('├─────────────────────────────────┤');
    debugPrint('│ is_logged_in : true');
    debugPrint('│ cid          : $cid');
    debugPrint('│ uid          : $uid');
    debugPrint('│ user_name    : $userName');
    debugPrint('│ auth_token   : $authToken');
    debugPrint('└─────────────────────────────────┘');
  }

  // ── Read: login state ──────────────────────────────────────────────────────
  // ✅ FIX: reload() added — hot restart / app resume-லயும் fresh value படிக்கும்
  // Missing key → null → false  (safe default after logout)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ← KEY FIX: disk-ல உள்ள latest value படிக்கும்
    return prefs.getBool(_kIsLoggedIn) == true;
  }

  // ── Read: individual fields ────────────────────────────────────────────────
  static Future<int>    getCid()       async => (await SharedPreferences.getInstance()).getInt   (_kCid)       ?? 0;
  static Future<String> getUid()       async => (await SharedPreferences.getInstance()).getString(_kUid)       ?? '';
  static Future<String> getUserName()  async => (await SharedPreferences.getInstance()).getString(_kUserName)  ?? '';
  static Future<String> getAuthToken() async => (await SharedPreferences.getInstance()).getString(_kAuthToken) ?? '';
  static Future<String> getDeviceId()  async => (await SharedPreferences.getInstance()).getString(_kDeviceId)  ?? '';
  static Future<double> getLt()        async => (await SharedPreferences.getInstance()).getDouble(_kLt)        ?? 0.0;
  static Future<double> getLn()        async => (await SharedPreferences.getInstance()).getDouble(_kLn)        ?? 0.0;

  // ── Update CID after switch company ─────────────────────────────────────
  static Future<void> saveCid(int cid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCid, cid);
    debugPrint('┌─────────────────────────────────┐');
    debugPrint('│       CID UPDATED               │');
    debugPrint('├─────────────────────────────────┤');
    debugPrint('│ cid : $cid');
    debugPrint('└─────────────────────────────────┘');
  }

  // ── Read all at once (useful for API calls in future screens) ─────────────
  static Future<Map<String, dynamic>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ← fresh read every time
    return {
      'is_logged_in' : prefs.getBool  (_kIsLoggedIn) ?? false,
      'cid'          : prefs.getInt   (_kCid)        ?? 0,
      'uid'          : prefs.getString(_kUid)        ?? '',
      'user_name'    : prefs.getString(_kUserName)   ?? '',
      'auth_token'   : prefs.getString(_kAuthToken)  ?? '',
      'device_id'    : prefs.getString(_kDeviceId)   ?? '',
      'lt'           : prefs.getDouble(_kLt)         ?? 0.0,
      'ln'           : prefs.getDouble(_kLn)         ?? 0.0,
    };
  }

  // ── Logout: removes ONLY login keys, keeps device_id / lt / ln ───────────
  //
  //  ❌ OLD (BUG):  prefs.clear()  → deletes device_id, lt, ln too!
  //  ✅ NEW (FIX):  remove each login key individually
  //
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove each login key individually
    await prefs.remove(_kIsLoggedIn);
    await prefs.remove(_kCid);
    await prefs.remove(_kUid);
    await prefs.remove(_kUserName);
    await prefs.remove(_kAuthToken);

    await prefs.reload();

    debugPrint('┌─────────────────────────────────┐');
    debugPrint('│           LOGGED OUT            │');
    debugPrint('├─────────────────────────────────┤');
    debugPrint('│ is_logged_in : removed → false  │');
    debugPrint('│ device info  : kept ✅           │');
    debugPrint('└─────────────────────────────────┘');
  }

  // ── clearSession: wipes EVERYTHING (use only on uninstall / reset) ────────
  //  Do NOT call this on normal logout — device info will be lost!
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.reload(); // ← FIX: clear confirm
    debugPrint('┌─────────────────────────────────┐');
    debugPrint('│     FULL SESSION CLEARED        │');
    debugPrint('│  (device info also removed)     │');
    debugPrint('└─────────────────────────────────┘');
  }
}
