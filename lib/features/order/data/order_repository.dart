import 'package:dio/dio.dart';
import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/features/order/models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getOrders({int? userId});
  Future<OrderModel> getOrderById(String orderId);
}

class OrderRepositoryImpl implements OrderRepository{
  final DioClient dioClient;

  OrderRepositoryImpl({required this.dioClient});

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      final response = await dioClient.post(
        ApiConstants.ordersEndpoint,
        data: order.toJson(),
      );

      if(response.statusCode == 201 || response.statusCode == 200) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException('Failed to place order: ${response.statusCode}');
    } on DioException catch(e) {
      if(e.type == DioExceptionType.connectionError ||
         e.type == DioExceptionType.connectionTimeout) {
        // Offline fallback if local mock server is not running
        return order;
      }

      throw NetworkException(e.response?.data['message'] ?? e.message);
    } catch(e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getOrders({int? userId})  async {
    try {
      final response = await dioClient.get(
        ApiConstants.ordersEndpoint,
        queryParameters: userId != null ? {'userId': userId} : null,
      );

      if(response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.ordersEndpoint}/$orderId',
      );
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch(e) {
      throw NetworkException(e.response?.data['message'] ?? e.message);
    }
  }
}