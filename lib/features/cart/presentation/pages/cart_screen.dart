import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _handleProceedCheckout(BuildContext context) {
    if(context.read<CartProvider>().items.isEmpty) {
      ScaffoldMessenger.of(
          context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
