import 'package:flutter/foundation.dart';
import 'package:shop_app_ecommerce/core/storage/preference_service.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_remote_datasource.dart';
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
  Future<void> setCloudCartId(int? id);
  DateTime? getLastSyncTime();
  Future<void> setLastSyncTime(DateTime time);
  bool hasPendingSync();
  Future<void> setPendingSync(bool pending);
}

class CartRepositoryImpl implements CartRepository {
  final PreferenceService preferenceService;
  final CartRemoteDatasource remoteDatasource;

  CartRepositoryImpl({
    required this.preferenceService,
    required this.remoteDatasource,
  });


  @override
  Future<List<CartItem>> loadCart() async {
    final cached = preferenceService.getCartCache();
    return cached.map((e) => CartItem.fromJson(e)).toList();
  }

  @override
  Future<void> saveCart(List<CartItem> items) async {
    final maps = items.map((e) => e.toJson()).toList();
    await preferenceService.setCartCache(maps);
  }

  @override
  Future<void> clearCart() async {
    await preferenceService.setCartCache([]);
  }

  @override
  Future<CloudCartDto?> fetchRemoteCart({required int userId}) async {
    return await remoteDatasource.fetchUserCart(userId);
  }

  @override
  Future<CloudCartDto> pushCartToCloud({
    required int userId,
    required List<CartItem> items
  }) async {
    final existingCartId = preferenceService.getColudCartId();
    if(existingCartId != null && existingCartId > 0) {
      try {
        final result = await remoteDatasource.updateCloudCart(
            cartId: existingCartId,
            items: items,
        );
        await setCloudCartId(result.id);
        await setLastSyncTime(DateTime.now());
        await setPendingSync(false);
        return result;
      } catch (_) {
        // Fallback to create if update fails (e.g. ephemeral server reset 404)
        final result = await remoteDatasource.createCloudCart(
          userId: userId,
          items: items,
        );
        await setCloudCartId(result.id);
        await setLastSyncTime(DateTime.now());
        await setPendingSync(false);
        return result;
      }
    } else {
      final result = await remoteDatasource.createCloudCart(
        userId: userId,
        items: items,
      );
      await setCloudCartId(result.id);
      await setLastSyncTime(DateTime.now());
      await setPendingSync(false);
      return result;
    }
  }

  @override
  Future<void> deleteCloudCart() async {
    final cartId = preferenceService.getColudCartId();
    if(cartId != null) {
      try{
        await remoteDatasource.deleteCloudCart(cartId);
      } catch (_) {
        // Silently tolerates remote delete failures in the background
      }
      await setCloudCartId(cartId);
    }
  }

  @override
  int? getCloudCartId() => preferenceService.getColudCartId();

  @override
  Future<void> setCloudCartId(int? id) => preferenceService.setColudCartId(id);

  @override
  DateTime? getLastSyncTime() => preferenceService.getLastCartSync();

  @override
  Future<void> setLastSyncTime(DateTime time) =>
      preferenceService.setLastCartSync(time);

  @override
  bool hasPendingSync() => preferenceService.hasPendingCartSync();

  @override
  Future<void> setPendingSync(bool pending) =>
      preferenceService.setPendingCartSync(pending);
}