import 'package:shop_app_ecommerce/core/network/api_exceptions.dart';
import 'package:shop_app_ecommerce/features/auth/data/auth_repository.dart';
import 'package:shop_app_ecommerce/features/auth/models/auth_state.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';
import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? mockUser;
  bool shouldThrowInvalid = false;
  bool shouldThrowNetwork = false;
  bool loggedOut = false;

  final UserModel sampleUser = const UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: '',
  );

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    if (shouldThrowInvalid) {
      throw const ServerException('Invalid credentials', 400);
    }
    if (shouldThrowNetwork) {
      throw const NetworkException('No internet');
    }
    mockUser = sampleUser;
    return sampleUser;
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    return mockUser;
  }

  @override
  UserModel? getCachedUser() {
    return mockUser;
  }

  @override
  Future<void> logout() async {
    mockUser = null;
    loggedOut = true;
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late AuthProvider provider;

  setUp(() {
    mockRepository = MockAuthRepository();
    provider = AuthProvider(authRepository: mockRepository, autoCheck: false);
  });

  group('AuthProvider Tests', () {
    test('initial status is AuthStatus.initial', () {
      expect(provider.status, AuthStatus.initial);
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
    });

    test('login success sets status to authenticated and populates user', () async {
      final success = await provider.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(success, true);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.isAuthenticated, true);
      expect(provider.user?.username, 'emilys');
      expect(provider.errorMessage, isNull);
    });

    test('login invalid credentials sets status to error and sets message', () async {
      mockRepository.shouldThrowInvalid = true;

      final success = await provider.login(
        username: 'wrong',
        password: 'wrong',
      );

      expect(success, false);
      expect(provider.status, AuthStatus.error);
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(provider.errorMessage, 'Invalid credentials');
    });

    test('login network failure sets friendly error message', () async {
      mockRepository.shouldThrowNetwork = true;

      final success = await provider.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(success, false);
      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, contains('internet connection'));
    });

    test('logout clears user and updates status to unauthenticated', () async {
      await provider.login(username: 'emilys', password: 'emilyspass');
      expect(provider.isAuthenticated, true);

      await provider.logout();

      expect(provider.isAuthenticated, false);
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.user, isNull);
      expect(mockRepository.loggedOut, true);
    });

    test('clearError resets error message', () async {
      mockRepository.shouldThrowInvalid = true;
      await provider.login(username: 'wrong', password: 'wrong');
      expect(provider.errorMessage, isNotNull);

      provider.clearError();
      expect(provider.errorMessage, isNull);
    });
  });
}
