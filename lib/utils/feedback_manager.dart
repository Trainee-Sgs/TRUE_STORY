import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackManager {
  static final FeedbackManager _instance = FeedbackManager._internal();
  factory FeedbackManager() => _instance;
  FeedbackManager._internal();

  final ValueNotifier<Set<String>> submittedStoryIds = ValueNotifier<Set<String>>({});

  static const String _storageKey = 'submitted_feedback_ids';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_storageKey) ?? [];
    submittedStoryIds.value = ids.toSet();
  }

  bool hasSubmitted(String storyId) {
    return submittedStoryIds.value.contains(storyId);
  }

  Future<void> submitFeedback(String storyId) async {
    final currentIds = Set<String>.from(submittedStoryIds.value);
    if (!currentIds.contains(storyId)) {
      currentIds.add(storyId);
      submittedStoryIds.value = currentIds;
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, submittedStoryIds.value.toList());
  }
}
