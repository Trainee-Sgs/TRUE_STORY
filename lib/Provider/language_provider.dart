import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../shared_preference.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _languages = [];
  List<dynamic> get languages => _languages;

  Future<void> fetchLanguages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int cid = await SessionManager.getCid();
      final double ln = await SessionManager.getLn();
      final double lt = await SessionManager.getLt();
      final String deviceId = await SessionManager.getDeviceId();

      // Fallbacks
      final String finalCid = cid == 0 ? '21472147' : cid.toString();
      final double finalLn = ln;
      final double finalLt = lt;
      final String finalDeviceId = deviceId;

      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'cid': finalCid,
        'ln': finalLn.toString(),
        'lt': finalLt.toString(),
        'device_id': finalDeviceId,
        'type': '2505',
      };

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│      FETCH LANGUAGES REQUEST         │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('└──────────────────────────────────────┘');

      final response = await http.post(url, body: requestBody);

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│      FETCH LANGUAGES RESPONSE        │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS : ${response.statusCode}');
      debugPrint('│ BODY   : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['error'] == true) {
          _errorMessage = decoded['error_msg'] ?? 'Failed to load languages';
        } else if (decoded is List) {
          _languages = decoded;
        } else if (decoded is Map<String, dynamic>) {
           // check for common keys
           if (decoded.containsKey('data')) {
             _languages = decoded['data'] ?? [];
           } else if (decoded.containsKey('Language') || decoded.containsKey('language') || decoded.containsKey('languages')) {
             _languages = decoded['Language'] ?? decoded['language'] ?? decoded['languages'] ?? [];
           } else {
             _languages = [decoded];
           }
        }
      } else {
        _errorMessage = 'Failed to fetch languages';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
