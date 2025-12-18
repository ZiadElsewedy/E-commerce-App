import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/promos_cubit.dart';
import '../cubit/promos_states.dart';
import '../cubit/banners_cubit.dart';
import '../cubit/banners_states.dart';
import '../../domain/entities/promo_entity.dart';
import '../../domain/entities/banner_entity.dart';
import '../widgets/promo_card_widget.dart';
import '../widgets/banner_card_widget.dart';
import '../widgets/promo_form_sheet.dart';
import '../widgets/banner_form_sheet.dart';
import '../../../Categories/presentation/cubit/categories_cubit.dart';
import '../../../Categories/data/firebase_category_repository.dart';

/// Promos & Banners Management Page
/// Modern tabbed interface for managing promotional offers and banners
class PromosBannersManagementPage extends StatefulWidget {
  const PromosBannersManagementPage({super.key});

  @override
  State<PromosBannersManagementPage> createState() => _PromosBannersManagementPageState();
}

class _PromosBannersManagementPageState extends State<PromosBannersManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PromosCubit>().fetchAllPromos();
    context.read<BannersCubit>().fetchAllBanners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPromosTab(),
                _buildBannersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddNew,
        backgroundColor: _tabController.index == 0 ? const Color(0xFF10B981) : const Color(0xFF2563EB),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'ADD PROMO' : 'ADD BANNER',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promos & Banners',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage promotional offers and advertising banners',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.filter_list_outlined,
          onPressed: _showFilterSheet,
          tooltip: 'Filter',
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.refresh,
          onPressed: _refreshCurrentTab,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 20, color: const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              _tabController.index == 0 ? const Color(0xFF10B981) : const Color(0xFF2563EB),
              _tabController.index == 0 ? const Color(0xFF059669) : const Color(0xFF1D4ED8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (_tabController.index == 0 ? Colors.green : Colors.blue).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.local_offer_outlined, size: 20),
            text: 'Promos',
            height: 50,
          ),
          Tab(
            icon: Icon(Icons.image_outlined, size: 20),
            text: 'Banners',
            height: 50,
          ),
        ],
        onTap: (index) => setState(() {}),
      ),
    );
  }

  Widget _buildPromosTab() {
    return BlocConsumer<PromosCubit, PromosState>(
      listener: _handlePromosStateChanges,
      builder: (context, state) {
        if (state is PromosLoading || state is PromosInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PromosEmpty) {
          return _buildEmptyState(
            icon: Icons.local_offer_outlined,
            title: 'No Promos Found',
            subtitle: 'Create your first promotional offer',
            buttonText: 'Create Promo',
            onPressed: () => _showAddPromoForm(),
          );
        } else if (state is PromosLoaded) {
          return _buildPromosList(state.promos);
        } else if (state is PromosError) {
          return _buildErrorState(state.errorMessage, isPromo: true);
        }
        return _buildEmptyState(
          icon: Icons.local_offer_outlined,
          title: 'No Promos',
          subtitle: 'Get started by creating a promo',
          buttonText: 'Create Promo',
          onPressed: () => _showAddPromoForm(),
        );
      },
    );
  }

  Widget _buildBannersTab() {
    return BlocConsumer<BannersCubit, BannersState>(
      listener: _handleBannersStateChanges,
      builder: (context, state) {
        if (state is BannersLoading || state is BannersInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BannersEmpty) {
          return _buildEmptyState(
            icon: Icons.image_outlined,
            title: 'No Banners Found',
            subtitle: 'Create your first promotional banner',
            buttonText: 'Create Banner',
            onPressed: () => _showAddBannerForm(),
          );
        } else if (state is BannersLoaded) {
          return _buildBannersList(state.banners);
        } else if (state is BannersError) {
          return _buildErrorState(state.errorMessage, isPromo: false);
        }
        return _buildEmptyState(
          icon: Icons.image_outlined,
          title: 'No Banners',
          subtitle: 'Get started by creating a banner',
          buttonText: 'Create Banner',
          onPressed: () => _showAddBannerForm(),
        );
      },
    );
  }

  Widget _buildPromosList(List<PromoEntity> promos) {
    return RefreshIndicator(
      onRefresh: () => context.read<PromosCubit>().fetchAllPromos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return PromoCardWidget(
            promo: promo,
            onEdit: () => _showEditPromoForm(promo),
            onDelete: () => _showDeletePromoConfirmation(promo),
            onToggleStatus: () => context.read<PromosCubit>().updatePromo(
                  promo.copyWith(isActive: !promo.isActive),
                ),
          );
        },
      ),
    );
  }

  Widget _buildBannersList(List<BannerEntity> banners) {
    return RefreshIndicator(
      onRefresh: () => context.read<BannersCubit>().fetchAllBanners(),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return BannerCardWidget(
            banner: banner,
            onEdit: () => _showEditBannerForm(banner),
            onDelete: () => _showDeleteBannerConfirmation(banner),
            onToggleStatus: () => context.read<BannersCubit>().updateBanner(
                  banner.copyWith(isActive: !banner.isActive),
                ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: _tabController.index == 0 ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, {required bool isPromo}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _refreshCurrentTab,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _tabController.index == 0 ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePromosStateChanges(BuildContext context, PromosState state) {
    if (state is PromoCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PromoUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PromoDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PromosError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleBannersStateChanges(BuildContext context, BannersState state) {
    if (state is BannerCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is BannerUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is BannerDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is BannersError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleAddNew() {
    if (_tabController.index == 0) {
      _showAddPromoForm();
    } else {
      _showAddBannerForm();
    }
  }

  void _showAddPromoForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromoFormSheet(
        onSubmit: (promo) {
          this.context.read<PromosCubit>().createPromo(promo);
        },
      ),
    );
  }

  void _showEditPromoForm(PromoEntity promo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromoFormSheet(
        promo: promo,
        onSubmit: (updatedPromo) {
          this.context.read<PromosCubit>().updatePromo(updatedPromo);
        },
      ),
    );
  }

  void _showAddBannerForm() {
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

  void _showEditBannerForm(BannerEntity banner) {
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

  void _showDeletePromoConfirmation(PromoEntity promo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Promo'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${promo.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PromosCubit>().deletePromo(promo.id);
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

  void _showDeleteBannerConfirmation(BannerEntity banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Banner'),
          ],
        ),
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(_tabController.index == 0 ? 'All Promos' : 'All Banners'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter('all');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(_tabController.index == 0 ? 'Active Promos' : 'Active Banners'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter('active');
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: Text(_tabController.index == 0 ? 'Current Promos' : 'Current Banners'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter('current');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter(String filter) {
    if (_tabController.index == 0) {
      switch (filter) {
        case 'active':
          context.read<PromosCubit>().fetchActivePromos();
          break;
        case 'current':
          context.read<PromosCubit>().fetchCurrentPromos();
          break;
        default:
          context.read<PromosCubit>().fetchAllPromos();
      }
    } else {
      switch (filter) {
        case 'active':
          context.read<BannersCubit>().fetchActiveBanners();
          break;
        case 'current':
          context.read<BannersCubit>().fetchCurrentBanners();
          break;
        default:
          context.read<BannersCubit>().fetchAllBanners();
      }
    }
  }

  void _refreshCurrentTab() {
    if (_tabController.index == 0) {
      context.read<PromosCubit>().fetchAllPromos();
    } else {
      context.read<BannersCubit>().fetchAllBanners();
    }
  }
}

