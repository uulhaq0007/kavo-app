import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'data/stores.dart';
import 'models/product.dart';
import 'models/store.dart';
import 'screens/account_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home/store_home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/order_placed_screen.dart';
import 'screens/product_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/search_screen.dart';
import 'screens/shop_screen.dart';

/// Every URL starts with the storefront: `/fashion`, `/grocery/shop`,
/// `/furniture/product/linden-three-seater`. The first segment picks the theme.
///
/// Screenshot-friendly states open straight from a URL:
///   /fashion/shop?filters=1          shop with the filter sheet up
///   /fashion/shop?cat=Shoes&sale=1   any filter combination
///   /grocery/search?q=salmon         search results
///   /fashion/cart/checkout?step=3    checkout on the review step
GoRouter buildRouter() => GoRouter(
  initialLocation: '/fashion',
  redirect: (context, state) {
    final first = state.uri.pathSegments.firstOrNull;
    return StoreKey.tryParse(first) == null ? '/fashion' : null;
  },
  errorPageBuilder: (context, state) => _fade(state, const NotFoundScreen(), key: state.pageKey),
  routes: [
    GoRoute(
      path: '/:store',
      pageBuilder: (context, state) => _tab(state, 'home', StoreHomeScreen(store: _store(state))),
      routes: [
        GoRoute(
          path: 'product/:id',
          pageBuilder: (context, state) => _slide(state, ProductScreen(productId: state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'search',
          pageBuilder: (context, state) =>
              _slide(state, SearchScreen(store: _store(state), initialQuery: state.uri.queryParameters['q'] ?? '')),
        ),
        GoRoute(
          path: 'order-placed/:id',
          pageBuilder: (context, state) =>
              _fade(state, OrderPlacedScreen(store: _store(state), orderId: state.pathParameters['id']!)),
        ),
      ],
    ),
    GoRoute(
      path: '/:store/shop',
      pageBuilder: (context, state) =>
          _tab(state, 'shop', ShopScreen(store: _store(state), query: state.uri.queryParameters)),
    ),
    GoRoute(
      path: '/:store/saved',
      pageBuilder: (context, state) => _tab(state, 'saved', SavedScreen(store: _store(state))),
    ),
    GoRoute(
      path: '/:store/cart',
      pageBuilder: (context, state) => _tab(state, 'cart', CartScreen(store: _store(state))),
      routes: [
        GoRoute(
          path: 'checkout',
          pageBuilder: (context, state) => _slide(
            state,
            CheckoutScreen(store: _store(state), initialStep: int.tryParse(state.uri.queryParameters['step'] ?? '')),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/:store/account',
      pageBuilder: (context, state) => _tab(state, 'account', AccountScreen(store: _store(state))),
      routes: [
        GoRoute(
          path: 'orders/:id',
          pageBuilder: (context, state) =>
              _slide(state, OrderDetailScreen(store: _store(state), orderId: state.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);

Store _store(GoRouterState state) => storeOf(StoreKey.tryParse(state.pathParameters['store']) ?? StoreKey.fashion);

/// Tabs share one page key per tab, so switching storefront updates the page in
/// place (the palette animates) instead of pushing a new one.
Page<void> _tab(GoRouterState state, String tab, Widget child) => CustomTransitionPage<void>(
  key: ValueKey('tab-$tab'),
  child: child,
  transitionDuration: const Duration(milliseconds: 220),
  reverseTransitionDuration: const Duration(milliseconds: 180),
  transitionsBuilder: (context, animation, secondary, child) =>
      FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child),
);

Page<void> _slide(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 320),
  transitionsBuilder: (context, animation, secondary, child) {
    final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    return SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(curve),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 24)],
        ),
        child: child,
      ),
    );
  },
);

Page<void> _fade(GoRouterState state, Widget child, {LocalKey? key}) => CustomTransitionPage<void>(
  key: key ?? state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 420),
  transitionsBuilder: (context, animation, secondary, child) {
    final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curve), child: child),
    );
  },
);

/// Navigation helpers used across screens.
extension KavoNavigation on BuildContext {
  void openProduct(Product product) => push('/${product.store.name}/product/${product.id}');

  void openShop(StoreKey store, {Map<String, String> query = const {}}) =>
      go(Uri(path: '/${store.name}/shop', queryParameters: query.isEmpty ? null : query).toString());

  void openSearch(StoreKey store) => push('/${store.name}/search');

  void openOrder(StoreKey store, String id) => push('/${store.name}/account/orders/$id');

  /// Pops when there is somewhere to go back to, otherwise lands on [fallback]
  /// (a page opened straight from a URL has no history).
  void back(String fallback) => canPop() ? pop() : go(fallback);
}
