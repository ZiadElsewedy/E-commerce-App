# Profile Feature Documentation

## 📋 Overview

The Profile feature is a complete user profile management system that allows users to view and update their profile information, including profile photos. It follows the same clean architecture pattern used throughout the app and integrates seamlessly with Firebase Authentication and Firestore.

## 🏗️ Architecture

The Profile feature follows the **Clean Architecture** pattern with three main layers:

```
Features/Profile/
├── Domain/              # Business logic layer
│   └── repositories/   # Repository interface
├── Data/               # Data layer
│   ├── datasources/   # Remote data source (Firestore)
│   ├── Models/        # Data models
│   └── repositories/   # Repository implementation
└── Presentation/       # UI layer
    ├── cubit/         # State management
    ├── pages/         # UI pages
    └── widgets/       # Reusable widgets
```

## 📦 What Was Implemented

### 1. **Data Model** (`ProfileUserModel`)
- **Extends** `AppUser` from the auth feature (no duplication)
- **Additional fields**:
  - `photoUrl` - Profile photo URL (Cloudinary)
  - `language`, `theme`, `notificationEnabled` - User preferences
  - `ordersCount`, `wishlistCount`, `addressesCount` - Statistics
- **Full JSON serialization** for Firestore mapping
- **Methods**: `fromJson()`, `toJson()`, `copyWith()`, `fromAppUser()`

### 2. **Domain Layer**
- **`ProfileRepository`** interface defining:
  - `getMyProfile()` - Fetch current user's profile
  - `updateMyProfile()` - Update user profile

### 3. **Data Layer**
- **`ProfileRemoteDataSource`**:
  - Fetches profile from Firestore `users` collection
  - **Auto-creates profile** if document doesn't exist (from Firebase Auth data)
  - Updates profile with merge strategy
- **`ProfileRepositoryImpl`** - Implements repository interface

### 4. **State Management** (Cubit)
- **`ProfileCubit`** with states:
  - `ProfileInitial` - Initial state
  - `ProfileLoading` - Loading state
  - `ProfileLoaded` - Success with profile data
  - `ProfileUpdateSuccess` - Update successful
  - `ProfileError` - Error state
- **Methods**:
  - `getMyProfile()` - Load profile data
  - `updateMyProfile()` - Update profile
  - `getCurrentProfile()` - Get profile from state

### 5. **UI Pages**

#### **ProfilePage** (`profile_page.dart`)
- **Displays**:
  - User avatar (network image with fallback)
  - Name, email, phone
  - Action tiles (Edit Profile, Orders, Wishlist, Addresses, etc.)
  - Settings section (Notifications, Help, Logout)
- **States**:
  - Loading skeleton UI
  - Error view with retry
  - Success view with profile data
- **Features**:
  - Pull-to-refresh
  - Logout with confirmation dialog
  - Navigation to Edit Profile

#### **EditProfilePage** (`edit_profile_page.dart`)
- **Form fields**:
  - Name (required)
  - Phone (optional)
  - Email (read-only)
  - Photo URL (optional)
- **Cloudinary Integration**:
  - "Upload Photo" button
  - Image picker (gallery)
  - Automatic upload to Cloudinary
  - Live photo preview
  - Manual URL entry (fallback)
- **Validation**:
  - Name required
  - URL format validation
- **Success handling**: Shows snackbar and pops back

### 6. **Reusable Widgets**
- **`ProfileHeader`** - Avatar + user info display
- **`ProfileTile`** - Action list tile component
- **`ProfileLoading`** - Skeleton loading UI

### 7. **Cloudinary Integration**

#### **Services Created** (`lib/core/services/`)
- **`CloudinaryService`**:
  - Uploads images to Cloudinary
  - Supports Web (Uint8List) and Mobile (File)
  - Uses folder: `users` for profile photos
  - Config: `cloudName: "duhq3yufs"`, `uploadPreset: "ecommerce_unsigned"`
  
- **`ImagePickerService`**:
  - Picks images from gallery
  - Cross-platform support (Web, iOS, Android, Desktop)
  - Returns appropriate format per platform

#### **Dependencies Added** (`pubspec.yaml`)
```yaml
http: ^1.2.0          # For Cloudinary API calls
image_picker: ^1.0.7  # For image selection
```

## 🔄 How It Works

### Profile Loading Flow
1. User opens Profile page
2. `ProfileCubit.getMyProfile()` is called
3. `ProfileRepository.getMyProfile()` fetches from Firestore
4. If document doesn't exist:
   - Creates `ProfileUserModel` from Firebase Auth data
   - Auto-creates Firestore document
   - Returns profile
5. UI displays profile data

### Profile Update Flow
1. User taps "Edit Profile"
2. User fills form and/or uploads photo
3. Photo upload (if selected):
   - Image picker opens
   - Image uploads to Cloudinary
   - URL is auto-filled in form
