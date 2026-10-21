import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop_app_ecommerce/features/cart/data/cart_repository.dart';
import 'package:shop_app_ecommerce/features/cart/models/cart_item.dart';
import 'package:shop_app_ecommerce/features/cart/models/sync_status.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository cartRepository;
  final bool autoLoad;

  List<CartItem> _items = [];
  bool _isLoading = false;
  SyncStatus _syncStatus = SyncStatus.synced;
  String? _syncErrorMessage;
  int _userId = 1;
  Timer? _debounceTimer;

  CartProvider({
    required this.cartRepository,
    this.autoLoad = true,
    int? inititalUserId,
  }) : _userId = inititalUserId ?? 1 {
    if(autoLoad) {
      _loadInitialCart();
    }
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  SyncStatus get syncStatus => _syncStatus;
  String? get syncErrorMessage => _syncErrorMessage;
  DateTime? get lastSyncTime => cartRepository.getLastSyncTime();
  int get userId => _userId;

  set userId(int id) {
    _userId = id;
    notifyListeners();
  }

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
    _items.fold(0.0, (total, item) => total + item.totalPrice);

  double get tax => subtotal * 0.08; // estimating a fixed tax rate of 8%

  double get total => subtotal + tax;

  Future<void> _loadInitialCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await cartRepository.loadCart();
    } catch(_) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if(autoLoad) {
      await syncWithCloud();
    }
  }

  Future<void> syncWithCloud() async {
    if(_syncStatus == SyncStatus.syncing) return;

    _syncStatus = SyncStatus.syncing;
    _syncErrorMessage = null;
    notifyListeners();

    try {
      if(cartRepository.hasPendingSync()) {
        if(_items.isNotEmpty) {
          await cartRepository.pushCartToCloud(
              userId: _userId,
              items: _items,
          );
        } else {
          await cartRepository.deleteCloudCart();
        }
        await cartRepository.setPendingSync(false);
      } else {
        final remoteCart = await cartRepository.fetchRemoteCart(userId: _userId);
        if(remoteCart != null && remoteCart.products.isNotEmpty) {
          final remoteItems = remoteCart.toCartItems();
          if(_items.isEmpty) {
            _items = List.of(remoteItems);
            await cartRepository.saveCart(_items);
            await cartRepository.setCloudCartId(remoteCart.id);
          } else {
            bool changed = false;
            for(var remoteItem in remoteItems) {
              final exists = _items.any(
                  (i) => i.product.id == remoteItem.product.id,
              );
              if(!exists) {
                _items.add(remoteItem);
                changed = true;
              }
            }
            if(changed) {
              await cartRepository.saveCart(_items);
              await cartRepository.setCloudCartId(remoteCart.id);
            }
          }
        }
      }
      _syncStatus = SyncStatus.synced;
      await cartRepository.setLastSyncTime(DateTime.now());
      await cartRepository.setPendingSync(false);
    } catch(e) {
      _syncStatus = SyncStatus.offline;
      _syncErrorMessage = e.toString();
      await cartRepository.setPendingSync(true);
    } finally {
      notifyListeners();
    }
  }

  Future<void> syncNow() async => await syncWithCloud();

  void _schedulePushToCloud() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      await _executePushToCloud();
    });
  }

  Future<void> _executePushToCloud() async {
    _syncStatus = SyncStatus.syncing;
    _syncErrorMessage = null;
    notifyListeners();

    try {
      if(items.isEmpty) {
        await cartRepository.deleteCloudCart();
      } else {
        await cartRepository.pushCartToCloud(userId: _userId, items: _items);
      }
      _syncStatus = SyncStatus.synced;
      await cartRepository.setPendingSync(false);
      await cartRepository.setLastSyncTime(DateTime.now());
    } catch(e) {
      _syncStatus = SyncStatus.offline;
      _syncErrorMessage = e.toString();
      await cartRepository.setPendingSync(true);
    } finally {
      notifyListeners();
    }
  }

  Future<void> addItem(CartItem item, {int? quantity}) async {
    final addQuantity = quantity ?? item.quantity;
    final index = _items.indexWhere(
        (existingItem) => existingItem.product.id == item.product.id
    );
    if(index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(
        quantity: existing.quantity + addQuantity,
      );
    } else {
      _items.add(item.copyWith(quantity: addQuantity));
    }
    notifyListeners();
    await cartRepository.saveCart(_items);
    _schedulePushToCloud();
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    if(newQuantity <= 0) {
      await removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if(index >= 0) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
      await cartRepository.saveCart(_items);
      _schedulePushToCloud();
    }
  }

  Future<void> removeItem(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await cartRepository.saveCart(_items);
    _schedulePushToCloud();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await cartRepository.clearCart();
    _schedulePushToCloud();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void reset() {
    _debounceTimer?.cancel();
    _items = [];
    _isLoading = false;
    _syncStatus = SyncStatus.synced;
    _syncErrorMessage = null;
    notifyListeners();
  }
}