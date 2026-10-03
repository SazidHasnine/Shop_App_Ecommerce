import 'package:shop_app_ecommerce/features/product/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(String? category, String? searchQuery);
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient
}