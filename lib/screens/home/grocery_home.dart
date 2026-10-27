import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/catalog.dart';
import '../../models/format.dart';
import '../../models/store.dart';
import '../../router.dart';
import '../../theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/product_card.dart';
import 'home_parts.dart';

/// Grocery: pill search, produce hero with a side offer, round aisle grid,
/// weekend banners and "Fresh This Morning".
class GroceryHome extends StatefulWidget {
  const GroceryHome({super.key, required this.store});

  final Store store;

  @override
  State<GroceryHome> createState() => _GroceryHomeState();
}

class _GroceryHomeState extends State<GroceryHome> {
  GridFilter _filter = GridFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final products = _filter.apply(productsOf(store.key).take(8).toList());

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _SearchPill(store: store)),
        SliverToBoxAdapter(child: AnnounceBar(store: store)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(child: _Hero(store: store)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(child: _SideCard(store: store)),
        ),
        homeGap,
        SliverToBoxAdapter(
          child: SectionHeader(
            title: store.railTitle,
            subtitle: store.railSub,
            onAction: () => context.openShop(store.key),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 152,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _AisleCard(store: store, category: store.categories[i]),
              childCount: store.categories.length,
            ),
          ),
        ),
        homeGap,
        SliverToBoxAdapter(
          child: PromoCarousel(
            height: 170,
            count: store.promos.length,
            itemBuilder: (context, i) => _WeekendCard(store: store, promo: store.promos[i]),
          ),
        ),
        homeGap,
        SliverToBoxAdapter(
          child: SectionHeader(
            title: store.gridTitle,
            subtitle: store.gridSub,
            onAction: () => context.openShop(store.key),
          ),
        ),
        SliverToBoxAdapter(child: GridFilterChips(value: _filter, onChanged: (f) => setState(() => _filter = f))),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverProductGrid(products: products),
        homeGap,
        const SliverToBoxAdapter(child: TrustStrip()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(side: BorderSide(color: KavoColors.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/${store.key.name}/search'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 5, 5, 5),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: KavoColors.body, size: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    store.searchHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: p.brand, borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    'SEARCH',
                    style: context.text.labelSmall!.copyWith(color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final hero = store.hero;
    final p = context.palette;
    final t = context.text;
    return Pressable(
      onTap: () => context.openShop(store.key),
      child: SizedBox(
        height: 238,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              KavoImage(hero.image, alignment: const Alignment(0.6, 0)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xF7FFFFFF), Color(0xC7FFFFFF), Color(0x00FFFFFF)],
                    stops: [0, 0.5, 0.88],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Text(
                        hero.eyebrow.toUpperCase(),
                        style: t.labelSmall!.copyWith(color: KavoColors.ink, letterSpacing: 1, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hero.title.replaceFirst(' ', '\n'),
                      style: t.headlineMedium!.copyWith(fontSize: 31, height: 1.02),
                    ),
                    const SizedBox(height: 6),
                    Text(money(hero.price), style: t.titleLarge!.copyWith(fontSize: 22, color: p.brandDark)),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => context.openShop(store.key),
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hero.cta),
                          const SizedBox(width: 6),
                          const Icon(Icons.north_east_rounded, size: 17),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final card = store.sideCard!;
    final p = context.palette;
    final t = context.text;
    return Pressable(
      onTap: () => openPromo(context, store.key, card),
      child: Container(
        height: 148,
        decoration: BoxDecoration(color: p.heroTint, borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                      child: Text(card.kicker, style: t.labelMedium!.copyWith(color: KavoColors.ink, fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
                    Text(card.title, style: t.titleMedium!.copyWith(height: 1.25)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(card.cta, style: t.labelMedium!.copyWith(color: KavoColors.ink)),
                        const SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 128, child: KavoImage(card.image, alignment: const Alignment(0, 0.4))),
          ],
        ),
      ),
    );
  }
}

class _AisleCard extends StatelessWidget {
  const _AisleCard({required this.store, required this.category});

  final Store store;
  final StoreCategory category;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: KavoColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openCategory(context, store.key, category),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
          child: Column(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: ClipOval(child: KavoImage(category.image)),
              ),
              const SizedBox(height: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: t.titleSmall!.copyWith(fontSize: 13, height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text('${category.count} items', style: t.bodySmall!.copyWith(fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekendCard extends StatelessWidget {
  const _WeekendCard({required this.store, required this.promo});

  final Store store;
  final StorePromo promo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    return Pressable(
      onTap: () => openPromo(context, store.key, promo),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            KavoImage(promo.image, alignment: Alignment.centerRight, background: p.heroTint),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                  stops: [0, 0.5, 0.92],
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.68,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 0, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: p.brand, borderRadius: BorderRadius.circular(99)),
                      child: Text(promo.kicker, style: t.labelMedium!.copyWith(color: Colors.white, fontSize: 11.5)),
                    ),
                    const SizedBox(height: 8),
                    Text(promo.title, style: t.titleLarge!.copyWith(fontSize: 18.5, height: 1.2)),
                    if (promo.sub != null) ...[
                      const SizedBox(height: 4),
                      Text(promo.sub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 17, color: p.brand),
                        const SizedBox(width: 6),
                        Text(promo.cta, style: t.labelMedium!.copyWith(color: KavoColors.ink)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
