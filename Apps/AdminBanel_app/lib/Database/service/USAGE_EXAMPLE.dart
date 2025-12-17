// ============================================
// مثال على استخدام ImagePickerService
// USAGE EXAMPLE - ImagePickerService
// ============================================

import 'dart:io';
import 'image_picker_service.dart';
import 'cloudinary_service.dart';
import 'firestore_image_service.dart';
import 'image_upload_flow.dart';

// ============================================
// مثال 1: استخدام ImagePickerService مباشرة
// Example 1: Using ImagePickerService directly
// ============================================
Future<void> example1_pickImageOnly() async {
  // اختيار صورة من المعرض
  final File? image = await ImagePickerService.pickImageFromGallery();
  
  if (image != null) {
    print('تم اختيار الصورة: ${image.path}');
  } else {
    print('لم يتم اختيار صورة');
  }
}

// ============================================
// مثال 2: رفع الصورة يدوياً بدون الـ Flow
// Example 2: Manual upload without using flow
// ============================================
Future<void> example2_manualUpload() async {
  // 1) اختيار الصورة
  final File? imageFile = await ImagePickerService.pickImage();
  
  if (imageFile == null) {
    print('لم يتم اختيار صورة');
    return;
  }
  
  // 2) رفعها إلى Cloudinary
  final cloudinaryService = CloudinaryService();
  final String imageUrl = await cloudinaryService.uploadImage(
    imageFile: imageFile,
    folder: 'banners', // أو أي مجلد آخر
  );
  
  // 3) حفظها في Firestore
  final firestoreService = FirestoreImageService();
  await firestoreService.updateImageUrl(
    collection: 'banners',
    docId: 'banner_123',
    imageUrl: imageUrl,
  );
  
  print('تم رفع الصورة بنجاح: $imageUrl');
}

// ============================================
// مثال 3: استخدام الـ Flow الجاهز (موصى به)
// Example 3: Using the ready flow (RECOMMENDED)
// ============================================
Future<void> example3_useUploadFlow() async {
  try {
    final String imageUrl = await uploadAndSaveImage(
      pickImage: () => ImagePickerService.pickImage(),
      cloudinaryFolder: 'categories', // أو products أو banners أو promos
      firestoreCollection: 'categories',
      docId: 'category_123',
    );
    
    print('تم رفع وحفظ الصورة: $imageUrl');
  } catch (e) {
    print('خطأ: $e');
  }
}

// ============================================
// مثال 4: استخدام في Cubit آخر
// Example 4: Using in another Cubit
// ============================================
/*
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Database/service/image_upload_flow.dart';
import '../../../../Database/service/image_picker_service.dart';

class BannerImageCubit extends Cubit<BannerImageState> {
  BannerImageCubit() : super(BannerImageInitial());

  /// رفع وحفظ صورة البانر
  Future<void> uploadBannerImage({
    required String bannerId,
  }) async {
    emit(BannerImageLoading());

    try {
      final imageUrl = await uploadAndSaveImage(
        pickImage: () => ImagePickerService.pickImage(),
        cloudinaryFolder: "banners",
        firestoreCollection: "banners",
        docId: bannerId,
      );

      emit(BannerImageUploaded(imageUrl));
    } catch (e) {
      emit(BannerImageError(e.toString()));
    }
  }
}
*/

// ============================================
// مثال 5: استخدام في UI مباشرة
// Example 5: Using directly in UI
// ============================================
/*
ElevatedButton(
  onPressed: () async {
    try {
      // اختيار ورفع الصورة
      final imageUrl = await uploadAndSaveImage(
        pickImage: () => ImagePickerService.pickImage(),
        cloudinaryFolder: "promos",
        firestoreCollection: "promos",
        docId: promoId,
      );
      
      // تحديث الـ UI
      setState(() {
        _imageUrl = imageUrl;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفع الصورة بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  },
  child: Text('Upload Image'),
)
*/

