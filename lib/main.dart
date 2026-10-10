import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/app.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferenceService = await PreferenceService.init();

  runApp(const MyApp());
}

