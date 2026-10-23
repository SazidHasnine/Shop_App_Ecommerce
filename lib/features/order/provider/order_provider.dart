import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';
import 'package:shop_app_ecommerce/features/cart/models/cart_item.dart';
import 'package:shop_app_ecommerce/features/order/data/order_repository.dart';
import 'package:shop_app_ecommerce/features/order/models/order_model.dart';
import 'package:shop_app_ecommerce/features/order/models/payment_method_model.dart';
import 'package:shop_app_ecommerce/features/order/models/shipping_address_model.dart';
import 'package:shop_app_ecommerce/features/payment/data/payment_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository orderRepository;
  final PaymentRepository paymentRepository;

  bool _isSubmitting = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  bool _isGatewayLoading = false;
  List<OrderModel> _orders = [];
  OrderModel? _latestOrder;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isGatewayLoading => _isGatewayLoading;
  List<OrderModel> get orders => _orders;
  OrderModel? get latestOrder => _latestOrder;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;

  OrderProvider({
    required this.orderRepository,
    required this.paymentRepository,
  });

  int? _syncedUserId;

  /// Called by a ProxyProvider whenever the auth user changes.
  /// Prefetches order history on login / app start, clears it on logout.
  void syncUser(int? userId) {
    if(userId == _syncedUserId) return;
    _syncedUserId = userId;
    if(userId == null) {
      _orders = [];
      _latestOrder = null;
      // Defer: update() runs during the build phase.
      Future.microtask(notifyListeners);
    } else {
      Future.microtask(() => fetchOrderHistory(userId: userId));
    }
  }

  void updateSelectedPaymentMethod(PaymentMethod method) {
    if(_selectedPaymentMethod == method) return;
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  String generateTransactionId() {
    return 'EVR-AAM-${DateTime.now().millisecondsSinceEpoch}';
  }

  ShippingAddressModel getInitialShippingAddress(UserModel? user) {
    if(user != null) {
      return ShippingAddressModel(
        fullName: user.fullName,
        addressLine: '742 Evergreen Terrace',
        city: 'Springfield',
        postalCode: '97477',
        phone: user.phone ?? '',
      );
    }
    return const ShippingAddressModel(
      fullName: 'Guest Shopper',
      addressLine: '100 Market Street',
      city: 'San Francisco',
      postalCode: '94105',
      phone: '+1 (555) 432-1098',
    );
  }

  void setGatewayLoading(bool loading) {
    _isGatewayLoading = loading;
    notifyListeners();
  }

  void resetCheckoutState() {
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _isGatewayLoading = false;
    _isSubmitting = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<OrderModel?> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required ShippingAddressModel shippingAddress,
    String? paymentStatus,
    String? transactionId,
    UserModel? user,
  })  async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderId =
          'EVR-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      final newOrder = OrderModel(
        id: orderId,
        userId: user?.id ?? 0,
        items: List.from(items),
        subtotal: subtotal,
        tax: tax,
        total: total,
        shippingAddress: shippingAddress,
        paymentMethod: PaymentMethod.fromString(_selectedPaymentMethod.value),
        paymentStatus: paymentStatus,
        transactionId: transactionId,
        status: 'confirmed',
        createdAt: DateTime.now(),
      );

      final placed = await orderRepository.placeOrder(newOrder);
      _latestOrder = placed;
      // _orders.insert(0, placed);
      _isSubmitting = false;
      notifyListeners();
      return placed;
    } catch(e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  Future<String> initiateAmarpayPayment({
    required String transactionId,
    required double amount,
    required ShippingAddressModel address,
    UserModel? user,
    String? description,
  }) async {
    _isGatewayLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final paymentUrl = await paymentRepository.initialPayment(
        transactionId: transactionId,
        amount: amount,
        customerName: address.fullName,
        customerEmail: user?.email ?? 'user@mail.com',
        customerPhone: address.phone,
        customerAddress: address.addressLine,
        customerCity: address.city,
        description: description ?? 'Payment for order',
      );
      _isGatewayLoading = false;
      notifyListeners();
      return paymentUrl;
    } catch(e) {
      _errorMessage = e.toString();
      _isGatewayLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchOrderHistory({int? userId}) async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      _orders = await orderRepository.getOrders(userId: userId);
      _isLoadingHistory = false;
      notifyListeners();
    } catch(e) {
      _errorMessage = e.toString();
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // clear latest order
  void clearLatestOrder() {
    _latestOrder = null;
    notifyListeners();
  }

  // clear order state
  void clearOrderState() {
    _isSubmitting = false;
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _isGatewayLoading = false;
    _orders = [];
    _latestOrder = null;
    _isLoadingHistory = false;
    _errorMessage = null;
    notifyListeners();
  }
}