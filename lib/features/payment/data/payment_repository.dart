import 'package:dio/dio.dart' show Options;
import 'package:shop_app_ecommerce/core/constants/payment_constants.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';

abstract class PaymentRepository {
  Future<String> initialPayment({
    required String transactionId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String customerCity,
    String? description,
  });
}

class AmarPayRepositoryImpl implements PaymentRepository {
  final DioClient dioClient;

  AmarPayRepositoryImpl({required this.dioClient});

  @override
  Future<String> initialPayment({
    required String transactionId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String customerCity,
    String? description,
    }) async {
    final payload = {
      'store_id': PaymentConstants.storeId,
      'signature_key': PaymentConstants.signatureKey,
      'cus_name': customerName.trim(),
      'cus_email': customerEmail.trim(),
      'cus_phone': customerPhone.trim(),
      'cus_add1': customerAddress.trim(),
      'cus_city': customerCity.trim(),
      'cus_country': 'Bangladesh',
      'amount': amount.toStringAsFixed(2),
      'currency': PaymentConstants.defaultCurrency,
      'tran_id': transactionId,
      'desc': description ?? 'Payment for order',
      'success_url': PaymentConstants.successUrl,
      'fail_url': PaymentConstants.failUrl,
      'cancel_url': PaymentConstants.cancelUrl,
      'type': 'json',
    };
    try {
      final response = await dioClient.post(
          PaymentConstants.initiateEndpoint,
          data: payload,
          options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if(response.data is Map && response.data['result'] == true) {
        final paymentUrl = response.data['payment_url'] as String? ;
        if(paymentUrl != null && paymentUrl.isNotEmpty) {
          return paymentUrl;
        }
      }

      throw Exception('Failed to initiate amarpay session: ${response.data}');
     } catch(e) {
      throw Exception('Gateway connection failed: ${e.toString()}');
    }
  }
}