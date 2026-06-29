import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../shared_preference.dart';

class CategoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int cid = await SessionManager.getCid();
      final double ln = await SessionManager.getLn();
      final double lt = await SessionManager.getLt();
      final String deviceId = await SessionManager.getDeviceId();

      // Fallbacks just in case preferences are not fully populated
      final String finalCid = cid == 0 ? '21472147' : cid.toString();
      final double finalLn = ln == 0.0 ? 23.0 : ln;
      final double finalLt = lt == 0.0 ? 45.0 : lt;
      final String finalDeviceId = deviceId.isEmpty ? '45' : deviceId;

      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      final Map<String, String> requestBody = {
        'cid': finalCid,
        'ln': finalLn.toString(),
        'lt': finalLt.toString(),
        'device_id': finalDeviceId,
        'type': '2504',
      };

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│      FETCH CATEGORIES REQUEST        │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('└──────────────────────────────────────┘');

      final response = await http.post(url, body: requestBody);

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│      FETCH CATEGORIES RESPONSE       │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS : ${response.statusCode}');
      debugPrint('│ BODY   : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['error'] == true) {
          _errorMessage = decoded['error_msg'] ?? 'Failed to load categories';
        } else if (decoded is List) {
          _categories = decoded;
        } else if (decoded is Map<String, dynamic>) {
           // check for common keys
           if (decoded.containsKey('data')) {
             _categories = decoded['data'] ?? [];
           } else if (decoded.containsKey('Category') || decoded.containsKey('category')) {
             _categories = decoded['Category'] ?? decoded['category'] ?? [];
           } else if (decoded.containsKey('categories')) {
             _categories = decoded['categories'] ?? [];
           } else {
             // Just store the whole map wrapped if we don't know the structure
             _categories = [decoded];
           }
        }
      } else {
        _errorMessage = 'Failed to fetch categories';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
