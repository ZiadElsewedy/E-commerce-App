import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Database/service/image_upload_flow.dart';
import 'product_image_states.dart';

class ProductImageCubit extends Cubit<ProductImageState> {
  ProductImageCubit() : super(ProductImageInitial());

  /// رفع وحفظ صورة المنتج
  Future<void> uploadProductImage({
    required Future<File?> Function() pickImage,
    required String productId,
  }) async {
    emit(ProductImageLoading());

    try {
      final imageUrl = await uploadAndSaveImage(
        pickImage: pickImage,
        cloudinaryFolder: "products",
        firestoreCollection: "products",
        docId: productId,
      );

      emit(ProductImageUploaded(imageUrl, 'تم رفع الصورة بنجاح'));
    } catch (e) {
      emit(ProductImageError(e.toString()));
    }
  }
}

