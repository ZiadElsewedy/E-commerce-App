import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/app_theme.dart';
import '../cubit/banners_cubit.dart';
import '../cubit/banners_states.dart';
import '../../domain/entities/banner_entity.dart';

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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: const Icon(Icons.view_carousel, color: Colors.orange),
            ),
            title: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner.description),
                const SizedBox(height: 4),
                Text(
                  'Priority: ${banner.priority}${banner.expiresAt != null ? ' • Expires: ${banner.expiresAt!.toString().split(' ')[0]}' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (banner.isActive && !banner.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                if (banner.isExpired)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Expired',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditBannerDialog(banner);
                    } else if (value == 'toggle') {
                      context.read<BannersCubit>().updateBanner(
                            banner.copyWith(isActive: !banner.isActive),
                          );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(banner);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            banner.isActive ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(banner.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imageUrlController = TextEditingController();
    final linkUrlController = TextEditingController();
    final priorityController = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
    DateTime? expiresAt;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Banner'),
          content: SizedBox(
            width: AppTheme.getDialogWidth(context),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Title *',
                        hintText: 'e.g., Summer Sale 2024',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter banner title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Banner description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL *',
                        hintText: 'https://example.com/banner.jpg',
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: linkUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Link URL (Optional)',
                        hintText: 'https://example.com/products',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priorityController,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        hintText: '0 (higher = shows first)',
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Expiration Date (Optional)'),
                      subtitle: Text(
                        expiresAt != null 
                            ? expiresAt.toString().split(' ')[0]
                            : 'No expiration',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => expiresAt = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final banner = BannerEntity(
                    id: '',
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    imageUrl: imageUrlController.text.trim(),
                    linkUrl: linkUrlController.text.isNotEmpty 
                        ? linkUrlController.text.trim() 
                        : null,
                    priority: int.tryParse(priorityController.text.trim()) ?? 0,
                    isActive: true,
                    createdAt: DateTime.now(),
                    expiresAt: expiresAt,
                  );
                  this.context.read<BannersCubit>().createBanner(banner);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Banner'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBannerDialog(BannerEntity banner) {
    final titleController = TextEditingController(text: banner.title);
    final descController = TextEditingController(text: banner.description);
    final imageUrlController = TextEditingController(text: banner.imageUrl);
    final linkUrlController = TextEditingController(text: banner.linkUrl ?? '');
    final priorityController = TextEditingController(text: banner.priority.toString());
    final formKey = GlobalKey<FormState>();
    DateTime? expiresAt = banner.expiresAt;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Banner'),
          content: SizedBox(
            width: AppTheme.getDialogWidth(context),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Title *',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter banner title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL *',
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: linkUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Link URL (Optional)',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priorityController,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Expiration Date'),
                      subtitle: Text(
                        expiresAt != null 
                            ? expiresAt.toString().split(' ')[0]
                            : 'No expiration',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (expiresAt != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => expiresAt = null),
                            ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => expiresAt = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedBanner = banner.copyWith(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    imageUrl: imageUrlController.text.trim(),
                    linkUrl: linkUrlController.text.isNotEmpty 
                        ? linkUrlController.text.trim() 
                        : null,
                    priority: int.tryParse(priorityController.text.trim()) ?? 0,
                    expiresAt: expiresAt,
                  );
                  this.context.read<BannersCubit>().updateBanner(updatedBanner);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
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

