import 'package:shop_app_ecommerce/core/storage/preference_service.dart';
import 'package:shop_app_ecommerce/features/cart/models/cart_item.dart';
import 'package:shop_app_ecommerce/features/cart/models/cloud_cart_dto.dart';

abstract class CartRepository {
  Future<List<CartItem>> loadCart();
  Future<void> saveCart(List<CartItem> items);
  Future<void> clearCart();

  Future<CloudCartDto?> fetchRemoteCart({required int userId});
  Future<CloudCartDto> pushCartToCloud({
    required int userId,
    required List<CartItem> items,
  });
  Future<void> deleteCloudCart();

  int? getCloudCartId();
  Future<void> setCloudCartId();
  DateTime? getLastSyncTime();
  Future<void> setLastSyncTime(DateTime time);
  bool hasPendingSync();
  Future<void> setPendingSync(bool pending);
}

class CartRepositoryImpl implements CartRepository {
  final PreferenceService preferenceService;
  final CartRemo
}