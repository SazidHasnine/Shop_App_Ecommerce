import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:shop_app_ecommerce/features/cart/models/sync_status.dart';
import 'package:shop_app_ecommerce/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:shop_app_ecommerce/features/cart/presentation/widgets/cart_sync_indicator.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _handleProceedCheckout(BuildContext context) {
    if(context.read<CartProvider>().items.isEmpty) {
      ScaffoldMessenger.of(
          context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if(!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to proceed to checkout'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Sign In',
            onPressed: () => context.push(AppRouter.signinPath),
          ),
        ),
      );
      return;
    }

    context.push(AppRouter.checkoutPath);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          const CartSyncIndicator(),
          if(cartProvider.items.isEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(CupertinoIcons.trash),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartProvider.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.cart,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8,),
                  const Text(
                    'Looks like you haven\'t added any items to your cart yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey,),
                  ),
                  const SizedBox(height: 24,),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            ),
          )
          : Column(
            children: [
              if(cartProvider.syncStatus == SyncStatus.offline)
                Container(
                  color: Colors.amber.shade800.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.wifi_slash,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8,),
                      const Expanded(
                        child: Text(
                          'Working offline. Changes will sync when online.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () => cartProvider.syncNow(),
                        child: const Text(
                          'Sync',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cartProvider.syncNow(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12,),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Dismissible(
                              key: ValueKey(item.product.id),
                              direction: DismissDirection.endToStart,
                              background: const SizedBox.shrink(),
                              onDismissed: (_) {
                                cartProvider.removeItem(item.product.id);
                              },
                              child: CartItemTile(item: item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      bottomNavigationBar: cartProvider.items.isEmpty 
          ? null 
          : Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark 
                      ? AppColors.borderDark 
                      : AppColors.borderLight,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),  
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text('\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 6,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Tax (8%)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text('\$${cartProvider.tax.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${cartProvider.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16,),
                  ElevatedButton.icon(
                    onPressed: () => _handleProceedCheckout(context),
                    label: const Text('Proceed to Checkout'),  
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
