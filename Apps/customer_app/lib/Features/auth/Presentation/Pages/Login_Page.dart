import 'package:ecommerceapp/Features/auth/Presentation/cubits/authCubit.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authStates.dart';
import 'package:ecommerceapp/Features/Home/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/textfield.dart';
import '../widgets/validation.dart';
import '../widgets/custom_button.dart';
import 'Register_Page.dart';
import 'ForgetPassPage.dart';
import 'GoogleSignIn.dart';
import 'EmailVerficationPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  late final AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> Login() async {
   String Email = _emailController.text.trim();
   String Password = _passwordController.text.trim();
   if (Email.isEmpty || Password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
    return;
   }
   final authCubit = context.read<AuthCubit>();
   await authCubit.login(email: Email, password: Password);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    final authCubit = context.read<AuthCubit>();
    await authCubit.signInWithGoogle();
    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (state is EmailVerificationPending) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_open,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 50),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: FormValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      textInputAction: TextInputAction.done,
                      validator: FormValidators.validatePassword,
                      obscureText: _obscurePassword,
                      showPasswordToggle: true,
                      onTogglePasswordVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onFieldSubmitted: (_) => Login(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'LOGIN',
                      onPressed: Login,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    
                    // Divider with "OR"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Google Sign-In Button
                    GoogleSignInButton(
                      onPressed: _signInWithGoogle,
                      isLoading: _isGoogleLoading,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

