import 'cloudinary_service.dart';
import 'firestore_image_service.dart';

/// رفع وحفظ الصورة في Cloudinary و Firestore
/// يدعم جميع المنصات: Web (Uint8List), Mobile/Desktop (File)
Future<String> uploadAndSaveImage({
  required Future<dynamic> Function() pickImage,
  required String cloudinaryFolder,
  required String firestoreCollection,
  required String docId,
}) async {
  // 1) اختيار الصورة
  final imageFile = await pickImage();
  if (imageFile == null) {
    throw Exception('No image selected');
  }

  // 2) رفع الصورة إلى Cloudinary
  final cloudinaryService = CloudinaryService();
  final imageUrl = await cloudinaryService.uploadImage(
    imageFile: imageFile,
    folder: cloudinaryFolder,
  );

  // 3) حفظ رابط الصورة في Firestore
  final firestoreService = FirestoreImageService();
  await firestoreService.updateImageUrl(
    collection: firestoreCollection,
    docId: docId,
    imageUrl: imageUrl,
  );

  // 4) إرجاع رابط الصورة
  return imageUrl;
}

