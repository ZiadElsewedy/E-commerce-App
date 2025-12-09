/// AppUser - Entity class representing a user in the application.
/// 
/// This class contains user information including ID, email, password,
/// name, and optional phone number. It provides methods to convert
/// between JSON format and AppUser objects.
class AppUser {
  /// Unique identifier for the user
  final String userId;
  
  /// User's email address
  final String email;
  
  /// User's password (should be hashed in production
  
  /// User's full name
  final String? name;
  
  /// User's phone number (optional)
  final String? phone;


  AppUser({
    required this.userId,
    required this.email,
    this.name,
    this.phone,
  });

  /// Converts AppUser object to JSON format
  /// 
  /// Returns a Map containing all user data in JSON format
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'name': name,
        'phone': phone,
      };

  /// Factory constructor to create AppUser from JSON
  /// 
  /// Parameters:
  /// - [json] - Map containing user data in JSON format
  /// 
  /// Returns an AppUser object created from the JSON data
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        userId: json['user_id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
      );

  /// Creates a copy of the AppUser with updated fields
  /// 
  /// Parameters are optional - only provided fields will be updated
  /// 
  /// Returns a new AppUser instance with updated values
  AppUser copyWith({
    String? userId,
    String? email,
    String? name,
    String? phone,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  /// Returns a string representation of the AppUser
  @override
  String toString() {
    return 'AppUser(userId: $userId, email: $email, name: $name, phone: $phone)';
  }

  /// Compares two AppUser objects for equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.userId == userId &&
        other.email == email &&
        other.name == name &&
        other.phone == phone;
  }

  /// Returns the hash code of the AppUser
  @override
  int get hashCode {
    return userId.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phone.hashCode;
  }
}
