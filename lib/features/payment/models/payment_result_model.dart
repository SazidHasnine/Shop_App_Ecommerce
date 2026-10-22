enum PaymentStatus { success, failed, cancelled }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;

  PaymentResult({required this.status, this.transactionId, this.errorMessage});

  factory PaymentResult.success({String? transactionId}) => PaymentResult(
    status: PaymentStatus.success,
    transactionId: transactionId,
  );

  factory PaymentResult.failed({String? transactionId, String? message}) => PaymentResult(
    status: PaymentStatus.failed,
    transactionId: transactionId,
    errorMessage: message,
  );

  factory PaymentResult.cancelled({String? transactionId}) => PaymentResult(
    status: PaymentStatus.cancelled,
    transactionId: transactionId,
  );
}