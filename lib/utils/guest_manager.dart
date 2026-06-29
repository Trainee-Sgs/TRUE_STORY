import 'package:shared_preferences/shared_preferences.dart';

class GuestManager {
  static final GuestManager _instance = GuestManager._internal();
  factory GuestManager() => _instance;
  GuestManager._internal();

  static const String _keyIsGuest = 'is_guest_mode';
  static const String _keyReadCount = 'story_read_count';
  static const int maxGuestStories = 3;

  bool _isGuest = false;
  int _readCount = 0;

  bool get isGuest => _isGuest;
  int get readCount => _readCount;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool(_keyIsGuest) ?? false;
    _readCount = prefs.getInt(_keyReadCount) ?? 0;
  }

  Future<void> setGuestMode(bool value) async {
    _isGuest = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, value);
  }

  Future<void> incrementReadCount() async {
    if (_isGuest && _readCount < maxGuestStories) {
      _readCount++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyReadCount, _readCount);
    }
  }

  bool canReadStory() {
    if (!_isGuest) return true;
    return _readCount < maxGuestStories;
  }

  Future<void> clearGuestData() async {
    _isGuest = false;
    _readCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyReadCount);
  }
}
