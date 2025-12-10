import 'package:ecommerceapp/Features/Home/HomeScreen.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authCubit.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authStates.dart' show AuthStates, Authenticated, Unauthenticated, EmailVerificationPending, AuthError, AuthLoading, AuthInitial;
import 'package:ecommerceapp/Features/auth/data/Firebase_auth_repo.dart' show FirebaseAuthRepository;
import 'package:ecommerceapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Features/auth/Presentation/Pages/Login_Page.dart';
import 'Features/auth/Presentation/Pages/EmailVerficationPage.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  
   MyApp({super.key});
 final  authRepository = FirebaseAuthRepository();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authRepository: authRepository) ..checkAuthStatus()),
      ],
      child: MaterialApp(   
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: AppTheme.lightTheme,
      home: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          // Listener is for side effects like showing snackbars
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
          // Builder determines which page to show based on state
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is Authenticated) {
            return const HomeScreen();
          } else if (state is EmailVerificationPending) {
            return const EmailVerificationPage();
          } else if (state is Unauthenticated || state is AuthError) {
            return const LoginPage();
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      )
    ));
  }
}

