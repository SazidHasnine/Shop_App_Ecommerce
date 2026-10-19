import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/features/cart/models/cart_item.dart';
import 'package:shop_app_ecommerce/features/cart/models/cloud_cart_dto.dart';

abstract class CartRemoteDatasource {
  Future<CloudCartDto?> fetchUserCart(int userId);

  Future<CloudCartDto> createCloudCart({
    required int userId,
    required List<CartItem> items,
  });

  Future<CloudCartDto> updateCloudCart({
    required int cartId,
    required List<CartItem> items,
  });

  Future<void> deleteCloudCart(int id);
}

class CartRemoteDatasourceImpl implements CartRemoteDatasource {
  final DioClient dioClient;

  CartRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<CloudCartDto?> fetchUserCart(int userId) async {
    final response = await dioClient.get(ApiConstants.userCart(userId));
    if(response.data is Map<String, dynamic>) {
      final dtos = CloudCartDto.fromUserCartsJson(
        response.data as Map<String, dynamic>
      );
      return dtos.isNotEmpty ? dtos.first : null;
    }
    return null;
  }

  @override
  Future<CloudCartDto> createCloudCart({
    required int userId,
    required List<CartItem> items,
  }) async {
    final payload = {
      'userId': userId,
      'products': items
          .map((i) => {'id': i.product.id, 'quantity': i.quantity})
          .toList(),
    };
    final response = await  dioClient.post(ApiConstants.addCart, data: payload);
    return CloudCartDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CloudCartDto> updateCloudCart({
    required int cartId,
    required List<CartItem> items,
  }) async {
    final payload = {
      'merge': true,
      'products': items
          .map((i) => {'id': i.product.id, 'quantity': i.quantity})
          .toList()
    };
    final response = await dioClient.put(
      ApiConstants.cartById(cartId),
      data: payload,
    );
    return CloudCartDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCloudCart(int cartId) async {
    await dioClient.delete(ApiConstants.cartById(cartId));
  }
}