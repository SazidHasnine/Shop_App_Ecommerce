import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';

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
    final cachedUser = preferenceService.get

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      routes: {

      },

      initialRoute: ,
    );
  }
}
