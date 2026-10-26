import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ecommerce/core/constants/app_colors.dart';
import 'package:shop_app_ecommerce/core/router/app_router.dart';
import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:shop_app_ecommerce/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:shop_app_ecommerce/features/order/models/payment_method_model.dart';
import 'package:shop_app_ecommerce/features/order/models/shipping_address_model.dart';
import 'package:shop_app_ecommerce/features/order/presentation/widgets/payment_options.dart';
import 'package:shop_app_ecommerce/features/order/provider/order_provider.dart';
import 'package:shop_app_ecommerce/features/payment/models/payment_result_model.dart';

import '../../../cart/provider/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthProvider>().user;
    final initialAddress = context
        .read<OrderProvider>()
        .getInitialShippingAddress(authUser);

    _nameController = TextEditingController(text: initialAddress.fullName);
    _addressController.text = initialAddress.addressLine;
    _cityController.text = initialAddress.city;
    _postalController.text = initialAddress.postalCode;
    _phoneController.text = initialAddress.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if(!_formKey.currentState!.validate()) return;

    final cartProvider = context.read<CartProvider>();
    if(cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    final address = ShippingAddressModel(
      fullName: _nameController.text.trim(),
      addressLine: _addressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    String paymentStatus = 'pending';
    String? transactionId;

    if(orderProvider.selectedPaymentMethod == PaymentMethod.amarpay) {
      final txnId = orderProvider.generateTransactionId();

      try {
        final paymentUrl = await orderProvider.initiateAmarpayPayment(
          transactionId: txnId,
          amount: cartProvider.total,
          address: address,
          user: authProvider.user,
        );

        if(!mounted) return;

        final paymentResult = await context.push<PaymentResult>(
          AppRouter.paymentPath,
          extra: { 'paymentUrl': paymentUrl, 'transactionId': transactionId },
        );

        if(!mounted) return;

        if(paymentResult == null ||
        paymentResult.status == PaymentStatus.cancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled or failed.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if(paymentResult.status == PaymentStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment failed at gateway.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        paymentStatus = 'paid';
        transactionId = paymentResult.transactionId ?? txnId;
      } catch(e) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to initiate payment gateway: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final placedOrder = await orderProvider.placeOrder(
      items: cartProvider.items,
      subtotal: cartProvider.subtotal,
      tax: cartProvider.tax,
      total: cartProvider.total,
      shippingAddress: address,
      paymentStatus: paymentStatus,
      transactionId: transactionId,
      user: authProvider.user,
    );

    if(!mounted) return;

    if(placedOrder != null) {
      await cartProvider.clearCart();
      if(mounted) {
        context.go(AppRouter.orderSuccessRoute(placedOrder.id));
      }
    } else {
      final errorMsg = orderProvider.errorMessage ?? 'Failed to place order' ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'),),
      body: cartProvider.items.isEmpty && !orderProvider.isSubmitting
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.cart_badge_minus,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16,),
                const Text(
                  'No items to checkout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16,),
                ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Return to shop'),
                ),
              ],
            ),
          )
          : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Shipping Address Section
                Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12,),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Recipient Full Name',
                          prefixIcon: Icon(CupertinoIcons.person, size: 20,),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter full name'
                            : null,
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Street Address',
                          prefixIcon: Icon(CupertinoIcons.location, size: 20,),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter street address'
                            : null,
                      ),
                      const SizedBox(height: 12,),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                prefixIcon: Icon(
                                  CupertinoIcons.building_2_fill,
                                  size: 20,
                                ),
                              ),
                              validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter city'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12,),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _postalController,
                              decoration: const InputDecoration(
                                labelText: 'Zip / Postal',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter zip'
                                  : null,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone Number',
                          prefixIcon: Icon(CupertinoIcons.phone, size: 20,),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter contact phone'
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24,),

                // 2. Products Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark 
                          ? AppColors.borderDark 
                          : AppColors.borderLight,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12,),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                            ),
                            Dismissible(
                              key: ValueKey(item.product.id),
                              direction: DismissDirection.endToStart,
                              background: const SizedBox.shrink(),
                              onDismissed: (_) {
                                cartProvider.removeItem(item.product.id);
                              },
                              child: CartItemTile(item: item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24,),

                // 3. Payment Method Section
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12,),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: PaymentMethod.values.map((method) {
                      final isLast = method == PaymentMethod.values.last;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 8 ),
                        child: PaymentOption(
                          method: method,
                          isDark: isDark,
                          currentSelection: orderProvider.selectedPaymentMethod,
                          onSelect: orderProvider.updateSelectedPaymentMethod,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Order Summary Section
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${cartProvider.itemCount})',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Tax (8%)',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text('\$${cartProvider.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Standard Shipping',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'FREE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cartProvider.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Place Order Action Button
                ElevatedButton(
                  onPressed: orderProvider.isSubmitting
                      ? null
                      : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16,),
                  ),
                  child: orderProvider.isSubmitting
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Submitting Order...',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                      : Text(
                        'Place Order',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ],
            ),
          ),
    );
  }
}
