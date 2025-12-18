import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// تحديث رابط الصورة في Firestore
  Future<void> updateImageUrl({
    required String collection,
    required String docId,
    required String imageUrl,
    String imageField = "imageUrl",
  }) async {
    await _firestore.collection(collection).doc(docId).update({
      imageField: imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

