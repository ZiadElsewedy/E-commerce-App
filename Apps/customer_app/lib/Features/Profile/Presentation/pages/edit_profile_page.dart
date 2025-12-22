import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Data/Models/profile_user_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/image_picker_service.dart';

/// EditProfilePage - Page to edit user profile information
/// 
/// Allows users to update their profile data
class EditProfilePage extends StatefulWidget {
  final ProfileUserModel profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _photoUrlController;
  
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _photoUrlController = TextEditingController(text: widget.profile.photoUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }
          
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Pop back to profile page
            Navigator.pop(context);
          }
          
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Preview
                  _buildPhotoPreview(),
                  
                  const SizedBox(height: 16),
                  
                  // Upload Image Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isUploadingImage ? null : _handleImageUpload,
                      icon: _isUploadingImage
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isUploadingImage ? 'Uploading...' : 'Upload Photo'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider with "OR" text
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.colorScheme.surfaceContainerHighest)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.colorScheme.surfaceContainerHighest)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Phone Field
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      // Phone is optional
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Field (read-only)
                  _buildTextField(
                    controller: TextEditingController(text: widget.profile.email),
                    label: 'Email',
                    icon: Icons.email,
                    enabled: false,
                    validator: null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Photo URL Field
                  _buildTextField(
                    controller: _photoUrlController,
                    label: 'Photo URL (optional)',
                    icon: Icons.image,
                    keyboardType: TextInputType.url,
                    maxLines: 2,
                    validator: (value) {
                      // Photo URL is optional
                      if (value != null && value.isNotEmpty) {
                        if (!Uri.tryParse(value)!.hasAbsolutePath) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        side: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء معاينة صورة الملف الشخصي
  /// Builds profile photo preview
  Widget _buildPhotoPreview() {
    final theme = Theme.of(context);
    return Center(
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _photoUrlController,
        builder: (context, value, child) {
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surfaceContainerHighest,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: value.text.isNotEmpty
                  ? Image.network(
                      value.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildAvatarLoading();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          );
        },
      ),
    );
  }

  /// صورة افتراضية
  /// Default avatar icon
  Widget _buildDefaultAvatar() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 60,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// مؤشر تحميل الصورة
  /// Avatar loading indicator
  Widget _buildAvatarLoading() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// بناء حقل نصي
  /// Builds text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: enabled ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
        ),
      ),
    );
  }

  /// معالجة رفع الصورة
  /// Handles image upload
  Future<void> _handleImageUpload() async {
    try {
      setState(() => _isUploadingImage = true);

      // Pick image
      final imageFile = await ImagePickerService.pickImage();
      if (imageFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      // Upload to Cloudinary
      final cloudinaryService = CloudinaryService();
      final imageUrl = await cloudinaryService.uploadImage(
        imageFile: imageFile,
        folder: 'users', // Profile photos in 'users' folder
      );

      // Update the photo URL controller
      setState(() {
        _photoUrlController.text = imageUrl;
        _isUploadingImage = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo uploaded successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// معالجة حفظ التعديلات
  /// Handles save action
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Create updated profile
      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty 
            ? null 
            : _photoUrlController.text.trim(),
      );

      // Update profile via cubit
      context.read<ProfileCubit>().updateMyProfile(updatedProfile);
    }
  }
}

