import 'package:flutter/foundation.dart';
import 'package:shop_app_ecommerce/features/cart/models/cart_item.dart';
import 'package:shop_app_ecommerce/features/product/models/product.dart';

/// A single item within a cloud cart as a response from DummyJSON
@immutable
class CloudCartProductDto {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  const CloudCartProductDto({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    this.total = 0.0,
    this.discountPercentage = 0.0,
    this.discountedTotal = 0.0,
    this.thumbnail= '',
  });

  factory CloudCartProductDto.fromJson(Map<String, dynamic> json) {
    return CloudCartProductDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ??
          (json['discountedPrice'] as num?)?.toDouble() ??
          0.0,
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'quantity': quantity,
    'total': total,
    'discountPercentage': discountPercentage,
    'discountedTotal': discountedTotal,
    'thumbnail': thumbnail,
  };

  CartItem toCartItem() {
    return CartItem(
      product: Product(
        id: id,
        title: title,
        price: price,
        thumbnail: thumbnail,
        discountPercentage: discountPercentage,
        rating: 4.5,
        stock: 50,
      ),
      quantity: quantity,
    );
  }
}

/// Cloud Cart data transfer object parsed from DummyJSON `/carts` responses.
@immutable
class CloudCartDto {
  final int id;
  final int userId;
  final List<CloudCartProductDto> products;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;

  const CloudCartDto({
    required this.id,
    required this.userId,
    this.products = const [],
    this.total = 0.0,
    this.discountedTotal = 0.0,
    this.totalProducts = 0,
    this.totalQuantity = 0,
  });

  factory CloudCartDto.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    final parsedProducts = rawProducts
                         .whereType<Map<String, dynamic>>()
                         .map(CloudCartProductDto.fromJson)
                         .toList();

    return CloudCartDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      products: parsedProducts,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? parsedProducts.length,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ??
          parsedProducts.fold(0, (sum, p) => sum + p.quantity),
    );
  }

  static List<CloudCartDto> fromUserCartsJson(Map<String, dynamic> json) {
    final rawCarts = json['carts'] as List<dynamic>? ?? [];
    return rawCarts
        .whereType<Map<String, dynamic>>()
        .map(CloudCartDto.fromJson)
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'products': products.map((p) => p.toJson()).toList(),
    'total': total,
    'discountedTotal': discountedTotal,
    'totalProducts': totalProducts,
    'totalQuantity': totalQuantity,
  };

  List<CartItem> toCartitem() {
    return products.map((p) => p.toCartItem()).toList();
  }
}