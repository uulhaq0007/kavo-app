import 'package:material_ui/material_ui.dart';

import '../../models/store.dart';
import '../../widgets/chrome.dart';
import 'fashion_home.dart';
import 'furniture_home.dart';
import 'grocery_home.dart';

/// `/fashion`, `/grocery`, `/furniture`. The header stays put while the body
/// cross-fades to the new store and the palette animates underneath it.
class StoreHomeScreen extends StatelessWidget {
  const StoreHomeScreen({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StoreHeader(store: store),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(store.key),
                child: switch (store.key) {
                  StoreKey.fashion => FashionHome(store: store),
                  StoreKey.grocery => GroceryHome(store: store),
                  StoreKey.furniture => FurnitureHome(store: store),
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: KavoNavBar(store: store.key, current: KavoTab.home),
    );
  }
}
