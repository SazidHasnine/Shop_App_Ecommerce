import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;

  const PaymentPage({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
