import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app_ecommerce/features/auth/presentation/pages/profile_page.dart';
import 'package:shop_app_ecommerce/features/auth/presentation/pages/signin_page.dart';
import 'package:shop_app_ecommerce/features/cart/presentation/pages/cart_screen.dart';
import 'package:shop_app_ecommerce/features/order/presentation/pages/checkout_page.dart';
import 'package:shop_app_ecommerce/features/order/presentation/pages/order_success_page.dart';
import 'package:shop_app_ecommerce/features/order/presentation/pages/orders_page.dart';
import 'package:shop_app_ecommerce/features/payment/presentation/pages/payment_page.dart';
import 'package:shop_app_ecommerce/features/product/presentation/pages/product_details.dart';
import 'package:shop_app_ecommerce/features/product/presentation/pages/product_list.dart';

class AppRouter {
  AppRouter._();

  static const String homePath = '/';
  static const String _productDetailPath = '/product/:id';
  static const String cartPath = '/cart';
  static const String signinPath = '/signin';
  static const String profilePath = '/profile';
  static const String checkoutPath = '/checkout';
  static const String _orderSuccessPath = '/orderSuccess/:orderId';
  static const String ordersPath = '/orders';
  static const String paymentPath = '/payment';

  static String productionDetailRoute(int id) => '/product/$id';
  static String orderSuccessRoute(String orderId) => '/orderSuccess/$orderId';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) => ProductListScreen(),
      ),
      GoRoute(
        path: _productDetailPath,
        name: 'productDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailsScreen(productId: int.tryParse(id) ?? 0);
        },
      ),
      GoRoute(
        path: cartPath,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: signinPath,
        name: 'signin',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return SigninPage(redirect: redirect,);
        },
      ),
      GoRoute(
        path: profilePath,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: checkoutPath,
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: _orderSuccessPath,
        name: 'orderSuccess',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderSuccessPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: ordersPath,
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: paymentPath,
        name: 'payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic> ?? {};
          final paymentUrl = extra['paymentUrl'] as String? ?? '';
          final transactionId = extra['transactionId'] as String? ?? '';
          return PaymentPage(
            paymentUrl: paymentUrl,
            transactionId: transactionId,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found'),),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16,),
              const Text(
                '404 - Page not found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8,),
              Text(
                'The route ${state.uri.path} could not be found',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24,),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Back to Catalog'),
                onPressed: () => context.go(homePath),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}