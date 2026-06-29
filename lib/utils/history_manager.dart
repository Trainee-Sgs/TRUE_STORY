import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryManager extends ChangeNotifier {
  static final HistoryManager _instance = HistoryManager._internal();
  factory HistoryManager() => _instance;
  HistoryManager._internal();

  SharedPreferences? _prefs;
  List<Map<String, dynamic>> _historyItems = [];

  List<Map<String, dynamic>> get historyItems => _historyItems;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final String? historyJson = _prefs?.getString('story_history');
    if (historyJson != null) {
      _historyItems = List<Map<String, dynamic>>.from(json.decode(historyJson));
    }
  }

  Future<void> addToHistory(Map<String, dynamic> storyData) async {
    // Check if story is already in history, if so remove it to push to front
    _historyItems.removeWhere((item) => item['title'] == storyData['title']);
    
    // Add to front of list
    _historyItems.insert(0, {
      ...storyData,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Limit history size to 50 items
    if (_historyItems.length > 50) {
      _historyItems = _historyItems.sublist(0, 50);
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> removeFromHistory(List<String> storyTitles) async {
    _historyItems.removeWhere((item) => storyTitles.contains(item['title']));
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    _historyItems.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final String historyJson = json.encode(_historyItems);
    await _prefs?.setString('story_history', historyJson);
  }
}
