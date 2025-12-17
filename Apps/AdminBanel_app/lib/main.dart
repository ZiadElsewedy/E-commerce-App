import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/app_theme.dart';
import 'firebase_options.dart';
import 'Admin/admin_page.dart';
import 'Features/Products/presentation/cubit/products_cubit.dart';
import 'Features/Products/data/firebase_product_repository.dart';
import 'Features/Banners/presentation/cubit/banners_cubit.dart';
import 'Features/Banners/data/firebase_banner_repository.dart';
import 'Features/Promos/presentation/cubit/promos_cubit.dart';
import 'Features/Promos/data/firebase_promo_repository.dart';
import 'Features/Coupons/presentation/cubit/coupons_cubit.dart';
import 'Features/Coupons/data/firebase_coupon_repository.dart';
import 'Features/Categories/presentation/cubit/categories_cubit.dart';
import 'Features/Categories/data/firebase_category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Products Cubit
        BlocProvider(
          create: (context) => ProductsCubit(
            productRepository: FirebaseProductRepository(),
          ),
        ),
        // Banners Cubit
        BlocProvider(
          create: (context) => BannersCubit(
            bannerRepository: FirebaseBannerRepository(),
          ),
        ),
        // Promos Cubit
        BlocProvider(
          create: (context) => PromosCubit(
            promoRepository: FirebasePromoRepository(),
          ),
        ),
        // Coupons Cubit
        BlocProvider(
          create: (context) => CouponsCubit(
            couponRepository: FirebaseCouponRepository(),
          ),
        ),
        // Categories Cubit
        BlocProvider(
          create: (context) => CategoriesCubit(
            categoryRepository: FirebaseCategoryRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Panel',
        theme: AppTheme.lightTheme,
        home: const AdminPage(),
      ),
    );
  }
}
