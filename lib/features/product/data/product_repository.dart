import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/features/product/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? searchQuery});
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;

  ProductRepositoryImpl({required this.dioClient});

  @override
  Future<List<Product>> getProducts({
    String? category,
    String? searchQuery
  }) async {
    try {
      String endpoint = ApiConstants.products;
      Map<String, dynamic> params = {};

      if(searchQuery != null && searchQuery.trim().isNotEmpty) {
        endpoint = '${ApiConstants.products}/search';
        params['q'] = searchQuery.trim();
      } else if (category != null && category.isNotEmpty && category != 'All') {
        endpoint = '${ApiConstants.products}/category/$category';
      }

      final response = await dioClient.get(endpoint, queryParameters: params);
      final data = response.data;

      if(data is List) {
        return data
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['products'] is List) {
        final List<dynamic> rawList = data['products'];
        return rawList
            .map((item) => Product.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on ApiException {
      throw Exception('Failed to fetch products');
    } catch(_) {
      throw Exception('Failed to fetch products');
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      final response = await dioClient.get('${ApiConstants.products}/$id');
      if(response.data is Map<String, dynamic>) {
        return Product.fromMap(response.data as Map<String, dynamic>);
      }
      throw Exception('Product with ID $id not found');
    } catch(_) {
      throw Exception('Failed to fetch product with ID $id');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await dioClient.get(ApiConstants.productCategories);
      if(response.data is List) {
        return (response.data as List).map((e) {
          if(e is Map<String, dynamic> && e['name'] != null) {
            return e['name'].toString();
          }
          return e.toString();
        }).toList();
      }
      return ['All', 'beauty', 'fragrances', 'furniture', 'groceries'];
    } catch (_) {
      return ['All', 'beauty', 'fragrances', 'furniture', 'groceries'];
    }
  }
}
