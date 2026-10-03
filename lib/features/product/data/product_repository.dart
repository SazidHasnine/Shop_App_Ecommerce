import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/features/product/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? searchQuery});
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;

  ProductRepositoryImpl(this.dioClient);

  @override
  Future<List<Product>> getProducts({String? category, String? searchQuery}) async {
    String url = ApiConstants.products;
    Map<String, dynamic>? queryParams;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      url = ApiConstants.productSearch;
      queryParams = {'q': searchQuery};
    } else if (category != null && category.isNotEmpty) {
      url = '${ApiConstants.productCategoryPrefix}/$category';
    }

    final response = await dioClient.get(url, queryParameters: queryParams);
    final List<dynamic> productsJson = response.data['products'] ?? [];
    return productsJson.map((json) => Product.fromMap(json)).toList();
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await dioClient.get('${ApiConstants.products}/$id');
    return Product.fromMap(response.data);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await dioClient.get(ApiConstants.productCategories);
    final List<dynamic> categoriesJson = response.data ?? [];
    return categoriesJson.map((e) => e.toString()).toList();
  }
}
