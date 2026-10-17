import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/app.dart';
import 'package:shop_app_ecommerce/core/network/dio_client.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferenceService = await PreferenceService.init();
  final dioClient = DioClient(preferenceService: preferenceService);

  runApp(MyApp(dioClient: dioClient, preferenceService: preferenceService,));
}
