import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared_preference.dart';
import '../utils/post_manager.dart';

class StoryStatusProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _userStories = [];
  List<Map<String, dynamic>> get userStories => _userStories;

  Map<String, dynamic>? _statusSummary;
  Map<String, dynamic>? get statusSummary => _statusSummary;

  int _totalStories = 0;
  int get totalStories => _totalStories;

  Future<void> fetchUserStories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionData = await SessionManager.getAll();

      final String cid = sessionData['cid'].toString() == '0'
          ? '21472147'
          : sessionData['cid'].toString();
      final String mobileNumber = sessionData['uid'].toString();
      final String deviceId = sessionData['device_id'].toString();
      final String lt = sessionData['lt'].toString();
      final String ln = sessionData['ln'].toString();

      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'cid': cid,
        'mobile_number': mobileNumber,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
        'type': '2506',
      };

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│    FETCH STORY STATUS REQUEST        │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('└──────────────────────────────────────┘');

      final response = await http.post(url, body: requestBody);

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│    FETCH STORY STATUS RESPONSE       │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS CODE : ${response.statusCode}');
      debugPrint('│ RESPONSE    : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          String authorName = data['author_name']?.toString() ?? 'Unknown';
          if (authorName == 'Unknown' ||
              authorName == 'User' ||
              authorName.isEmpty) {
            authorName = await SessionManager.getUserName();
          }
          _userStories =
              (data['stories'] as List?)?.map((story) {
                final Map<String, dynamic> mutableStory =
                    Map<String, dynamic>.from(story);
                mutableStory['author_name'] ??= authorName;
                return mutableStory;
              }).toList() ??
              [];
          _statusSummary = data['status_summary'];
          _totalStories = data['total_stories'] ?? 0;
        } else {
          _errorMessage = data['error_msg'] ?? 'Failed to fetch stories.';
        }
      } else {
        _errorMessage = 'API Error: ${response.statusCode}. Response: ${response.body.isEmpty ? "Empty Response" : response.body}';
        _userStories = [];
        _statusSummary = {'pending': 0, 'approved': 0, 'rejected': 0};
        _totalStories = 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
