import 'package:material_ui/material_ui.dart';

import 'account_controller.dart';
import 'cart_controller.dart';
import 'wishlist_controller.dart';

/// Exposes one [ChangeNotifier] to the tree. Widgets that read it through
/// `watch` rebuild when it notifies; `read` is for callbacks.
class NotifierScope<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const NotifierScope({super.key, required T notifier, required super.child}) : super(notifier: notifier);

  static T watch<T extends ChangeNotifier>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NotifierScope<T>>()!.notifier!;

  static T read<T extends ChangeNotifier>(BuildContext context) =>
      context.getInheritedWidgetOfExactType<NotifierScope<T>>()!.notifier!;
}

/// Puts the app-wide controllers above the router, so state survives every
/// navigation, including switching storefront.
class AppScope extends StatelessWidget {
  const AppScope({
    super.key,
    required this.cart,
    required this.wishlist,
    required this.account,
    required this.child,
  });

  final CartController cart;
  final WishlistController wishlist;
  final AccountController account;
  final Widget child;

  @override
  Widget build(BuildContext context) => NotifierScope<CartController>(
    notifier: cart,
    child: NotifierScope<WishlistController>(
      notifier: wishlist,
      child: NotifierScope<AccountController>(notifier: account, child: child),
    ),
  );
}

extension AppStateContext on BuildContext {
  CartController get cart => NotifierScope.watch<CartController>(this);
  WishlistController get wishlist => NotifierScope.watch<WishlistController>(this);
  AccountController get account => NotifierScope.watch<AccountController>(this);

  CartController get readCart => NotifierScope.read<CartController>(this);
  WishlistController get readWishlist => NotifierScope.read<WishlistController>(this);
  AccountController get readAccount => NotifierScope.read<AccountController>(this);
}
