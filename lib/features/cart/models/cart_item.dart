import 'package:flutter/foundation.dart';
import 'package:shop_app_ecommerce/features/product/models/product.dart';

/// An immutable representation of an item in the user's shopping cart.
///
/// ### Why Immutability Matters in Cart Management:
/// 1. **Zero Side-Effects:** Once a [CartItem] is instantiated, its [product]
///    and [quantity] cannot be mutated in-place by external widgets or services.
/// 2. **Predictable State Updates:** Changes in quantity must be dispatched
///    through [copyWith], yielding a distinct new instance:
///    ```dart
///    final updatedItem = item.copyWith(quantity: item.quantity + 1);
///    ```
///    This allows state management solutions (such as `Provider` or `ChangeNotifier`)
///    to detect changes via reference comparisons and trigger UI rebuilds accurately.
/// 3. **Thread and Asynchronous Safety:** An immutable cart item can be safely passed
///    across asynchronous operations (e.g. persisting to SharedPreferences or syncing
///    with a backend API) without risking concurrent modification anomalies.

@immutable
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => (product.price ?? 0) * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromMap(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }
}