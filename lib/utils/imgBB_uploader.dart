import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const API_Key = 'aa39c1586073b98405d158dfea23eb31';

class ImgBBUploader {
  ImgBBUploader();

  /// Upload image using a File
  Future<String?> uploadImageFile(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {
        'key': API_Key,
        'image': base64Image,
        'name': 'flutter_upload_${DateTime.now().millisecondsSinceEpoch}',
      },
    );
    print('response $response');
    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['success']) {
      final imageUrl = result['data']['url'];
      print('✅ Image uploaded: $imageUrl');
      return imageUrl;
    } else {
      print('❌ Upload failed: ${result['error']['message']}');
      return null;
    }
  }
}
