import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ecommerce/core/constants/api_constants.dart';
import 'package:shop_app_ecommerce/core/constants/payment_constants.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/core/router/app_router.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';
import 'package:shop_app_ecommerce/core/theme/app_theme.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_remote_datasource.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_repository.dart';
import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_remote_datasource.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_repository.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';
import 'package:shop_app_ecommerce/features/order/data/order_repository.dart';
import 'package:shop_app_ecommerce/features/order/provider/order_provider.dart';
import 'package:shop_app_ecommerce/features/payment/data/payment_repository.dart';
import 'package:shop_app_ecommerce/features/product/data/product_repository.dart';
import 'package:shop_app_ecommerce/features/product/provider/product_provider.dart';

class MyApp extends StatelessWidget {
  final DioClient dioClient;
  final PreferenceService preferenceService;

  const MyApp({
    super.key,
    required this.dioClient,
    required this.preferenceService,
  });

  @override
  Widget build(BuildContext context) {
    final cachedUser = preferenceService.getUserData();
    final initialUserId = (cachedUser?['id'] as num?)?.toInt() ?? 1;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: AuthRepositoryImpl(
              authRemoteDatasource: AuthRemoteDatasourceImpl(dioClient: dioClient),
              preferenceService: preferenceService,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            productRepository: ProductRepositoryImpl(dioClient : dioClient)
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            cartRepository: CartRepositoryImpl(
              preferenceService: preferenceService,
              remoteDatasource: CartRemoteDatasourceImpl(dioClient: dioClient),
            ),
            initialUserId: initialUserId,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          update: (_, auth, order) => order!..syncUser(auth.user?.id),
          create: (_) => OrderProvider(
            orderRepository: OrderRepositoryImpl(
              dioClient: DioClient(
                preferenceService: preferenceService,
                baseUrl: ApiConstants.orderBaseUrl,
              ),
            ),
            paymentRepository: AmarPayRepositoryImpl(
              dioClient: DioClient(
                preferenceService: preferenceService,
                baseUrl: PaymentConstants.sandboxBaseUrl,
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'E-commerce Shop',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
