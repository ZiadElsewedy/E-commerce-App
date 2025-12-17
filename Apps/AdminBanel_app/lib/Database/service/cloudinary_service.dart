import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  /// رفع الصورة إلى Cloudinary
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return responseData['secure_url'];
      } else {
        // طباعة تفاصيل الخطأ
        print('Cloudinary Error Status: ${response.statusCode}');
        print('Cloudinary Error Body: $responseBody');
        
        try {
          final errorData = json.decode(responseBody);
          throw Exception('Cloudinary upload failed: ${errorData['error']?['message'] ?? responseBody}');
        } catch (e) {
          throw Exception('Cloudinary upload failed (${response.statusCode}): $responseBody');
        }
      }
    } catch (e) {
      print('Upload Exception: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}

