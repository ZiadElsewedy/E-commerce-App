import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_tile.dart';
import '../widgets/profile_loading.dart' as widgets;
import 'edit_profile_page.dart';
import '../../../auth/Presentation/Pages/Login_Page.dart';
import '../../../Orders/presentation/pages/orders_page.dart';
import '../../../Orders/presentation/cubit/order_cubit.dart';
import '../../../Orders/data/repositories/order_repository_impl.dart';
import '../../../Orders/data/datasources/order_remote_datasource.dart';

/// ProfilePage - User profile page
/// 
/// Displays user profile information and actions
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data on init
    context.read<ProfileCubit>().getMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // Show snackbar for update success
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          
          // Show snackbar for errors
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
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const widgets.ProfileLoading();
          }

          if (state is ProfileError) {
            return _buildErrorView(state.message);
          }

          if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
            final profile = state is ProfileLoaded 
                ? state.profile 
                : (state as ProfileUpdateSuccess).profile;
            
            return RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().getMyProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header
                    ProfileHeader(profile: profile),
                    
                    const SizedBox(height: 24),
                    
                    // Actions Section
                    _buildActionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Settings Section (optional placeholder)
                    _buildSettingsSection(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// بناء قسم الإجراءات
  /// Builds actions section
  Widget _buildActionsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        ProfileTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your profile information',
          iconColor: theme.colorScheme.primary,
          onTap: _navigateToEditProfile,
        ),
        
        ProfileTile(
          icon: Icons.shopping_bag,
          title: 'My Orders',
          subtitle: 'View your order history',
          iconColor: theme.colorScheme.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => OrderCubit(
                    repository: OrderRepositoryImpl(
                      dataSource: OrderRemoteDataSource(),
                    ),
                  ),
                  child: const OrdersPage(),
                ),
              ),
            );
          },
        ),
        
        ProfileTile(
          icon: Icons.favorite,
          title: 'My Wishlist',
          subtitle: 'View your saved items',
          iconColor: theme.colorScheme.secondary,
          onTap: () {
            // TODO: Navigate to wishlist page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Wishlist page coming soon')),
            );
          },
        ),
        
        ProfileTile(
          icon: Icons.location_on,
          title: 'Addresses',
          subtitle: 'Manage your addresses',
          iconColor: theme.colorScheme.secondary,
          onTap: () {
            // TODO: Navigate to addresses page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Addresses page coming soon')),
            );
          },
        ),
      ],
    );
  }

  /// بناء قسم الإعدادات
  /// Builds settings section
  Widget _buildSettingsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        ProfileTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage notification settings',
          iconColor: theme.colorScheme.secondary,
          onTap: () {
            // TODO: Navigate to notifications settings
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifications settings coming soon')),
            );
          },
        ),
        
        ProfileTile(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          iconColor: theme.colorScheme.secondary,
          onTap: () {
            // TODO: Navigate to help page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Help page coming soon')),
            );
          },
        ),
        
        ProfileTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          iconColor: theme.colorScheme.error,
          onTap: _handleLogout,
        ),
      ],
    );
  }

  /// التنقل إلى صفحة تعديل الملف الشخصي
  /// Navigates to edit profile page
  void _navigateToEditProfile() async {
    final profile = context.read<ProfileCubit>().getCurrentProfile();
    if (profile != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: EditProfilePage(profile: profile),
          ),
        ),
      );
    }
  }

  /// معالجة تسجيل الخروج
  /// Handles logout action
  void _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
        
        // Navigate to login page and remove all previous routes
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// بناء عرض الخطأ
  /// Builds error view
  Widget _buildErrorView(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileCubit>().getMyProfile();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

