/// حالات رفع صورة المنتج
abstract class ProductImageState {}

/// الحالة الأولية
class ProductImageInitial extends ProductImageState {}

/// حالة التحميل
class ProductImageLoading extends ProductImageState {}

/// تم رفع الصورة بنجاح
class ProductImageUploaded extends ProductImageState {
  final String imageUrl;
  final String message;

  ProductImageUploaded(this.imageUrl, this.message);
}

/// حالة الخطأ
class ProductImageError extends ProductImageState {
  final String errorMessage;

  ProductImageError(this.errorMessage);
}

