import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared_preference.dart';

class SignUpProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> performSignUp({
    required String name,
    required String email,
    required String mobileNumber,
  }) async {
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
        'type': '2511',
        'cid': cid,
        'name': name,
        'email': email,
        'mobile_number': mobileNumber,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
      };

      debugPrint('SignUp Request: $requestBody');
      final response = await http.post(url, body: requestBody);
      debugPrint('SignUp Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['error'] == false) {
            _isLoading = false;
            notifyListeners();
            return true; // Success
          } else {
            _errorMessage = data['error_msg'] ?? 'Signup failed';
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
    }

    _isLoading = false;
    notifyListeners();
    return false; // Failure
  }
}
