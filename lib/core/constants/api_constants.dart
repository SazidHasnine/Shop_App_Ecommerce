class ApiConstants {
  ApiConstants._();

  static String get baseUrl => 'https://dummyjson.com';
  /* {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  } */

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Endpoints
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static const String productCategoryPrefix = '/products/category';
  static const String productSearch = '/products/search';
  static const String carts = '/carts';
  static const String userCartsPrefix = '/carts/user';
  static const String addCart = '/carts/add';
  static String userCart(int userId) => '/carts/user/$userId';
  static String cartById(int cartId) => '/carts/$cartId';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String users = '/users';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'auth_user_data';
  static const String cachedProductsKey = 'cached_products_list';
  static const String cachedCartKey = 'cached_cart_items';
  static const String favoriteProductIdsKey = 'favorite_product_ids';

  static const String cloudCartIdKey = 'cloud_cart_id';
  static const String lastCartSyncKey = 'last_cart_sync';
  static const String pendingCartSyncKey = 'pending_cart_sync';
}