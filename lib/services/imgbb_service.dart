import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImgbbService {
  final ImagePicker _picker = ImagePicker();

  String _sanitizeImageUrl(String rawUrl) {
    final cleaned = rawUrl.trim().replaceAll('\\/', '/');
    final initialUri = Uri.tryParse(cleaned);

    if (initialUri == null || initialUri.host.isEmpty) {
      throw Exception('ImgBB returned invalid image URL: $rawUrl');
    }

    // Fix common malformed host variants found in some stored data.
    String fixedHost = initialUri.host;
    if (fixedHost == 'i.ibb.co') {
      fixedHost = 'i.ibb.co.com';
    } else if (fixedHost == 'ibb.co') {
      fixedHost = 'ibb.co.com';
    }

    final uri = initialUri.replace(host: fixedHost);

    if (uri.host.isEmpty) {
      throw Exception('ImgBB returned invalid image URL: $rawUrl');
    }

    // Force https for stable TLS behavior.
    if (uri.scheme != 'https') {
      return uri.replace(scheme: 'https').toString();
    }

    return uri.toString();
  }

  String _validatedApiKey() {
    final key = dotenv.env['IMGBB_API_KEY']?.trim() ?? '';

    if (key.isEmpty) {
      throw Exception('ImgBB API key not found in .env');
    }

    return key;
  }

  Future<String?> pickAndUploadImage({
    required ImageSource source,
  }) async {
    final apiKey = _validatedApiKey();

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1280,
    );

    if (image == null) return null;

    final uri = Uri.parse('https://api.imgbb.com/1/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['key'] = apiKey
      ..files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // print("IMG BB RESPONSE:");
    // print(responseBody);
    
    Map<String, dynamic>? parsed;

    try {
      parsed = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      parsed = null;
    }

    if (response.statusCode != 200) {
      final errorMessage = parsed?['error']?['message'] ?? responseBody;
      throw Exception(
        'ImgBB upload failed: HTTP ${response.statusCode} - $errorMessage',
      );
    }

    final Map<String, dynamic> data = parsed ?? jsonDecode(responseBody);
    final bool success = data['success'] as bool? ?? false;

    if (!success) {
      throw Exception('ImgBB upload failed: $responseBody');
    }

    final dataObj = data['data'] as Map<String, dynamic>?;
    final String? rawUrl =
          dataObj?['url'] as String? ??
          dataObj?['image']?['url'] as String? ??
          dataObj?['display_url'] as String?;

    if (rawUrl == null || rawUrl.isEmpty) {
      throw Exception('ImgBB upload failed: no image URL returned.');
    }

    return _sanitizeImageUrl(rawUrl);
  }
}
