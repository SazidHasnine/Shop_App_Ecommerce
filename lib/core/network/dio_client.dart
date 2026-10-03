import 'package:dio/dio.dart';
import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';

class DioClient {
  late final Dio _dio;
  final PreferenceService preferenceService;

  DioClient({required this.preferenceService, Dio? dio}){
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            sendTimeout: ApiConstants.sendTimeout,
            headers: {
              'Content-Type' : 'application/json',
              'Accept' : 'application/json',
            },
          )
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler){
          final token = preferenceService.getAuthToken();
          if(token != null && token.isNotEmpty){
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onError: (DioException error, handler) {
          final mappedError = _mapDioException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: mappedError,
              type: error.type,
              response: error.response,
              message: mappedError.message,

            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
      String path, {
      Map<String, dynamic>? queryParameters,
      Options? options,
      }) {
    try {
      return _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch(e) {
      throw _mapDioException(e);
    } catch(e) {
      throw ApiException(e.toString());
    }
  }

  ApiException _mapDioException(DioException error){
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if(statusCode == 401 || statusCode == 403){
          return const UnauthorizedException();
        }else if(statusCode == 404){
          return const NotFoundException();
        }
        final message = (error.response?.data is Map<String, dynamic>)
            ? (error.response?.data['message']?.toString() ??
                'Server error ($statusCode)')
            : 'Server error ($statusCode)';
        return ServerException(message, statusCode);
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
      case DioExceptionType.badCertificate:
        return ApiException('Invalid SSL certificate');
      case DioExceptionType.unknown:
      default:
        return ApiException(error.message ?? 'Unexpected error occurred');

    }
  }
}
