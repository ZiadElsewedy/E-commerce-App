import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// اختيار صورة من الاستوديو أو المعرض
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// اختيار صورة من الكاميرا
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  /// اختيار صورة (يعمل على كل المنصات)
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

  /// عرض خيارات اختيار الصورة (معرض أو كاميرا)
  static Future<File?> showImageSourceOptions({
    bool allowGallery = true,
    bool allowCamera = true,
  }) async {
    return await pickImage();
  }
}

