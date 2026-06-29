import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeManager {
  static final LikeManager _instance = LikeManager._internal();
  factory LikeManager() => _instance;
  LikeManager._internal();

  final ValueNotifier<Set<String>> likedStoryIds = ValueNotifier<Set<String>>({});

  static const String _storageKey = 'liked_story_ids';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? likedIds = prefs.getStringList(_storageKey);
    if (likedIds != null) {
      likedStoryIds.value = likedIds.toSet();
    }
  }

  bool isLiked(String id) {
    return likedStoryIds.value.contains(id);
  }

  Future<void> toggleLike(String id) async {
    final current = Set<String>.from(likedStoryIds.value);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    likedStoryIds.value = current;
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, likedStoryIds.value.toList());
  }
}
