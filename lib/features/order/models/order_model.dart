import '../../cart/models/cart_item.dart';
import 'shipping_address_model.dart';
import 'package:shop_app_ecommerce/features/order/models/payment_method_model.dart';

class OrderModel {
  final String id;
  final int userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final ShippingAddressModel shippingAddress;
  final PaymentMethod paymentMethod;
  final String? paymentStatus;
  final String? transactionId;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),
      userId: json['userId'] as int,
      items:
      (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddressModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      )
          : const ShippingAddressModel(
        fullName: '',
        addressLine: '',
        city: '',
        postalCode: '',
        phone: '',
      ),
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      transactionId: json['transactionId'] as String? ?? '',
      status: json['status'] as String? ?? 'confirmed',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod.value,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (transactionId != null) 'transactionId': transactionId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    int? userId,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    ShippingAddressModel? shippingAddress,
    PaymentMethod? paymentMethod,
    String? paymentStatus,
    String? transactionId,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}