4. User taps "Save Changes"
5. `ProfileCubit.updateMyProfile()` is called
6. Profile updates in Firestore (creates if doesn't exist)
7. Success snackbar shown, navigates back

### Logout Flow
1. User taps "Logout"
2. Confirmation dialog appears
3. If confirmed:
   - `FirebaseAuth.signOut()` is called
   - Navigates to LoginPage
   - Removes all previous routes

## 🗂️ File Structure

```
Features/Profile/
├── Domain/
│   └── repositories/
│       └── profile_repository.dart          # Repository interface
├── Data/
│   ├── datasources/
│   │   └── profile_remote_data_source.dart  # Firestore operations
│   ├── Models/
│   │   └── profile_user_model.dart          # ProfileUserModel extends AppUser
│   └── repositories/
│       └── profile_repository_impl.dart      # Repository implementation
└── Presentation/
    ├── cubit/
    │   ├── profile_cubit.dart                # State management
    │   └── profile_state.dart                # State classes
    ├── pages/
    │   ├── profile_page.dart                 # Main profile page
    │   └── edit_profile_page.dart           # Edit profile page
    └── widgets/
        ├── profile_header.dart              # Avatar + info header
        ├── profile_tile.dart                # Action list tile
        └── profile_loading.dart             # Loading skeleton

lib/core/services/
├── cloudinary_service.dart                  # Cloudinary upload service
└── image_picker_service.dart                # Image picker service
```

## 🔌 Integration Points

### 1. **Main App** (`main.dart`)
```dart
// Profile repository and cubit registration
final profileRepository = ProfileRepositoryImpl(
  dataSource: ProfileRemoteDataSource(),
);

BlocProvider(
  create: (context) => ProfileCubit(repository: profileRepository),
)
```

### 2. **HomeScreen** (`HomeScreen.dart`)
```dart
// Profile icon button in AppBar
IconButton(
  onPressed: () => _navigateToProfile(),
  icon: Icon(Icons.person_outline),
)

// Navigation method
void _navigateToProfile() {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const ProfilePage()),
  );
}
```

## 🎯 Key Features

✅ **No Auth Feature Modification** - Profile feature doesn't touch `Features/auth`  
✅ **Extends AppUser** - ProfileUserModel extends AppUser (no duplication)  
✅ **Auto-Create Profile** - Creates profile from Firebase Auth if Firestore doc missing  
✅ **Cloudinary Upload** - Direct image upload with automatic URL handling  
✅ **Cross-Platform** - Works on Web, iOS, Android, Desktop  
✅ **Error Handling** - Comprehensive error states and user-friendly messages  
✅ **Loading States** - Skeleton UI during loading  
✅ **Form Validation** - Required fields and URL format validation  
✅ **Live Preview** - Photo preview updates as URL changes  
✅ **Logout Integration** - Secure logout with confirmation  

## 📝 Firestore Structure

### Collection: `users`
### Document ID: `FirebaseAuth.currentUser.uid`

```json
{
  "user_id": "abc123...",
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "photo_url": "https://res.cloudinary.com/.../image.jpg",
  "language": "en",
  "theme": "light",
  "notification_enabled": true,
  "orders_count": 5,
  "wishlist_count": 3,
  "addresses_count": 2,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## 🚀 Usage Examples

### Loading Profile
```dart
// In ProfilePage initState
context.read<ProfileCubit>().getMyProfile();

// In UI
BlocBuilder<ProfileCubit, ProfileState>(
  builder: (context, state) {
    if (state is ProfileLoaded) {
      final profile = state.profile;
      return ProfileHeader(profile: profile);
    }
    // ... other states
  },
)
```

### Updating Profile
```dart
final updatedProfile = currentProfile.copyWith(
  name: 'New Name',
  phone: '+1234567890',
  photoUrl: 'https://cloudinary.com/...',
);

context.read<ProfileCubit>().updateMyProfile(updatedProfile);
```

### Uploading Photo
```dart
// In EditProfilePage
final imageFile = await ImagePickerService.pickImage();
final cloudinaryService = CloudinaryService();
final imageUrl = await cloudinaryService.uploadImage(
  imageFile: imageFile,
  folder: 'users',
);
// imageUrl is automatically set in the form
```

## 🔧 Configuration

### Cloudinary Setup
The Cloudinary service uses:
- **Cloud Name**: `duhq3yufs`
- **Upload Preset**: `ecommerce_unsigned`
- **Folder**: `users` (for profile photos)

Make sure the upload preset `ecommerce_unsigned` exists in your Cloudinary dashboard with:
- Signing Mode: **Unsigned**
- Folder: `users` (optional, can be set per upload)

## ⚠️ Important Notes

1. **Profile Auto-Creation**: If a user doesn't have a Firestore document, one is automatically created from Firebase Auth data when they first open the Profile page.

2. **Update Strategy**: Uses `set()` with `merge: true` to create or update documents, ensuring it works even if the document doesn't exist.

3. **Photo URL**: Users can either:
   - Upload via Cloudinary (recommended)
   - Manually enter a URL (fallback)

4. **Error Handling**: All errors are caught and displayed as user-friendly messages in snackbars.

5. **State Management**: Uses Cubit (not Bloc) to match the existing codebase pattern.

## 🐛 Troubleshooting

### "Profile data not found" Error
- **Fixed**: Profile now auto-creates from Firebase Auth if Firestore doc doesn't exist

### Image Upload Fails
- Check Cloudinary upload preset exists
- Verify network connection
- Check Cloudinary credentials

### Photo Not Displaying
- Verify URL is valid
- Check network image loading
- Ensure URL is accessible

## 📚 Related Files

- **Auth Entity**: `Features/auth/Domain/Entities/App_User.dart`
- **Auth Repository**: `Features/auth/data/Firebase_auth_repo.dart`
- **Main App**: `main.dart`
- **Home Screen**: `Features/Home/HomeScreen.dart`

---

**Created**: Profile feature implementation with Cloudinary integration  
**Last Updated**: Profile auto-creation fix for missing Firestore documents

