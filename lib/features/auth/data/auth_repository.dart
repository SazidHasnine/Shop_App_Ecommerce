import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_remote_datasource.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<UserModel?> checkAuthStatus();

  UserModel? getCachedUser();

  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;
  final PreferenceService preferenceService;

  AuthRepositoryImpl({
    AuthRemoteDatasource? authRemoteDatasource,
    AuthRemoteDatasource? remoteDataSource,
    required this.preferenceService,
  }) : authRemoteDatasource = authRemoteDatasource ?? remoteDataSource!;

  @override
  Future<UserModel> login({required String username, required String password}) async {
    final data = await authRemoteDatasource.login(
        username: username,
        password: password,
    );

    // save auth tokens
    final accessToken =  data['accessToken']?.toString();
    final refreshToken = data['refreshToken']?.toString();

    if(accessToken != null && accessToken.isNotEmpty) {
      await preferenceService.setAuthToken(accessToken);
    }
    if(refreshToken != null && refreshToken.isNotEmpty) {
      await preferenceService.setRefreshToken(refreshToken);
    }

    final user = UserModel.fromMap(data);
    await preferenceService.setUserData(user.toMap());

    return user;
  }


  @override
  Future<UserModel?> checkAuthStatus() async {
    final token = preferenceService.getAuthToken();
    if(token == null || token.isEmpty) {
      return null; //error resolved after async is added, why?
    }

    // Attempt to load locally cached user first for immediate UI responsiveness
    final cachedData = preferenceService.getUserData();
    UserModel? cachedUser;
    if(cachedData != null) {
      cachedUser = UserModel.fromMap(cachedData);
    }

    // Verify token validity against /auth/me
    try {
      final freshData = await authRemoteDatasource.getCurrentUser();
      final freshUser = UserModel.fromMap(freshData);
      await preferenceService.setUserData(freshUser.toMap());
      return freshUser;
    } on UnauthorizedException {
      // Token is expired or invalid
      await logout();
      return null;
    } catch(_) {
      // In case of offline/network glitch, fallback to cached user if available
      return cachedUser;
    }
  }

  @override
  UserModel? getCachedUser() {
    final cachedData = preferenceService.getUserData();
    if(cachedData == null) return null;
    return UserModel.fromMap(cachedData);
  }

  @override
  Future<void> logout() async {
    await preferenceService.clearAuthSession();
  }

}