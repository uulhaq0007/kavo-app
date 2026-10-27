import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/stores.dart';
import '../models/format.dart';
import '../models/product.dart';
import '../models/shop_filters.dart';
import '../models/store.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/sheets.dart';

/// `/:store/shop`. Category chips, sort, and a filter sheet for category,
/// price, rating and stock. Filters can be preset from the URL.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.store, required this.query});

  final Store store;
  final Map<String, String> query;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late ShopFilters _filters;
  late ShopSort _sort;
  final _scroll = ScrollController();

  List<Product> get _all => productsOf(widget.store.key);

  @override
  void initState() {
    super.initState();
    _readQuery();
  }

  @override
  void didUpdateWidget(ShopScreen old) {
    super.didUpdateWidget(old);
    if (old.store.key != widget.store.key || !mapEquals(old.query, widget.query)) {
      _readQuery();
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _readQuery() {
    _filters = ShopFilters.fromQuery(widget.query, PriceBounds.of(_all));
    _sort = ShopSort.parse(widget.query['sort']);
    if (widget.query['filters'] == '1') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFilters();
      });
    }
  }

  Future<void> _openFilters() async {
    final result = await showFilterSheet(
      context,
      initial: _filters,
      products: _all,
      categories: categoriesOf(widget.store.key),
    );
    if (result != null && mounted) setState(() => _filters = result);
  }

  Future<void> _openSort() async {
    final result = await showSortSheet(context, _sort);
    if (result != null && mounted) setState(() => _sort = result);
  }

  void _toggleCategory(String? category) {
    setState(() {
      _filters = _filters.copyWith(
        categories: category == null || (_filters.categories.length == 1 && _filters.categories.contains(category))
            ? {}
            : {category},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final products = _sort.apply(_all.where(_filters.matches).toList());
    final categories = categoriesOf(store.key);

    return Scaffold(
      appBar: TabHeader(
        title: 'Shop',
        subtitle: _StorePicker(store: store.key),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.push('/${store.key.name}/search'),
            icon: const Icon(Icons.search_rounded, size: 26),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ToolbarDelegate(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _filters.categories.isEmpty,
                          onSelected: (_) => _toggleCategory(null),
                        ),
                        for (final c in categories) ...[
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(c),
                            selected: _filters.categories.contains(c),
                            onSelected: (_) => _toggleCategory(c),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: '${products.length}',
                              style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: products.length == 1 ? ' product' : ' products',
                                  style: context.text.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openSort,
                          style: TextButton.styleFrom(foregroundColor: KavoColors.ink),
                          icon: const Icon(Icons.swap_vert_rounded, size: 19),
                          label: Text(_sort.label),
                        ),
                        const SizedBox(width: 4),
                        _FilterButton(count: _filters.extraCount + (_filters.categories.length > 1 ? 1 : 0), onTap: _openFilters),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_filters.extraCount > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_filters.price != null)
                      _ActiveChip(
                        '${money(_filters.price!.start)} – ${money(_filters.price!.end)}',
                        () => setState(() => _filters = _filters.copyWith(clearPrice: true)),
                      ),
                    if (_filters.minRating > 0)
                      _ActiveChip(
                        '${_filters.minRating.toStringAsFixed(1)}★ & up',
                        () => setState(() => _filters = _filters.copyWith(minRating: 0)),
                      ),
                    if (_filters.inStockOnly)
                      _ActiveChip('In stock', () => setState(() => _filters = _filters.copyWith(inStockOnly: false))),
                    if (_filters.onSaleOnly)
                      _ActiveChip('On sale', () => setState(() => _filters = _filters.copyWith(onSaleOnly: false))),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.filter_alt_off_outlined,
                title: 'Nothing matches yet',
                message: 'Try a wider price range or fewer filters.',
                action: 'Clear filters',
                onAction: () => setState(() => _filters = const ShopFilters()),
              ),
            )
          else
            SliverProductGrid(products: products, aspect: store.key == StoreKey.fashion ? 560 / 640 : 1),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
      bottomNavigationBar: KavoNavBar(store: store.key, current: KavoTab.shop),
    );
  }
}

class _ToolbarDelegate extends SliverPersistentHeaderDelegate {
  const _ToolbarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 104;

  @override
  double get maxExtent => 104;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: overlapsContent || shrinkOffset > 0 ? KavoColors.line : Colors.white)),
      ),
      child: Padding(padding: const EdgeInsets.only(top: 4, bottom: 6), child: child),
    );
  }

  @override
  bool shouldRebuild(_ToolbarDelegate oldDelegate) => true;
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final active = count > 0;
    return Material(
      color: active ? p.brand : KavoColors.ink,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 7),
              Text('Filters', style: context.text.labelMedium!.copyWith(color: Colors.white, fontSize: 13.5)),
              if (active) ...[
                const SizedBox(width: 7),
                Container(
                  width: 19,
                  height: 19,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Text('$count', style: context.text.labelSmall!.copyWith(color: p.brandDark, letterSpacing: 0)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip(this.label, this.onDeleted);

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: p.brandSoft,
      labelStyle: context.text.labelMedium!.copyWith(color: p.brandDark),
      deleteIconColor: p.brandDark,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    );
  }
}

/// "● Fashion store ▾": switches storefront without leaving the shop tab.
class _StorePicker extends StatelessWidget {
  const _StorePicker({required this.store});

  final StoreKey store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PopupMenuButton<StoreKey>(
      tooltip: 'Switch storefront',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      onSelected: (key) => context.go('/${key.name}/shop'),
      itemBuilder: (context) => [
        for (final key in StoreKey.values)
          PopupMenuItem(
            value: key,
            child: Row(
              children: [
                PaletteSwatch(store: key),
                const SizedBox(width: 12),
                Expanded(child: Text(key.label)),
                if (key == store) Icon(Icons.check_rounded, size: 18, color: p.brand),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                '${store.label} · ${storeOf(store).tagline}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall!.copyWith(fontSize: 13),
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 18, color: KavoColors.body),
          ],
        ),
      ),
    );
  }
}
