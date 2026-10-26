import 'package:shop_app_ecommerce/features/auth/data/auth_repository.dart';
import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';
import 'package:shop_app_ecommerce/features/auth/presentation/pages/signin_page.dart';
import 'package:shop_app_ecommerce/features/auth/provider/auth_provider.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_repository.dart';
import 'package:shop_app_ecommerce/features/cart/models/cart_item.dart';
import 'package:shop_app_ecommerce/features/cart/models/cloud_cart_dto.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCartRepository implements CartRepository {
  @override
  Future<List<CartItem>> loadCart() async => [];
  @override
  Future<void> saveCart(List<CartItem> items) async {}
  @override
  Future<void> clearCart() async {}
  @override
  Future<CloudCartDto?> fetchRemoteCart({required int userId}) async => null;
  @override
  Future<CloudCartDto> pushCartToCloud({
    required int userId,
    required List<CartItem> items,
  }) async =>
      const CloudCartDto(
        id: 1,
        products: [],
        total: 0,
        discountedTotal: 0,
        userId: 1,
        totalProducts: 0,
        totalQuantity: 0,
      );
  @override
  Future<void> deleteCloudCart() async {}
  @override
  DateTime? getLastSyncTime() => null;
  @override
  Future<void> setLastSyncTime(DateTime time) async {}
  @override
  bool hasPendingSync() => false;
  @override
  Future<void> setPendingSync(bool pending) async {}
  @override
  int? getCloudCartId() => null;
  @override
  Future<void> setCloudCartId(int? id) async {}
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login({required String username, required String password}) async {
    return const UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily@example.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: '',
    );
  }

  @override
  Future<UserModel?> checkAuthStatus() async => null;

  @override
  UserModel? getCachedUser() => null;

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget() {
    final authRepo = FakeAuthRepository();
    final cartRepo = FakeCartRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepo, autoCheck: false),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(cartRepository: cartRepo, autoLoad: false),
        ),
      ],
      child: const MaterialApp(
        home: SignInPage(),
      ),
    );
  }

  group('SignInPage Widget Tests', () {
    testWidgets('renders brand title, inputs, demo accounts, and buttons', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Shop-Ops'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Quick Demo Accounts (Tap to auto-fill)'), findsOneWidget);
      expect(find.text('Emily Johnson'), findsOneWidget);
      expect(find.text('Michael Williams'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.ensureVisible(signInButton);
      await tester.pumpAndSettle();

      // Tap Sign In button without entering username/password
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('tapping demo account chip auto-fills username and password', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Emily demo chip
      await tester.tap(find.text('Emily Johnson'));
      await tester.pumpAndSettle();

      // Verify TextFormField text updated
      expect(find.text('emilys'), findsOneWidget);
      expect(find.text('emilyspass'), findsOneWidget);
    });
  });
}
