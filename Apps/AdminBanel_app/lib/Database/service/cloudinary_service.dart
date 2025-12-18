import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

/// خدمة رفع الصور إلى Cloudinary
/// 
/// للعمل بشكل صحيح، يجب إنشاء Upload Preset في لوحة Cloudinary:
/// 1. اذهب إلى Settings → Upload → Upload presets
/// 2. انشئ preset جديد باسم: ecommerce_unsigned
/// 3. اختر Signing Mode: Unsigned
/// 4. احفظ الإعدادات
/// 
/// راجع ملف CLOUDINARY_SETUP.md للتفاصيل الكاملة
class CloudinaryService {
  static const String cloudName = "duhq3yufs";
  static const String uploadPreset = "ecommerce_unsigned";

  /// رفع الصورة إلى Cloudinary (يدعم Web و Mobile)
  Future<String> uploadImage({
    required dynamic imageFile,
    required String folder,
  }) async {
    try {
      if (imageFile == null) {
        throw Exception('Image file is null');
      }
      
      if (kIsWeb && imageFile is! Uint8List) {
        throw Exception('On web, expected Uint8List but got ${imageFile.runtimeType}');
      }

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder;

      if (kIsWeb && imageFile is Uint8List) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile,
            filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return responseData['secure_url'];
      } else {
        try {
          final errorData = json.decode(responseBody);
          final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
          throw Exception('Cloudinary upload failed: $errorMessage');
        } catch (e) {
          throw Exception('Cloudinary upload failed (${response.statusCode}): $responseBody');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}

