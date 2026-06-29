import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  static final SaveManager _instance = SaveManager._internal();
  factory SaveManager() => _instance;
  SaveManager._internal();

  final ValueNotifier<Set<String>> savedStoryIds = ValueNotifier<Set<String>>({});
  final ValueNotifier<Map<String, Map<String, dynamic>>> savedStories = 
      ValueNotifier<Map<String, Map<String, dynamic>>>({});

  static const String _storageKey = 'saved_stories';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataJson = prefs.getString(_storageKey);
    if (dataJson != null) {
      final Map<String, dynamic> decoded = json.decode(dataJson);
      final Map<String, Map<String, dynamic>> stories = {};
      decoded.forEach((key, value) {
        stories[key] = Map<String, dynamic>.from(value);
      });
      savedStories.value = stories;
      savedStoryIds.value = stories.keys.toSet();
    }
  }

  bool isSaved(String id) => savedStoryIds.value.contains(id);

  Future<void> toggleSave(String id, [Map<String, dynamic>? storyData]) async {
    final currentIds = Set<String>.from(savedStoryIds.value);
    final currentStories = Map<String, Map<String, dynamic>>.from(savedStories.value);

    if (currentIds.contains(id)) {
      currentIds.remove(id);
      currentStories.remove(id);
    } else {
      currentIds.add(id);
      currentStories[id] = storyData ?? {
        'title': id,
        'image': 'assets/images/ratan_tata.png',
        'views': '0',
        'likes': '0',
      };
    }
    savedStoryIds.value = currentIds;
    savedStories.value = currentStories;
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(savedStories.value));
  }
}
