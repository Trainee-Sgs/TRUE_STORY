import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final ValueNotifier<Set<String>> downloadedStoryIds = ValueNotifier<Set<String>>({});
  final ValueNotifier<Map<String, Map<String, dynamic>>> downloadedStories = 
      ValueNotifier<Map<String, Map<String, dynamic>>>({});

  static const String _storageKey = 'downloaded_stories';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataJson = prefs.getString(_storageKey);
    if (dataJson != null) {
      final Map<String, dynamic> decoded = json.decode(dataJson);
      final Map<String, Map<String, dynamic>> stories = {};
      decoded.forEach((key, value) {
        stories[key] = Map<String, dynamic>.from(value);
      });
      downloadedStories.value = stories;
      downloadedStoryIds.value = stories.keys.toSet();
    }
  }

  Future<void> downloadStory(String id, [Map<String, dynamic>? storyData]) async {
    final currentIds = Set<String>.from(downloadedStoryIds.value);
    final currentStories = Map<String, Map<String, dynamic>>.from(downloadedStories.value);

    if (!currentIds.contains(id)) {
      currentIds.add(id);
      currentStories[id] = storyData ?? {
        'title': id,
        'image': 'assets/images/ratan_tata.png',
        'views': '0',
        'likes': '0',
      };
      
      downloadedStoryIds.value = currentIds;
      downloadedStories.value = currentStories;
      await _saveToStorage();
    }
  }

  Future<void> removeDownload(String id) async {
    final currentIds = Set<String>.from(downloadedStoryIds.value);
    final currentStories = Map<String, Map<String, dynamic>>.from(downloadedStories.value);

    if (currentIds.contains(id)) {
      currentIds.remove(id);
      currentStories.remove(id);
      downloadedStoryIds.value = currentIds;
      downloadedStories.value = currentStories;
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(downloadedStories.value));
  }

  bool isDownloaded(String id) => downloadedStoryIds.value.contains(id);
}
