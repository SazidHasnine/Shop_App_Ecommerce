import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../provider/product_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.bag_fill,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Evira', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: authProvider.isAuthenticated
                ? Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(CupertinoIcons.person_crop_circle_fill),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            )
                : const Icon(CupertinoIcons.person_crop_circle),
            tooltip: authProvider.isAuthenticated ? 'Account' : 'Sign In',
            onPressed: () {
              if (authProvider.isAuthenticated) {
                context.push(AppRouter.profilePath);
              } else {
                context.push(AppRouter.signinPath);
              }
            },
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(CupertinoIcons.cart),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Cart',
            onPressed: () => context.push(AppRouter.cartPath),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  productProvider.search(val);
                });
              },
              decoration: InputDecoration(
                hintText: 'Search electronics, watches, fashion...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    size: 18,
                  ),
                  onPressed: () {
                    _debounce?.cancel();
                    _searchController.clear();
                    productProvider.search('');
                  },
                )
                    : null,
              ),
            ),
          ),

          // Categories Bar
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: productProvider.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = productProvider.categories[index];
                final isSelected = category == productProvider.selectedCategory;

                return ChoiceChip(
                  label: Text(
                    category[0].toUpperCase() + category.substring(1),
                  ),
                  selected: isSelected,
                  onSelected: (_) => productProvider.selectCategory(category),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Content State (Loading, Error, Empty, Grid)
          Expanded(
            child: Builder(
              builder: (context) {
                if (productProvider.isLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (productProvider.errorMessage != null &&
                    productProvider.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_circle,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            productProvider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => productProvider.fetchProducts(),
                            icon: const Icon(CupertinoIcons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.tray, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No products found.',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.fetchProducts(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return ProductCard(product: product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}