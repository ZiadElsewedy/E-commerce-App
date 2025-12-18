import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/app_theme.dart';
import '../../../Promos/presentation/cubit/banners_cubit.dart';
import '../../../Promos/presentation/cubit/banners_states.dart';
import '../../../Promos/domain/entities/banner_entity.dart';
import '../../../Promos/presentation/widgets/banner_card_widget.dart';
import '../../../Promos/presentation/widgets/banner_form_sheet.dart';
import '../../../Categories/presentation/cubit/categories_cubit.dart';
import '../../../Categories/data/firebase_category_repository.dart';

/// Banners Management Page
/// Admin page for managing promotional banners (CRUD operations)
class BannersManagementPage extends StatefulWidget {
  const BannersManagementPage({super.key});

  @override
  State<BannersManagementPage> createState() => _BannersManagementPageState();
}

class _BannersManagementPageState extends State<BannersManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<BannersCubit>().fetchAllBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manage Banners',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BannersCubit>().fetchAllBanners();
            },
          ),
        ],
      ),
      body: BlocConsumer<BannersCubit, BannersState>(
        listener: (context, state) {
          if (state is BannerCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BannersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BannerDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BannersLoading || state is BannersInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BannersEmpty) {
            return _buildEmptyState();
          } else if (state is BannersLoaded) {
            return _buildBannersList(state.banners);
          } else if (state is BannersError) {
            return _buildErrorState(state.errorMessage);
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddBannerDialog();
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: Text(AppTheme.isMobile(context) ? 'Add' : 'Add Banner'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_carousel_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Banners Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first promotional banner',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _showAddBannerDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Banner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersList(List banners) {
    return RefreshIndicator(
      onRefresh: () => context.read<BannersCubit>().fetchAllBanners(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return BannerCardWidget(
            banner: banner,
            onEdit: () => _showEditBannerDialog(banner),
            onDelete: () => _showDeleteConfirmation(banner),
            onToggleStatus: () => context.read<BannersCubit>().updateBanner(
                  banner.copyWith(isActive: !banner.isActive),
                ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              context.read<BannersCubit>().fetchAllBanners();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Banners'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<BannersCubit>().fetchAllBanners();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Banners'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<BannersCubit>().fetchActiveBanners();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBannerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => CategoriesCubit(
          categoryRepository: FirebaseCategoryRepository(),
        ),
        child: BannerFormSheet(
          onSubmit: (banner) {
            this.context.read<BannersCubit>().createBanner(banner);
          },
        ),
      ),
    );
  }

  void _showEditBannerDialog(BannerEntity banner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => CategoriesCubit(
          categoryRepository: FirebaseCategoryRepository(),
        ),
        child: BannerFormSheet(
          banner: banner,
          onSubmit: (updatedBanner) {
            this.context.read<BannersCubit>().updateBanner(updatedBanner);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BannerEntity banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Banner'),
        content: Text(
          'Are you sure you want to delete "${banner.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BannersCubit>().deleteBanner(banner.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

