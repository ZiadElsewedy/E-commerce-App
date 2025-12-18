// ============================================
// مثال على استخدام ImagePickerService
// USAGE EXAMPLE - ImagePickerService
// ============================================
//
// ✅ يدعم جميع المنصات: Web, Mobile, Desktop
// ✅ Supports all platforms: Web, Mobile, Desktop
//
// ============================================

import 'image_picker_service.dart';
import 'cloudinary_service.dart';
import 'firestore_image_service.dart';
import 'image_upload_flow.dart';

// ============================================
// مثال 1: استخدام ImagePickerService مباشرة
// Example 1: Using ImagePickerService directly
// ============================================
Future<void> example1_pickImageOnly() async {
  // اختيار صورة من المعرض أو سطح المكتب
  // يعمل على جميع المنصات (Web, Mobile, Desktop)
  final dynamic image = await ImagePickerService.pickImage();
  
  if (image != null) {
    print('✅ تم اختيار الصورة بنجاح');
    // على Web: image هو Uint8List
    // على Mobile/Desktop: image هو File
  } else {
    print('❌ لم يتم اختيار صورة');
  }
}

// ============================================
// مثال 2: رفع الصورة يدوياً بدون الـ Flow
// Example 2: Manual upload without using flow
// ============================================
Future<void> example2_manualUpload() async {
  // 1) اختيار الصورة (يدعم جميع المنصات)
  final dynamic imageFile = await ImagePickerService.pickImage();
  
  if (imageFile == null) {
    print('❌ لم يتم اختيار صورة');
    return;
  }
  
  // 2) رفعها إلى Cloudinary (يدعم جميع المنصات تلقائياً)
  final cloudinaryService = CloudinaryService();
  final String imageUrl = await cloudinaryService.uploadImage(
    imageFile: imageFile, // يدعم File أو Uint8List
    folder: 'banners', // أو أي مجلد آخر (products, categories, promos)
  );
  
  // 3) حفظها في Firestore
  final firestoreService = FirestoreImageService();
  await firestoreService.updateImageUrl(
    collection: 'banners',
    docId: 'banner_123',
    imageUrl: imageUrl,
  );
  
  print('✅ تم رفع الصورة بنجاح: $imageUrl');
}

// ============================================
// مثال 3: استخدام الـ Flow الجاهز (موصى به) ⭐
// Example 3: Using the ready flow (RECOMMENDED) ⭐
// ============================================
// هذا هو الطريقة الأفضل والأسهل!
// This is the best and easiest way!
Future<void> example3_useUploadFlow() async {
  try {
    final String imageUrl = await uploadAndSaveImage(
      pickImage: () => ImagePickerService.pickImage(),
      cloudinaryFolder: 'categories', // products, banners, promos, categories
      firestoreCollection: 'categories',
      docId: 'category_123',
    );
    
    print('✅ تم رفع وحفظ الصورة: $imageUrl');
  } catch (e) {
    print('❌ خطأ: $e');
  }
}

// ============================================
// مثال 4: استخدام في Cubit (نمط موصى به) 🎯
// Example 4: Using in Cubit (Recommended Pattern) 🎯
// ============================================
/*
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Database/service/image_upload_flow.dart';
import '../../../../Database/service/image_picker_service.dart';

// حالات البانر
abstract class BannerImageState {}
class BannerImageInitial extends BannerImageState {}
class BannerImageLoading extends BannerImageState {}
class BannerImageUploaded extends BannerImageState {
  final String imageUrl;
  BannerImageUploaded(this.imageUrl);
}
class BannerImageError extends BannerImageState {
  final String error;
  BannerImageError(this.error);
}

// Cubit للبانر
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
// مثال 5: استخدام في UI مباشرة 🎨
// Example 5: Using directly in UI 🎨
// ============================================
/*
// في StatefulWidget
bool _isUploading = false;
String? _imageUrl;

ElevatedButton(
  onPressed: _isUploading ? null : () async {
    setState(() => _isUploading = true);
    
    try {
      // اختيار ورفع الصورة (يدعم جميع المنصات)
      final imageUrl = await uploadAndSaveImage(
        pickImage: () => ImagePickerService.pickImage(),
        cloudinaryFolder: "promos",
        firestoreCollection: "promos",
        docId: promoId,
      );
      
      // تحديث الـ UI
      setState(() {
        _imageUrl = imageUrl;
        _isUploading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم رفع الصورة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: _isUploading
      ? CircularProgressIndicator(color: Colors.white)
      : Text('Upload Image'),
)
*/

// ============================================
// مثال 6: رفع الصورة فقط بدون Firestore ⚡
// Example 6: Upload to Cloudinary only (no Firestore) ⚡
// ============================================
/*
// مفيد عند إنشاء منتج جديد (قبل الحفظ)
Future<String?> uploadImageOnly() async {
  try {
    // 1. اختيار الصورة
    final imageFile = await ImagePickerService.pickImage();
    if (imageFile == null) return null;
    
    // 2. رفع إلى Cloudinary فقط
    final cloudinaryService = CloudinaryService();
    final imageUrl = await cloudinaryService.uploadImage(
      imageFile: imageFile,
      folder: 'products',
    );
    
    return imageUrl;
  } catch (e) {
    print('❌ خطأ: $e');
    return null;
  }
}

// استخدام في نموذج إضافة منتج:
ElevatedButton(
  onPressed: () async {
    final imageUrl = await uploadImageOnly();
    if (imageUrl != null) {
      setState(() {
        _imageUrlController.text = imageUrl;
      });
    }
  },
  child: Text('Upload Image'),
)
*/

// ============================================
// ملاحظات مهمة 📝
// Important Notes 📝
// ============================================
/*
1. ✅ يدعم جميع المنصات: Web, iOS, Android, Desktop
2. ✅ رفع الصور إلى Cloudinary تلقائياً
3. ✅ حفظ الروابط في Firestore
4. ✅ معالجة الأخطاء تلقائياً

المجلدات المتاحة في Cloudinary:
- products    (المنتجات)
- banners     (البانرات)
- categories  (الفئات)
- promos      (العروض)

للحصول على أفضل أداء:
- استخدم uploadAndSaveImage() للحفظ المباشر
- استخدم CloudinaryService فقط للرفع بدون حفظ
- استخدم Cubit للتطبيقات الكبيرة
*/

