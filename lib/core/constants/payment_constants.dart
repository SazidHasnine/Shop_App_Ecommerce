class PaymentConstants {
  static const String sandboxBaseUrl = 'https://sandbox.aamarpay.com';
  static const String initiateEndpoint = '/jsonpost.php';

  // Amarpay credentials
  static const String storeId = 'aamarpaytest';
  static const String signatureKey = 'dbb74894e82415a2f7ff0ec3a97e4183'; // **
  static const String defaultCurrency = 'USD';

  static const String successUrl = 'https://example.app/payment/success';
  static const String failUrl = 'https://example.app/payment/fail';
  static const String cancelUrl = 'https://example.app/payment/cancel';
}