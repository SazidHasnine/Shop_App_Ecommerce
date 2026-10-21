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
  /// The [Product] associated with this cart entry.
  final Product product;

  /// The quantity of the product in the cart (minimum 1).
  final int quantity;

  /// Creates an immutable [CartItem].
  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Computes the total price for this line item based on product price and quantity.
  double get totalPrice => product.price * quantity;

  /// Creates a copy of this [CartItem] with the given fields replaced by new values.
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Deserializes a [CartItem] from a JSON-compatible map.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromMap(
        json['product'] is Map
            ? Map<String, dynamic>.from(json['product'] as Map)
            : const <String, dynamic>{},
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Serializes this [CartItem] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  @override
  String toString() =>
      'CartItem(product: ${product.title}, quantity: $quantity, totalPrice: \$$totalPrice)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CartItem &&
              runtimeType == other.runtimeType &&
              other.product == product &&
              other.quantity == quantity;

  @override
  int get hashCode => Object.hash(product, quantity);
}