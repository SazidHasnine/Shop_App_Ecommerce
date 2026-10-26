import 'package:flutter/cupertino.dart';
import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_repository.dart';
import 'package:shop_app_ecommerce/features/auth/models/auth_state.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider({required this.authRepository, bool autoCheck = true}) {
    if(autoCheck) {
      checkAuthStatus();
    }
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
    _status == AuthStatus.authenticated && _user != null;
  bool get isLoading => _status == AuthStatus.authenticating;

  Future<void> checkAuthStatus() async {
    // Check locally cached user first for immediate display
    final cached = authRepository.getCachedUser();
    if(cached != null) {
      _user = cached;
      _status = AuthStatus.authenticated;
      notifyListeners();
    }

    try {
      final verifiedUser = await authRepository.checkAuthStatus();
      if(verifiedUser != null) {
        _user = verifiedUser;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch(_) {
      if(_user == null) {
        _status = AuthStatus.unauthenticated;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await authRepository.login(
          username: username,
          password: password,
      );
      _user = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ServerException catch(e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } on NetworkException {
      _errorMessage = 'No internet connection. Please check your network.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch(e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();

    clearAuth();
  }

  void clearError() {
    if(errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearAuth() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}