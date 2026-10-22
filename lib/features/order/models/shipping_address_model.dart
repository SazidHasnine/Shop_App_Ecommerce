import 'package:flutter/foundation.dart';

@immutable
class ShippingAddressModel {
  final String fullName;
  final String addressLine;
  final String city;
  final String postalCode;
  final String phone;

  const ShippingAddressModel({
    required this.fullName,
    required this.addressLine,
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      fullName: json['fullName'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'addressLine': addressLine,
      'city': city,
      'postalCode': postalCode,
      'phone': phone,
    };
  }

  ShippingAddressModel copyWith({
    String? fullName,
    String? addressLine,
    String? city,
    String? postalCode,
    String? phone,
  }) {
    return ShippingAddressModel(
      fullName: fullName ?? this.fullName,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
    );
  }
}