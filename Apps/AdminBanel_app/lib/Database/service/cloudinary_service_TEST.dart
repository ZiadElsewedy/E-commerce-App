import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// نسخة تجريبية لاختبار Cloudinary بدون upload preset
class CloudinaryServiceTest {
  static const String cloudName = "duhq3yufs";
  
  /// اختبار رفع صورة بدون preset (سيفشل لكن سيعطينا معلومات مفيدة)
  Future<void> testConnection({required File imageFile}) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      // محاولة بدون preset
      final request = http.MultipartRequest("POST", uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
          ),
        );

      print('Testing Cloudinary connection...');
      print('URL: $uri');
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Status Code: ${response.statusCode}');
      print('Response: $responseBody');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS: Image uploaded!');
      } else {
        print('❌ FAILED: Check the response above');
        final errorData = json.decode(responseBody);
        print('Error Message: ${errorData['error']?['message']}');
      }
    } catch (e) {
      print('❌ EXCEPTION: $e');
    }
  }
  
  /// اختبار قائمة Upload Presets المتاحة
  Future<void> checkPresets() async {
    print('Note: You need to check presets manually in Cloudinary Dashboard');
    print('Go to: https://console.cloudinary.com/settings/upload');
    print('Look for: ecommerce_unsigned in the Upload presets section');
  }
}

