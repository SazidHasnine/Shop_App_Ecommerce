import 'package:flutter/cupertino.dart';

enum PaymentMethod {
  cashOnDelivery(
    value: 'cash_on_delivery',
    title: 'Cash on Delivery',
    subtitle: 'Pay with cash upon package receipt',
    icon: CupertinoIcons.money_dollar_circle,
  ),
  amarpay(
    value: 'amarpay',
    title: 'AmarPay',
    subtitle: 'Pay with Amarpay (Sandbox)',
    icon: CupertinoIcons.creditcard,
  ),
  cardDemo(
    value: 'card_demo',
    title: 'Credit / Debit Card (Demo)',
    subtitle: 'Simulated card transaction',
    icon: CupertinoIcons.creditcard,
  ),
  eviraPay(
    value: 'evira_pay',
    title: 'Evira Pay (Demo Wallet)',
    subtitle: 'Instant checkout with 1-click',
    icon: CupertinoIcons.sparkles,
  );


  final String value;
  final String title;
  final String subtitle;
  final IconData icon;

  const PaymentMethod({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static PaymentMethod fromString(String? value) {
    if(value == null) return PaymentMethod.cashOnDelivery;
    final normalized = value.trim().toLowerCase();
    for (final method in PaymentMethod.values) {
      if(method.value.toLowerCase() == normalized) {
        return method;
      }
    }
    if(normalized == 'aamarpay') {
      return PaymentMethod.amarpay;
    }

    return PaymentMethod.cashOnDelivery;
  }
}