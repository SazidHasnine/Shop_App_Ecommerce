import 'package:flutter/foundation.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';
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

  int? syncedUserId;

  /// Called by a ProxyProvider whenever the auth user changes.
  /// Prefetches order history on login / app start, clears it on logout.
  void syncUser(int? userId) {

  }

  void updateSelectedPaymentMethod(PaymentMethod method) {

  }

  String generateTransactioId() {
    return 'EVR-AAM-${DateTime.now().millisecondsSinceEpoch}';
  }

  ShippingAddressModel getInitialShippingAddress(UserModel? user) {

  }

  Future<void> fetchOrderHistory({int? userId}) {
    _isLoadingHistory = true;
    notifyListeners();
    try {

    } catch(e) {

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