import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authCubit.dart';
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authStates.dart';
import 'package:ecommerceapp/Features/auth/Presentation/widgets/custom_button.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  bool _isCheckingVerification = false;
  bool _canResendEmail = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    // Auto-check email verification every 10 seconds
    _startAutoCheck();
  }

  void _startAutoCheck() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isCheckingVerification && mounted) {
        setState(() {
          _isCheckingVerification = true;
        });
        
        final authCubit = context.read<AuthCubit>();
        final isVerified = await authCubit.checkEmailVerification();
        
        if (mounted) {
          setState(() {
            _isCheckingVerification = false;
          });
        }
        
        // If verified, the cubit will automatically navigate to home
        if (isVerified) {
          _timer?.cancel();
        }
      }
    });
  }

  void _startResendCooldown() {
    setState(() {
      _canResendEmail = false;
      _resendCooldown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });

        if (_resendCooldown <= 0) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _canResendEmail = true;
            });
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    final authCubit = context.read<AuthCubit>();
    final theme = Theme.of(context);
    
    try {
      await authCubit.resendVerificationEmail();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Verification email sent! Check your inbox.'),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _startResendCooldown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _checkVerificationManually() async {
    setState(() {
      _isCheckingVerification = true;
    });

    final authCubit = context.read<AuthCubit>();
    final theme = Theme.of(context);
    final isVerified = await authCubit.checkEmailVerification();

    if (mounted) {
      setState(() {
        _isCheckingVerification = false;
      });

      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠ Email not verified yet. Check your inbox.'),
            backgroundColor: theme.colorScheme.secondary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _logout() {
    _timer?.cancel();
    context.read<AuthCubit>().logout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        String userEmail = '';
        
        if (state is EmailVerificationPending) {
          userEmail = state.user.email;
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: _logout,
                child: Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Title
                    Text(
                      'VERIFY YOUR EMAIL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Description
                    Text(
                      'We sent a verification link to',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // User Email - Always visible
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Instructions Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Click the verification link in your email to activate your account',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Check Verification Button
                    CustomButton(
                      text: _isCheckingVerification ? 'CHECKING...' : 'I VERIFIED MY EMAIL',
                      onPressed: _checkVerificationManually,
                      isLoading: _isCheckingVerification,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Resend Email Button
                    CustomButton(
                      text: _canResendEmail
                          ? 'RESEND EMAIL'
                          : 'WAIT ${_resendCooldown}s',
                      onPressed: _canResendEmail ? _resendVerificationEmail : null,
                      backgroundColor: Colors.white,
                      textColor: theme.colorScheme.primary,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Status indicator
                    AnimatedOpacity(
                      opacity: _isCheckingVerification ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Checking...',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Help text
                    Text(
                      'Check your spam folder if you don\'t see the email',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

