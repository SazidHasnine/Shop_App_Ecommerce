import 'package:flutter/cupertino.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_repository.dart';
import 'package:shop_app_ecommerce/features/auth/models/auth_state.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthStatus _authStatus = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
}