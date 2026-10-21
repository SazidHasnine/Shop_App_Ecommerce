import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';

abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
    int? expiresInMins,
  });

  Future<Map<String, dynamic>> getCurrentUser();

  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final DioClient dioClient;

  AuthRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
    int? expiresInMins
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.authLogin,
        data: {
          'userName': userName.trim(),
          'password': password.trim(),
          'expiresInMins': ?expiresInMins,
          //   if (expiresInMins != null) 'expiresInMins': expiresInMins,
        },
      );
      if(response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw const ApiException('Invalid response received from authentication server');
    } on ApiException {
      rethrow;
    } catch(e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await dioClient.get(ApiConstants.authMe);
      if(response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw const ApiException('Failed to retrieve user profile');
    } on ApiException {
      rethrow;
    } catch(e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiConstants.authRefresh,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': 60,
        },
      );
      if(response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw const ApiException('Invalid response received from authentication server');
    } on ApiException {
      rethrow;
    } catch(e) {
      throw ApiException(e.toString());
    }
  }
}