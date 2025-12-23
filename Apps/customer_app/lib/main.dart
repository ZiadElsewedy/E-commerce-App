import 'package:ecommerceapp/Features/Home/HomeScreen.dart';
import 'package:ecommerceapp/Features/Home/presentation/cubit/home_cubit.dart';
import 'package:ecommerceapp/Features/Home/data/firebase_home_repository.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authCubit.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authStates.dart'
    show
        AuthStates,
        Authenticated,
        Unauthenticated,
        EmailVerificationPending,
        AuthError,
        AuthLoading,
        AuthInitial;
import 'package:ecommerceapp/Features/auth/data/Firebase_auth_repo.dart'
    show FirebaseAuthRepository;
import 'package:ecommerceapp/Features/Profile/Presentation/cubit/profile_cubit.dart';
import 'package:ecommerceapp/Features/Profile/Data/repositories/profile_repository_impl.dart';
import 'package:ecommerceapp/Features/Profile/Data/datasources/profile_remote_data_source.dart';
import 'package:ecommerceapp/Features/Cart/presentation/cubit/cart_cubit.dart';
import 'package:ecommerceapp/Features/Cart/domain/repositories/cart_repository.dart';
import 'package:ecommerceapp/Features/Cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerceapp/Features/Cart/data/datasources/cart_remote_datasource.dart';
import 'package:ecommerceapp/Features/Wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:ecommerceapp/Features/Orders/presentation/cubit/order_cubit.dart';
import 'package:ecommerceapp/Features/Orders/domain/repositories/order_repository.dart';
import 'package:ecommerceapp/Features/Orders/data/repositories/order_repository_impl.dart';
import 'package:ecommerceapp/Features/Orders/data/datasources/order_remote_datasource.dart';
import 'package:ecommerceapp/Features/Catalog/domain/repositories/catalog_repository.dart';
import 'package:ecommerceapp/Features/Catalog/data/repositories/catalog_repository_impl.dart';
import 'package:ecommerceapp/Features/Catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:ecommerceapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/app_theme.dart';
import 'Features/auth/Presentation/Pages/Login_Page.dart';
import 'Features/auth/Presentation/Pages/EmailVerficationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Initialize repositories
  // تهيئة المستودعات
  late final authRepository = FirebaseAuthRepository();
  late final homeRepository = FirebaseHomeRepository();
  late final profileRepository = ProfileRepositoryImpl(
    dataSource: ProfileRemoteDataSource(),
  );

  // Catalog repositories
  // مستودعات الكتالوج
  CatalogRepository get catalogRepository => CatalogRepositoryImpl(
        dataSource: CatalogRemoteDataSource(),
      );

  // Cart repositories
  // مستودعات السلة
  CartRepository get cartRepository => CartRepositoryImpl(
        dataSource: CartRemoteDataSource(),
      );

  // Order repositories
  // مستودعات الطلبات
  OrderRepository get orderRepository => OrderRepositoryImpl(
        dataSource: OrderRemoteDataSource(),
      );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthCubit(authRepository: authRepository)..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => HomeCubit(repository: homeRepository),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(repository: profileRepository),
        ),
        BlocProvider(
          create: (context) => CartCubit(repository: cartRepository),
        ),
        BlocProvider(
          create: (context) => WishlistCubit(),
        ),
        BlocProvider(
          create: (context) => OrderCubit(repository: orderRepository),
        ),
        // Provide CatalogRepository for dependency injection
        // توفير CatalogRepository لحقن التبعيات
        RepositoryProvider<CatalogRepository>(
          create: (context) => catalogRepository,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce App',
        theme: AppTheme.lightTheme,
        home: BlocConsumer<AuthCubit, AuthStates>(
          listener: (context, state) {
            // Handle side effects like showing snackbars
            // معالجة الآثار الجانبية مثل عرض الرسائل
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            // Determine which page to show based on state
            // تحديد الصفحة التي سيتم عرضها بناءً على الحالة
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is Authenticated) {
              return const HomeScreen();
            } else if (state is EmailVerificationPending) {
              return const EmailVerificationPage();
            } else if (state is Unauthenticated) {
              return const LoginPage();
            } else if (state is AuthError) {
              return const LoginPage();
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
