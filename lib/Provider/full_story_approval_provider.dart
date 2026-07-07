import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared_preference.dart';

class FullStoryApprovalProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _approvedStories = [];
  List<Map<String, dynamic>> get approvedStories => _approvedStories;

  Future<void> fetchApprovedStories({String category = 'All'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionData = await SessionManager.getAll();
      
      final String cid = sessionData['cid'].toString() == '0' ? '21472147' : sessionData['cid'].toString();
      final String deviceId = sessionData['device_id'].toString();
      final String lt = sessionData['lt'].toString();
      final String ln = sessionData['ln'].toString();

      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'cid': cid,
        'category': category == 'All' ? '' : category,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
        'type': '2507',
      };

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│ FETCH FULL STORY APPROVAL REQUEST    │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('└──────────────────────────────────────┘');

      final response = await http.post(
        url,
        body: requestBody,
      );

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│ FETCH FULL STORY APPROVAL RESPONSE   │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS CODE : ${response.statusCode}');
      debugPrint('│ RESPONSE    : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          String rootAuthorName = data['author_name']?.toString() ?? data['name']?.toString() ?? '';
          if (rootAuthorName.isEmpty || rootAuthorName == 'User') {
            rootAuthorName = await SessionManager.getUserName();
          }
          List<Map<String, dynamic>> allStories = [];
          if (data['stories'] != null && data['stories'] is List) {
            allStories = (data['stories'] as List).map((e) {
              if (e is Map) {
                final storyMap = Map<String, dynamic>.from(e);
                if (rootAuthorName.isNotEmpty && (storyMap['author_name'] == null || storyMap['author_name'] == 'User' || storyMap['author_name'].toString().isEmpty)) {
                  storyMap['author_name'] = rootAuthorName;
                }
                return storyMap;
              }
              return <String, dynamic>{};
            }).where((e) => e.isNotEmpty).toList();
          }
          
          _approvedStories = allStories.where((story) {
            final status = story['status']?.toString().toLowerCase() ?? '';
            return status == 'approved' || status == '1';
          }).toList();
        } else {
          _errorMessage = data['error_msg'] ?? 'Failed to fetch stories.';
        }
      } else {
        _errorMessage = 'Server error. Please try again.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
