import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ecommerce/core/constants/app_colors.dart';
import 'package:shop_app_ecommerce/core/router/app_router.dart';
import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';
import 'package:shop_app_ecommerce/features/order/provider/order_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            if(context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.homePath);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: user == null
                ? _buildGuestView(context, isDark, surfaceColor, borderColor)
                : _buildAuthenticatedView(context, user, cartProvider, isDark, surfaceColor, borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestView(
      BuildContext context,
      bool isDark,
      Color surfaceColor,
      Color borderColor,
      ) {
    return Column(
      children: [
        const SizedBox(height: 32,),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.person_crop_circle,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20,),
        Text(
          'Browsing as Guest',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8,),
        Text(
          'Sign in to synchronize your cart, view order history, and access personalized discounts.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 32,),
        ElevatedButton(
          onPressed: () => context.push(AppRouter.signinPath),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Sign In to Your Account'),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedView(
      BuildContext context,
      dynamic user,
      CartProvider cartProvider,
      bool isDark,
      Color surfaceColor,
      Color borderColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User Profile card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.textPrimaryLight,
                backgroundImage: user.image.isNotEmpty
                    ? NetworkImage(user.image)
                    : null,
                child: user.image.isEmpty
                    ? Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                    : null,
              ),
              const SizedBox(width: 16,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6,),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.role ?? 'User',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2,),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),

        // Account Details Section
        Text(
          'Account Overview',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildListTile(
                icon: CupertinoIcons.person_badge_plus,
                title: 'User ID',
                subtitle: '#${user.id}',
                isDark: isDark,
              ),
              const Divider(height: 1,),
              _buildListTile(
                icon: CupertinoIcons.cart,
                title: 'Cart Items',
                subtitle: '${cartProvider.itemCount} item(s)',
                trailing: const Icon(CupertinoIcons.forward, size: 16,),
                isDark: isDark,
                onTap: () => context.push(AppRouter.cartPath),
              ),
              const Divider(height: 1,),
              _buildListTile(
                icon: CupertinoIcons.cloud_upload,
                title: 'Cart Sync Status',
                subtitle: cartProvider.syncStatus.name.toUpperCase(),
                isDark: isDark,
              ),
              const Divider(height: 1,),
              _buildListTile(
                icon: CupertinoIcons.list_bullet,
                title: 'Order History',
                subtitle: context.read<OrderProvider>().orders.isNotEmpty
                    ? '${context.read<OrderProvider>().orders.length} order(s)'
                    : 'No order history yet.',
                isDark: isDark,
                onTap: () => context.push(AppRouter.ordersPath),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32,),

        //logout button
        ElevatedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout, size: 18,),
          label: const Text('Log Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx) ,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              context.read<OrderProvider>().clearOrderState();
              await context.read<AuthProvider>().logout();
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
                context.go(AppRouter.homePath);
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
