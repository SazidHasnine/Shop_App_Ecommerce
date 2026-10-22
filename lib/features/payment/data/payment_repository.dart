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
    required String customerCity
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
    required String customerCity}) {
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
      'tran_id': ,
      'desc': ,
      'success_url': ,
      'fail_url': ,
      'cancel_url': ,
      'type': ,

    }
  }
}