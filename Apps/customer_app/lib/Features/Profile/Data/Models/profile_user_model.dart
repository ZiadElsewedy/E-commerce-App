import 'package:ecommerceapp/Features/auth/Domain/Entities/App_User.dart';

/// ProfileUserModel - extends AppUser with profile-specific fields
/// 
/// This model adds app-specific fields like photoUrl and other extras
/// for the Profile feature while reusing the base AppUser entity.
class ProfileUserModel extends AppUser {
  /// User's profile photo URL
  final String? photoUrl;
  
  /// User's preferred language (optional)
  final String? language;
  
  /// User's theme preference (optional)
  final String? theme;
  
  /// Whether notifications are enabled
  final bool? notificationEnabled;
  
  /// Count of user's orders
  final int? ordersCount;
  
  /// Count of user's wishlist items
  final int? wishlistCount;
  
  /// Count of user's saved addresses
  final int? addressesCount;

  ProfileUserModel({
    required super.userId,
    required super.email,
    super.name,
    super.phone,
    this.photoUrl,
    this.language,
    this.theme,
    this.notificationEnabled,
    this.ordersCount,
    this.wishlistCount,
    this.addressesCount,
  });

  /// تحويل الكائن إلى JSON
  /// Converts ProfileUserModel to JSON including all fields
  @override
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'name': name,
        'phone': phone,
        'photo_url': photoUrl,
        'language': language,
        'theme': theme,
        'notification_enabled': notificationEnabled,
        'orders_count': ordersCount,
        'wishlist_count': wishlistCount,
        'addresses_count': addressesCount,
      };

  /// إنشاء كائن من JSON
  /// Factory constructor to create ProfileUserModel from JSON
  factory ProfileUserModel.fromJson(Map<String, dynamic> json) =>
      ProfileUserModel(
        userId: json['user_id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        photoUrl: json['photo_url'] as String?,
        language: json['language'] as String?,
        theme: json['theme'] as String?,
        notificationEnabled: json['notification_enabled'] as bool?,
        ordersCount: json['orders_count'] as int?,
        wishlistCount: json['wishlist_count'] as int?,
        addressesCount: json['addresses_count'] as int?,
      );

  /// إنشاء كائن من AppUser
  /// Factory constructor to create ProfileUserModel from AppUser
  factory ProfileUserModel.fromAppUser(AppUser user) => ProfileUserModel(
        userId: user.userId,
        email: user.email,
        name: user.name,
        phone: user.phone,
      );

  /// نسخ الكائن مع تحديث الحقول
  /// Creates a copy with updated fields
  @override
  ProfileUserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    String? language,
    String? theme,
    bool? notificationEnabled,
    int? ordersCount,
    int? wishlistCount,
    int? addressesCount,
  }) {
    return ProfileUserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      ordersCount: ordersCount ?? this.ordersCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      addressesCount: addressesCount ?? this.addressesCount,
    );
  }

  /// عرض الكائن كنص
  @override
  String toString() {
    return 'ProfileUserModel(userId: $userId, email: $email, name: $name, phone: $phone, photoUrl: $photoUrl)';
  }

  /// مقارنة الكائنات
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileUserModel &&
        other.userId == userId &&
        other.email == email &&
        other.name == name &&
        other.phone == phone &&
        other.photoUrl == photoUrl &&
        other.language == language &&
        other.theme == theme &&
        other.notificationEnabled == notificationEnabled &&
        other.ordersCount == ordersCount &&
        other.wishlistCount == wishlistCount &&
        other.addressesCount == addressesCount;
  }

  /// حساب الهاش كود
  @override
  int get hashCode {
    return userId.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        photoUrl.hashCode ^
        language.hashCode ^
        theme.hashCode ^
        notificationEnabled.hashCode ^
        ordersCount.hashCode ^
        wishlistCount.hashCode ^
        addressesCount.hashCode;
  }
}

