import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/core/router/app_router.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';
import 'package:shop_app_ecommerce/core/theme/app_theme.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_remote_datasource.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_repository.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';
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
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'E-commerce Shop',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
