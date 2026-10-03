import 'package:shop_app_ecommerce/features/product/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? searchQuery});

}