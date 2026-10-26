import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:shop_app_ecommerce/core/constants/app_colors.dart';
import 'package:shop_app_ecommerce/core/router/app_router.dart';
import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';

class SigninPage extends StatefulWidget {
  final String? redirect;
  const SigninPage({super.key, this.redirect});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameContoller = TextEditingController();
  final _passwordContoller = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  // Preset demo accounts for DummyJSON
  static const List<Map<String, String>> _demoAccounts = [
    {
      'name': 'Emily Johnson',
      'username': 'emilys',
      'password': 'emilyspass',
      'role': 'Admin',
    },
    {
      'name': 'Michael Williams',
      'username': 'michaelw',
      'password': 'michaelwpass',
      'role': 'Customer',
    },
  ];

  @override
  void dispose() {
    _userNameContoller.dispose();
    _passwordContoller.dispose();
    super.dispose();
  }

  void _fillCredentials(String userName, String password) {
    setState(() {
      _userNameContoller.text = userName;
      _passwordContoller.text = password;
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();

    if(!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    final success = await authProvider.login(
      username: _userNameContoller.text.trim(),
      password: _passwordContoller.text.trim(),
    );

    if(!mounted) return;

    if(success) {
      // Sync logged in user's ID with CartProvider
      if(authProvider.user != null) {
        cartProvider.userId = authProvider.user!.id;
        cartProvider.syncWithCloud();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${authProvider.user?.firstName ?? 'User'}!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if(widget.redirect != null && widget.redirect!.isNotEmpty) {
        context.go(widget.redirect!);
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRouter.homePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          onPressed: () {
            if(context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.homePath);
            }
          },
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            CupertinoIcons.bag_fill,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Center(
                      child: Text(
                        'Welcome to Shop-Ops',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6,),
                    Center(
                      child: Text(
                        'Sign in to sync your cart, orders, and favorites',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28,),

                    // Quick Demo Accounts Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.sparkles,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 6,),
                              Expanded(
                                child: Text(
                                  'Quick Demo Accounts (Tap to auto-fill)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _demoAccounts.map((account) {
                              final isSelected =
                                  _userNameContoller.text == account['username'];
                              return InkWell(
                                onTap: () => _fillCredentials(
                                  account['username']!,
                                  account['password']!,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                        ? AppColors.backgroundDark
                                        : AppColors.backgroundLight),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.person_crop_circle_fill,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(width: 6,),
                                      Text(
                                        '${account['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight),
                                        ),
                                      ),
                                      const SizedBox(width: 4,),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.2)
                                              : AppColors.primaryLight.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          account['role']!,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),

                    // Error Message Banner
                    if(authProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.error,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: authProvider.clearError,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16,),
                    ],

                    // Username Field
                    Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6,),
                    TextFormField(
                      controller: _userNameContoller,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Enter username (e.g. emilys)',
                        prefixIcon: const Icon(
                          CupertinoIcons.person,
                          size: 20,
                          color: AppColors.textSecondaryLight,
                        ),
                        suffixIcon: _userNameContoller.text.isNotEmpty
                            ? IconButton(
                            onPressed: () {
                              setState(() {
                                _userNameContoller.clear();
                              });
                              authProvider.clearError();
                            },
                            icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18,),
                            )
                            : null,
                      ),
                      onChanged: (_) {
                        setState(() {
                          if(authProvider.errorMessage != null) {
                            authProvider.clearError();
                          }
                        });
                      },
                      validator: (value) {
                        if(value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18,),

                    // Password Field
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6,),
                    TextFormField(
                      controller: _passwordContoller,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSignIn(),
                      decoration: InputDecoration(
                        hintText: 'Enter password (e.g. emilyspass)',
                        prefixIcon: const Icon(
                          CupertinoIcons.lock,
                          size: 20,
                          color: AppColors.textSecondaryLight,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            size: 20,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if(authProvider.errorMessage != null) {
                          authProvider.clearError();
                        }
                      },
                      validator: (value) {
                        if(value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12,),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8,),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('DummyJSON Credentials'),
                                content: const Text(
                                  'This app authenticates using DummyJSON mock API. Use one of the demo accounts listed above (e.g., emilys / emilyspass).',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Got it'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24,),

                    // Submit button
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8,),
                              Icon(CupertinoIcons.arrow_right, size: 18,),
                            ],
                          ),
                    ),

                    // Guest / Continue browsing button
                    OutlinedButton(
                      onPressed: () {
                        if(context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.homePath);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textSecondaryLight,
                        ),
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
