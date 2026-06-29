import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostManager {
  static final PostManager _instance = PostManager._internal();
  factory PostManager() => _instance;
  PostManager._internal();

  final ValueNotifier<List<Map<String, dynamic>>> uploadedPosts = 
      ValueNotifier<List<Map<String, dynamic>>>([]);

  static const String _storageKey = 'uploaded_posts';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? postsJson = prefs.getString(_storageKey);
    if (postsJson != null) {
      final List<dynamic> decoded = json.decode(postsJson);
      uploadedPosts.value = List<Map<String, dynamic>>.from(decoded);
    }
  }

  Future<void> addPost(Map<String, dynamic> postData) async {
    final updatedList = List<Map<String, dynamic>>.from(uploadedPosts.value)..add(postData);
    uploadedPosts.value = updatedList;
    await _saveToStorage(updatedList);
  }

  Future<void> deletePost(String title) async {
    final updatedList = List<Map<String, dynamic>>.from(uploadedPosts.value)
      ..removeWhere((post) => post['title'] == title);
    uploadedPosts.value = updatedList;
    await _saveToStorage(updatedList);
  }

  Future<void> _saveToStorage(List<Map<String, dynamic>> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(posts);
    await prefs.setString(_storageKey, encoded);
  }
}
