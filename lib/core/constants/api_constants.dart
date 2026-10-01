class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Endpoints
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static const String productCategoryPrefix = '/products/category';
  static const String productSearch = '/products/search';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String cachedProductsKey = 'cached_products_list';
  static const String cachedCartKey = 'cached_cart_items';
  static const String favoriteProductIdsKey = 'favorite_product_ids';
}