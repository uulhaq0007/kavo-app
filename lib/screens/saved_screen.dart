import 'package:material_ui/material_ui.dart';

import '../models/format.dart';
import '../models/store.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/product_card.dart';

/// `/:store/saved`. The wishlist, shared across stores, filterable by store.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key, required this.store});

  final Store store;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  StoreKey? _only;

  @override
  Widget build(BuildContext context) {
    final all = context.wishlist.products;
    final products = _only == null ? all : all.where((p) => p.store == _only).toList();
    final storeCount = all.map((p) => p.store).toSet().length;

    return Scaffold(
      appBar: TabHeader(
        title: 'Saved',
        subtitle: Text(
          all.isEmpty ? 'Tap the heart on anything to keep it here' : '${plural(all.length, 'piece')} from ${plural(storeCount, 'store')}',
          style: context.text.bodySmall!.copyWith(fontSize: 13),
        ),
      ),
      body: all.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Nothing saved yet',
              message: 'Save pieces from any store and compare them here later.',
              action: 'Browse the shop',
              onAction: () => context.openShop(widget.store.key),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        ChoiceChip(
                          label: Text('All  ${all.length}'),
                          selected: _only == null,
                          onSelected: (_) => setState(() => _only = null),
                        ),
                        for (final key in StoreKey.values) ...[
                          const SizedBox(width: 8),
                          ChoiceChip(
                            avatar: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: KavoPalette.of(key).brand,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.2),
                              ),
                            ),
                            label: Text('${key.label}  ${all.where((p) => p.store == key).length}'),
                            selected: _only == key,
                            onSelected: (_) => setState(() => _only = _only == key ? null : key),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'Nothing saved from ${_only!.label.toLowerCase()}',
                      message: 'Hearts you tap in that store will show up here.',
                      action: 'Visit ${_only!.label}',
                      onAction: () => context.openShop(_only!),
                    ),
                  )
                else
                  SliverProductGrid(products: products, aspect: 0.92, showStore: true),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
      bottomNavigationBar: KavoNavBar(store: widget.store.key, current: KavoTab.saved),
    );
  }
}
