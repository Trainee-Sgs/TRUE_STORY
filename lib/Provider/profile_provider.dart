import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared_preference.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionData = await SessionManager.getAll();
      final String cid = sessionData['cid'].toString() == '0' ? '21472147' : sessionData['cid'].toString();
      
      final String deviceId = sessionData['device_id'].toString();
      final String lt = sessionData['lt'].toString();
      final String ln = sessionData['ln'].toString();
      final String mobileNumber = sessionData['uid'].toString();
      if (mobileNumber.isEmpty || mobileNumber == 'null') {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'type': '2508',
        'cid': cid,
        'mobile_number': mobileNumber,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
      };

      debugPrint('Profile Request: $requestBody');
      final response = await http.post(url, body: requestBody);
      debugPrint('Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['error'] == false) {
            _profileData = data['profile'] ?? data['data'] ?? data;
          } else {
            _errorMessage = data['error_msg'] ?? 'Failed to fetch profile';
          }
        } on FormatException catch (e) {
          debugPrint('FormatException: $e');
          // Strip HTML tags for cleaner display if it's an HTML error
          final cleanError = response.body.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
          _errorMessage = cleanError.isNotEmpty ? cleanError : response.body;
        }
      } else {
        _errorMessage = 'Server Error. Please try again later.';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong. Please check your connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
