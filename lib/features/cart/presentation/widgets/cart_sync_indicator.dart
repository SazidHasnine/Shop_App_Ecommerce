import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ecommerce/features/cart/models/sync_status.dart';
import 'package:shop_app_ecommerce/features/cart/provider/cart_provider.dart';

class CartSyncIndicator extends StatelessWidget {
  const CartSyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final status = cartProvider.syncStatus;

    switch(status) {
      case SyncStatus.synced:
        return Tooltip(
          message: 'Cart synced with cloud',
          child: IconButton(
            icon: Icon(
              CupertinoIcons.cloud_fill,
              size: 20,
              color: Colors.green,
            ),
            onPressed: () => cartProvider.syncNow(),
          ),
        );
      case SyncStatus.syncing:
        return Tooltip(
          message: 'Syncing with cloud...',
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CupertinoActivityIndicator(radius: 8,),
            ),
          ),
        );
      case SyncStatus.offline:
        return Tooltip(
          message: 'Offline - Tap to sync with cloud',
          child: IconButton(
            icon: Icon(
              Icons.cloud_off,
              size: 20,
              color: Colors.orange,
            ),
            onPressed: () => cartProvider.syncNow(),
          ),
        );
      case SyncStatus.error:
        return Tooltip(
          message: cartProvider.syncErrorMessage ?? 'Sync error - Tap to retry',
          child: IconButton(
            icon: Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              size: 20,
              color: Colors.redAccent,
            ),
            onPressed: () => cartProvider.syncNow(),
          ),
        );
    }
  }
}
