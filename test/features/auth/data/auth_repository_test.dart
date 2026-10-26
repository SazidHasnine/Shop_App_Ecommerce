import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_remote_datasource.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldThrowInvalid = false;
  bool shouldThrowUnauthorized = false;

  final Map<String, dynamic> sampleLoginResponse = {
    'id': 1,
    'username': 'emilys',
    'email': 'emily.johnson@x.dummyjson.com',
    'firstName': 'Emily',
    'lastName': 'Johnson',
    'gender': 'female',
    'image': 'https://dummyjson.com/icon/emilys/128',
    'accessToken': 'test_access_token',
    'refreshToken': 'test_refresh_token',
  };

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    int? expiresInMins,
  }) async {
    if (shouldThrowInvalid) {
      throw const ServerException('Invalid credentials', 400);
    }
    return sampleLoginResponse;
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (shouldThrowUnauthorized) {
      throw const UnauthorizedException();
    }
    return sampleLoginResponse;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return sampleLoginResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferenceService preferenceService;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferenceService = await PreferenceService.init();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      preferenceService: preferenceService,
    );
  });

  group('AuthRepository Tests', () {
    test('login saves tokens and user data on success and returns UserModel', () async {
      final user = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(user.id, 1);
      expect(user.username, 'emilys');
      expect(preferenceService.getAuthToken(), 'test_access_token');
      expect(preferenceService.getRefreshToken(), 'test_refresh_token');

      final cachedUser = repository.getCachedUser();
      expect(cachedUser, isNotNull);
      expect(cachedUser!.username, 'emilys');
    });

    test('login propagates exception on failure', () async {
      mockRemoteDataSource.shouldThrowInvalid = true;

      expect(
        () => repository.login(
          username: 'wrong',
          password: 'wrong',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('checkAuthStatus returns null when no token is stored', () async {
      final user = await repository.checkAuthStatus();
      expect(user, isNull);
    });

    test('checkAuthStatus returns user when token exists and remote verifies', () async {
      await preferenceService.setAuthToken('valid_token');

      final user = await repository.checkAuthStatus();
      expect(user, isNotNull);
      expect(user!.username, 'emilys');
    });

    test('checkAuthStatus logs out and returns null when token is unauthorized', () async {
      await preferenceService.setAuthToken('expired_token');
      await preferenceService.setUserData({'id': 1, 'username': 'emilys'});
      mockRemoteDataSource.shouldThrowUnauthorized = true;

      final user = await repository.checkAuthStatus();

      expect(user, isNull);
      expect(preferenceService.getAuthToken(), isNull);
      expect(preferenceService.getUserData(), isNull);
    });

    test('logout clears all session data', () async {
      await preferenceService.setAuthToken('token');
      await preferenceService.setRefreshToken('refresh');
      await preferenceService.setUserData({'id': 1, 'username': 'emilys'});

      await repository.logout();

      expect(preferenceService.getAuthToken(), isNull);
      expect(preferenceService.getRefreshToken(), isNull);
      expect(preferenceService.getUserData(), isNull);
    });
  });
}
