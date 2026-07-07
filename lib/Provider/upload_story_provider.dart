import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' as dart_io;
import '../shared_preference.dart';

class UploadStoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> uploadStory({
    required String title,
    required String description,
    required String category,
    required String language,
    dart_io.File? imageFile,
    dart_io.File? pdfFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final int cid = await SessionManager.getCid();
      final String mobile = await SessionManager.getUid();
      final double ln = await SessionManager.getLn();
      final double lt = await SessionManager.getLt();
      final String deviceId = await SessionManager.getDeviceId();
      final String authorName = await SessionManager.getUserName();

      if (mobile.isEmpty) {
        _errorMessage = "You must be logged in to upload a story.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String finalCid = cid == 0 ? '21472147' : cid.toString();
      final String finalMobile = mobile;
      final double finalLn = ln;
      final double finalLt = lt;
      final String finalDeviceId = deviceId;
      final String finalAuthor = authorName.isEmpty ? 'test' : authorName;

      final Uri url = Uri.parse('https://truestory.ai.in/ai/api/m_api/');
      String categoryId = '1';
      switch (category.toLowerCase()) {
        case 'startup': categoryId = '1'; break;
        case 'general': categoryId = '2'; break;
        case 'business': categoryId = '3'; break;
        case 'education': categoryId = '4'; break;
        case 'sports': categoryId = '5'; break;
        case 'artists': categoryId = '6'; break;
        default: categoryId = '1';
      }

      String languageId = '1';
      switch (language.toLowerCase()) {
        case 'tamil': languageId = '1'; break;
        case 'english': languageId = '2'; break;
        case 'malayalam': languageId = '3'; break;
        case 'hindi': languageId = '4'; break;
        case 'telugu': languageId = '5'; break;
        case 'kanada': languageId = '6'; break;
        default: languageId = '1';
      }

      final Map<String, String> requestBody = {
        'cid': finalCid,
        'mobile': finalMobile,
        'story_title': title,
        'story_description': description.length > 500 ? description.substring(0, 500) : description,
        'author_name': finalAuthor,
        'age': '21',
        'category': categoryId,
        'language': languageId,
        'action': 'publish',
        'ln': finalLn.toString(),
        'lt': finalLt.toString(),
        'device_id': finalDeviceId,
        'type': '2503',
      };

      var request = http.MultipartRequest('POST', url);
      request.fields.addAll(requestBody);

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('header_image', imageFile.path));
      }

      if (pdfFile != null) {
        request.files.add(await http.MultipartFile.fromPath('pdf_document', pdfFile.path));
      }

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│      UPLOAD STORY REQUEST            │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ URL  : $url');
      debugPrint('│ BODY : $requestBody');
      debugPrint('│ FILES: image=${imageFile?.path}, pdf=${pdfFile?.path}');
      debugPrint('└──────────────────────────────────────┘');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('┌──────────────────────────────────────┐');
      debugPrint('│      UPLOAD STORY RESPONSE           │');
      debugPrint('├──────────────────────────────────────┤');
      debugPrint('│ STATUS : ${response.statusCode}');
      debugPrint('│ BODY   : ${response.body}');
      debugPrint('└──────────────────────────────────────┘');

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['error'] == true) {
            _errorMessage = decoded['error_msg'] ?? 'Failed to upload story';
            return false;
          } else {
            _successMessage = 'Story uploaded successfully';
            return true;
          }
        } catch (e) {
          debugPrint('JSON Decode Error: $e');
          String cleanError = response.body.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
          if (cleanError.length > 150) {
             cleanError = '${cleanError.substring(0, 150)}...';
          }
          if (cleanError.isEmpty) cleanError = 'Invalid response format.';
          _errorMessage = 'Server error: $cleanError';
          return false;
        }
      } else {
        _errorMessage = 'Failed to upload story';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
