import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageServices {
  // ── Cloudinary config (free plan, no credit card needed) ──
  // Replace with your actual Cloud Name from cloudinary.com dashboard
  static const String _cloudName    = 'dai2erkmg';
  static const String _uploadPreset = 'interntask_uploads'; // unsigned preset

  /// Uploads [file] to Cloudinary under [folder] and returns the secure URL.
  Future<String> uploadImage(File file, String folder) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder']        = folder
        ..files.add(
          await http.MultipartFile.fromPath('file', file.path),
        );

      // 30-second timeout — prevents infinite spinner
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw 'Upload timed out. Check your internet connection.',
      );

      final bytes = await streamedResponse.stream.toBytes().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Upload response timed out.',
      );
      final body  = String.fromCharCodes(bytes);
      final json  = jsonDecode(body) as Map<String, dynamic>;

      if (streamedResponse.statusCode == 200) {
        return json['secure_url'] as String;
      } else {
        // Cloudinary returns {"error":{"message":"..."}} on failure
        final msg = (json['error'] as Map?)?['message']
            ?? 'Upload failed (HTTP ${streamedResponse.statusCode}).\n'
               'Make sure the upload preset "interntask_uploads" exists '
               'in your Cloudinary dashboard under Settings → Upload → Upload Presets.';
        throw msg.toString();
      }
    } on SocketException {
      throw 'No internet connection. Please check your network.';
    } catch (e) {
      rethrow;
    }
  }
}
