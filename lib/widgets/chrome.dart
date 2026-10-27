import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/stores.dart';
import '../models/store.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import 'basics.dart';
import 'sheets.dart';

enum KavoTab {
  home('', 'Home', Icons.storefront_outlined, Icons.storefront_rounded),
  shop('/shop', 'Shop', Icons.grid_view_outlined, Icons.grid_view_rounded),
  saved('/saved', 'Saved', Icons.favorite_border_rounded, Icons.favorite_rounded),
  cart('/cart', 'Cart', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
  account('/account', 'Account', Icons.person_outline_rounded, Icons.person_rounded);

  const KavoTab(this.segment, this.label, this.icon, this.selectedIcon);

  final String segment;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  String pathFor(StoreKey store) => '/${store.name}$segment';
}

/// Bottom navigation shared by the five tab screens.
class KavoNavBar extends StatelessWidget {
  const KavoNavBar({super.key, required this.store, required this.current});

  final StoreKey store;
  final KavoTab current;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.cart.count;
    final savedCount = context.wishlist.count;

    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: KavoColors.line))),
      child: NavigationBar(
        selectedIndex: current.index,
        onDestinationSelected: (i) => context.go(KavoTab.values[i].pathFor(store)),
        destinations: [
          for (final tab in KavoTab.values)
            NavigationDestination(
              label: tab.label,
              tooltip: '',
              icon: _badged(tab, Icon(tab.icon), cartCount, savedCount),
              selectedIcon: _badged(tab, Icon(tab.selectedIcon), cartCount, savedCount),
            ),
        ],
      ),
    );
  }

  Widget _badged(KavoTab tab, Widget icon, int cart, int saved) {
    final count = switch (tab) {
      KavoTab.cart => cart,
      _ => 0,
    };
    if (count == 0) return icon;
    return Badge(label: Text('$count'), offset: const Offset(9, -6), child: icon);
  }
}

/// Cart mark + KAVO, as in the web header.
class KavoWordmark extends StatelessWidget {
  const KavoWordmark({super.key, required this.ink, required this.mark});

  final Color ink;
  final Color mark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shopping_cart_outlined, color: mark, size: 25),
        const SizedBox(width: 7),
        Text(
          Brand.wordmark,
          style: context.text.headlineSmall!.copyWith(
            color: ink,
            fontSize: 25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// The store home's top bar: wordmark, search, notifications and the store
/// switcher. Its colours come from the palette, so it is near-black for
/// fashion, green for grocery and white for furniture.
class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final overlay = p.barIsDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Material(
        color: p.bar,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.barIsDark ? Colors.transparent : KavoColors.line)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 10, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        KavoWordmark(ink: p.barInk, mark: p.mark),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Search',
                          onPressed: () => context.push('/${store.key.name}/search'),
                          icon: Icon(Icons.search_rounded, color: p.barInk, size: 26),
                        ),
                        IconButton(
                          tooltip: 'Notifications',
                          onPressed: () => showInboxSheet(context, store.key),
                          icon: Badge(
                            smallSize: 8,
                            backgroundColor: p.barIsDark && p.bar == p.brand ? Colors.white : p.brand,
                            child: Icon(Icons.notifications_none_rounded, color: p.barInk, size: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: StoreSwitcher(current: store.key, onChanged: (key) => context.go(key.path)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control that jumps between the three storefronts. The thumb
/// slides; the colours around it animate with the theme.
class StoreSwitcher extends StatelessWidget {
  const StoreSwitcher({super.key, required this.current, required this.onChanged, this.track, this.thumb, this.ink, this.thumbInk});

  final StoreKey current;
  final ValueChanged<StoreKey> onChanged;
  final Color? track;
  final Color? thumb;
  final Color? ink;
  final Color? thumbInk;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    const keys = StoreKey.values;
    final alignX = -1 + 2 * current.index / (keys.length - 1);

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: track ?? p.switcherTrack, borderRadius: BorderRadius.circular(99)),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(alignX, 0),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            child: FractionallySizedBox(
              widthFactor: 1 / keys.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: thumb ?? p.switcherThumb,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final key in keys)
                Expanded(
                  child: Semantics(
                    selected: key == current,
                    button: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(99),
                      onTap: key == current ? null : () => onChanged(key),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: KavoPalette.of(key).brand,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: t.labelSmall!.copyWith(
                                    fontSize: 11.5,
                                    letterSpacing: 1,
                                    color: key == current
                                        ? thumbInk ?? p.switcherThumbInk
                                        : (ink ?? p.barInk).withValues(alpha: 0.82),
                                  ),
                                  child: Text(key.label.toUpperCase()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White top bar for the non-home tabs: big title, optional subtitle.
class TabHeader extends StatelessWidget implements PreferredSizeWidget {
  const TabHeader({super.key, required this.title, this.subtitle, this.actions = const [], this.bottom});

  final String title;
  final Widget? subtitle;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(72 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.headlineMedium!.copyWith(fontSize: 27)),
          ?subtitle,
        ],
      ),
      actions: [...actions, const SizedBox(width: 8)],
      bottom: bottom,
    );
  }
}

/// Back arrow that still works when the page was opened straight from a URL.
class KavoBackButton extends StatelessWidget {
  const KavoBackButton({super.key, required this.fallback, this.floating = false});

  final String fallback;

  /// White circle for use over photos.
  final bool floating;

  @override
  Widget build(BuildContext context) {
    void back() => context.canPop() ? context.pop() : context.go(fallback);
    if (floating) {
      return RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: back);
    }
    return IconButton(tooltip: 'Back', onPressed: back, icon: const Icon(Icons.arrow_back_rounded));
  }
}
