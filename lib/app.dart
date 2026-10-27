import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'data/seed.dart';
import 'models/store.dart';
import 'router.dart';
import 'state/account_controller.dart';
import 'state/app_scope.dart';
import 'state/cart_controller.dart';
import 'state/wishlist_controller.dart';
import 'theme.dart';

/// Screenshot mode: `?shot` in the URL simulates an iPhone's safe areas so the
/// portfolio mockup's status bar and home indicator never cover content.
final bool shotMode = kIsWeb && Uri.base.queryParameters.containsKey('shot');

class KavoApp extends StatefulWidget {
  const KavoApp({super.key});

  @override
  State<KavoApp> createState() => _KavoAppState();
}

class _KavoAppState extends State<KavoApp> {
  static final _themes = {for (final key in StoreKey.values) key: buildKavoTheme(KavoPalette.of(key))};

  final _cart = CartController(seedCart());
  final _wishlist = WishlistController(seedWishlist);
  final _account = AccountController.seeded();
  final GoRouter _router = buildRouter();

  /// The storefront in the current URL. It drives the whole app's theme.
  late final ValueNotifier<StoreKey> _store = ValueNotifier(
    (kIsWeb ? StoreKey.tryParse(Uri.base.pathSegments.firstOrNull) : null) ?? StoreKey.fashion,
  );

  @override
  void initState() {
    super.initState();
    _router.routerDelegate.addListener(_syncStore);
  }

  void _syncStore() {
    final segments = _router.routerDelegate.currentConfiguration.uri.pathSegments;
    final key = StoreKey.tryParse(segments.firstOrNull);
    if (key != null) _store.value = key;
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_syncStore);
    _router.dispose();
    _store.dispose();
    _cart.dispose();
    _wishlist.dispose();
    _account.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      cart: _cart,
      wishlist: _wishlist,
      account: _account,
      child: ValueListenableBuilder<StoreKey>(
        valueListenable: _store,
        builder: (context, store, _) => MaterialApp.router(
          title: 'Kavo',
          debugShowCheckedModeBanner: false,
          // MaterialApp animates between themes, so switching store cross-fades
          // every colour in the app from one palette to the next.
          theme: _themes[store],
          themeAnimationDuration: const Duration(milliseconds: 450),
          themeAnimationCurve: Curves.easeInOutCubic,
          scrollBehavior: const _KavoScrollBehavior(),
          routerConfig: _router,
          builder: (context, child) {
            if (!shotMode) return child!;
            const pad = EdgeInsets.only(top: 47, bottom: 34);
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(padding: pad, viewPadding: pad),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

/// iOS-style bounce everywhere, drag-to-scroll with a mouse on the web build,
/// and no desktop scrollbars.
class _KavoScrollBehavior extends MaterialScrollBehavior {
  const _KavoScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
