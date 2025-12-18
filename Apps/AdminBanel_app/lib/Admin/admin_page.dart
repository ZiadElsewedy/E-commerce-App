import 'package:ecommerceapp/Admin/presentation/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Features/Products/presentation/pages/products_management_page.dart';
import '../Features/Banners/presentation/pages/banners_management_page.dart';
import '../Features/Promos/presentation/pages/promos_management_page.dart';
import '../Features/Coupons/presentation/pages/coupons_management_page.dart';
import '../Features/Categories/presentation/pages/categories_management_page.dart';
import '../Features/Promos/presentation/cubit/banners_cubit.dart';
import '../Features/Promos/data/firebase_banner_repository.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Admin',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Statistics Title
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    icon: Icons.people_outline,
                    title: 'Users',
                    value: '0',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStatCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Products',
                    value: '0',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Orders',
                    value: '0',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildStatCard(
                    icon: Icons.attach_money,
                    title: 'Revenue',
                    value: '\$0',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Quick Actions Title
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Action Buttons
            buildActionButton(
              icon: Icons.inventory_2_outlined,
              title: 'Manage Products',
              subtitle: 'View and edit existing products',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductsManagementPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            buildActionButton(
              icon: Icons.view_carousel_outlined,
              title: 'Manage Banners',
              subtitle: 'Create and edit promotional banners',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => BannersCubit(
                        bannerRepository: FirebaseBannerRepository(),
                      ),
                      child: const BannersManagementPage(),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            buildActionButton(
              icon: Icons.local_offer_outlined,
              title: 'Manage Promos',
              subtitle: 'Set up promotional offers',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromosManagementPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            buildActionButton(
              icon: Icons.confirmation_number_outlined,
              title: 'Manage Coupons',
              subtitle: 'Create and manage discount coupons',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CouponsManagementPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            buildActionButton(
              icon: Icons.category_outlined,
              title: 'Manage Categories',
              subtitle: 'Organize products into categories',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesManagementPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
}