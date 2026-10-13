import 'package:go_router/go_router.dart';

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

  static String productionDetailRoute(int id) => '/product/$id';
  static String orderSuccessRoute(String orderId) => '/orderSuccess/$orderId';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) =>
      ),
    ],
  );
}