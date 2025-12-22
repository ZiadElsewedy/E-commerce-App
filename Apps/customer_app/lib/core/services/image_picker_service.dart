import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// خدمة اختيار الصور من المعرض أو الكاميرا
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// اختيار صورة من المعرض
  static Future<dynamic> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        return await pickedFile.readAsBytes();
      } else {
        return File(pickedFile.path);
      }
    } catch (e) {
      throw Exception('Image selection failed: $e');
    }
  }

  /// اختيار صورة من الكاميرا
  static Future<dynamic> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        return await pickedFile.readAsBytes();
      } else {
        return File(pickedFile.path);
      }
    } catch (e) {
      throw Exception('Image selection from camera failed: $e');
    }
  }
}

