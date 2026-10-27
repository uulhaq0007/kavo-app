import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart' as catalog;
import '../models/format.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/product_card.dart';

/// `/:store/search?q=`. Searches the current store, and lists matches from the
/// other two stores underneath.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.store, this.initialQuery = ''});

  final Store store;
  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);

  String get _query => _controller.text.trim();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchFor(String text) {
    _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    context.readAccount.rememberSearch(text);
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Scaffold(
      appBar: AppBar(
        leading: KavoBackButton(fallback: store.key.path),
        titleSpacing: 0,
        toolbarHeight: 64,
        title: TextField(
          controller: _controller,
          autofocus: widget.initialQuery.isEmpty,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          onSubmitted: (v) => _searchFor(v.trim()),
          style: context.text.bodyLarge,
          decoration: InputDecoration(
            hintText: store.searchHint,
            prefixIcon: const Icon(Icons.search_rounded, size: 21),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(99), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(99), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(99),
              borderSide: BorderSide(color: context.palette.brand, width: 1.4),
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () => setState(_controller.clear),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
          ),
        ),
        actions: const [SizedBox(width: 16)],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _query.isEmpty
            ? _Suggestions(key: const ValueKey('suggest'), store: store, onPick: _searchFor)
            : _Results(key: ValueKey('results-$_query'), store: store, query: _query, onPick: _searchFor),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({super.key, required this.store, required this.onPick});

  final Store store;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final p = context.palette;
    final recent = context.account.recentSearches;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text('Popular in ${store.label}', style: t.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final term in store.popularSearches)
              ActionChip(
                avatar: Icon(Icons.trending_up_rounded, size: 17, color: p.brand),
                label: Text(term),
                onPressed: () => onPick(term),
              ),
          ],
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: Text('Recent searches', style: t.titleMedium)),
              TextButton(
                onPressed: context.readAccount.clearSearches,
                style: TextButton.styleFrom(foregroundColor: KavoColors.body),
                child: const Text('Clear'),
              ),
            ],
          ),
          for (final r in recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded, color: KavoColors.body),
              title: Text(r, style: t.titleSmall!.copyWith(fontWeight: FontWeight.w400)),
              trailing: const Icon(Icons.north_west_rounded, size: 18, color: KavoColors.body),
              onTap: () => onPick(r),
            ),
        ],
        const SizedBox(height: 24),
        Text('Browse ${store.label.toLowerCase()}', style: t.titleMedium),
        const SizedBox(height: 6),
        for (final c in store.categories)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SizedBox(width: 44, height: 44, child: ClipOval(child: KavoImage(c.image))),
            title: Text(c.name, style: t.titleSmall),
            subtitle: Text('${c.count} items'),
            trailing: const Icon(Icons.chevron_right_rounded, color: KavoColors.body),
            onTap: () => context.openShop(store.key, query: {'cat': c.filter}),
          ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({super.key, required this.store, required this.query, required this.onPick});

  final Store store;
  final String query;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final here = catalog.search(query, store: store.key);
    final elsewhere = catalog.search(query).where((p) => p.store != store.key).toList();

    if (here.isEmpty && elsewhere.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matches for “$query”',
        message: 'Try one of the popular searches, like “${store.popularSearches.first}”.',
        action: 'Search “${store.popularSearches.first}”',
        onAction: () => onPick(store.popularSearches.first),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          sliver: SliverToBoxAdapter(
            child: Text.rich(
              TextSpan(
                text: plural(here.length, 'result'),
                style: t.titleMedium,
                children: [TextSpan(text: ' in ${store.label}', style: t.bodyMedium)],
              ),
            ),
          ),
        ),
        if (here.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Nothing in ${store.label.toLowerCase()} yet, but the other stores have a match.', style: t.bodyMedium),
            ),
          )
        else
          SliverProductGrid(products: here, aspect: store.key == StoreKey.fashion ? 560 / 640 : 1),
        if (elsewhere.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            sliver: SliverToBoxAdapter(child: Text('In other stores', style: t.titleMedium)),
          ),
          SliverList.builder(
            itemCount: elsewhere.length,
            itemBuilder: (context, i) => _OtherStoreTile(product: elsewhere[i]),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _OtherStoreTile extends StatelessWidget {
  const _OtherStoreTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return InkWell(
      onTap: () => context.openProduct(product),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 64, height: 64, child: KavoImage(product.image, radius: BorderRadius.circular(14))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreChip(product.store),
                  const SizedBox(height: 4),
                  Text(product.name, style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
                  Text(product.category, style: t.bodySmall),
                ],
              ),
            ),
            Text(money(product.price), style: t.titleMedium),
            const Icon(Icons.chevron_right_rounded, color: KavoColors.body),
          ],
        ),
      ),
    );
  }
}
