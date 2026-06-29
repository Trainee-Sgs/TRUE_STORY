import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreenProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> requestOtp({
    required String mobile,
    required String cid,
    required double ln,
    required double lt,
    required String deviceId,
    required String type,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'cid': cid,
        'ln': ln.toString(),
        'lt': lt.toString(),
        'device_id': deviceId,
        'type': type,
        'mobile': mobile,
      };

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│         OTP REQUEST SENT             │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('└──────────────────────────────────────┘');
      
      final response = await http.post(
        url,
        body: requestBody,
      );

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│         OTP REQUEST RESPONSE         │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS CODE : ${response.statusCode}');
      debugPrint('│ RESPONSE    : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      _isLoading = false;

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['error'] == true) {
            _errorMessage = data['error_msg'] ?? 'Failed to request OTP.';
            notifyListeners();
            return false;
          }
        } catch (_) {}
        // Success
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to request OTP. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String mobile,
    required String cid,
    required double ln,
    required double lt,
    required String deviceId,
    required String type,
    required String otp,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'cid': cid,
        'ln': ln.toString(),
        'lt': lt.toString(),
        'device_id': deviceId,
        'type': type,
        'mobile': mobile,
        'otp': otp,
        'token': token,
      };

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│       VERIFY OTP REQUEST SENT        │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('└──────────────────────────────────────┘');
      
      final response = await http.post(
        url,
        body: requestBody,
      );

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│       VERIFY OTP RESPONSE            │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS CODE : ${response.statusCode}');
      debugPrint('│ RESPONSE    : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      _isLoading = false;

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['error'] == true) {
            _errorMessage = data['error_msg'] ?? 'Failed to verify OTP.';
            notifyListeners();
            return false;
          }
        } catch (_) {}
        // Success
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to verify OTP. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
