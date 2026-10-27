import 'package:material_ui/material_ui.dart';

import '../../data/catalog.dart';
import '../../models/format.dart';
import '../../models/store.dart';
import '../../router.dart';
import '../../theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/product_card.dart';
import 'home_parts.dart';

/// Fashion: full-bleed lifestyle hero, category tiles, promo carousel and the
/// "Trending This Week" grid.
class FashionHome extends StatefulWidget {
  const FashionHome({super.key, required this.store});

  final Store store;

  @override
  State<FashionHome> createState() => _FashionHomeState();
}

class _FashionHomeState extends State<FashionHome> {
  GridFilter _filter = GridFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final products = _filter.apply(productsOf(store.key).take(8).toList());

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: AnnounceBar(store: store)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(child: _Hero(store: store)),
        ),
        homeGap,
        SliverToBoxAdapter(
          child: SectionHeader(
            title: store.railTitle,
            subtitle: store.railSub,
            onAction: () => context.openShop(store.key),
          ),
        ),
        SliverToBoxAdapter(child: CategoryTileRail(store: store)),
        homeGap,
        SliverToBoxAdapter(
          child: PromoCarousel(
            height: 176,
            count: store.promos.length,
            itemBuilder: (context, i) => _PromoCard(store: store, promo: store.promos[i]),
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
        SliverProductGrid(products: products, aspect: 560 / 640),
        homeGap,
        const SliverToBoxAdapter(child: TrustStrip()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
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
        height: 430,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              KavoImage(hero.image, alignment: const Alignment(-0.5, 0), background: p.heroTint),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00141414), Color(0x33141414), Color(0xE6141414)],
                    stops: [0.35, 0.55, 1],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    hero.eyebrow.toUpperCase(),
                    style: t.labelSmall!.copyWith(color: p.brand, letterSpacing: 1.6, fontSize: 10.5),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 20,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.title.toUpperCase(),
                      style: t.displaySmall!.copyWith(color: Colors.white, fontSize: 33, height: 1.02),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hero.priceLabel ?? '', style: t.bodySmall!.copyWith(color: Colors.white70)),
                              Text(
                                money(hero.price),
                                style: t.headlineMedium!.copyWith(color: Colors.white, height: 1.1),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () => context.openShop(store.key),
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: Text(hero.cta, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.store, required this.promo});

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
            KavoImage(promo.image, alignment: Alignment.centerRight),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xD9FFFFFF), Color(0x00FFFFFF)],
                  stops: [0, 0.48, 0.9],
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.66,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 0, 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(promo.kicker, style: t.labelMedium!.copyWith(color: p.brand)),
                    const SizedBox(height: 6),
                    Text(promo.title, style: t.titleLarge!.copyWith(fontSize: 19, height: 1.2)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(color: p.brand.withValues(alpha: 0.14), shape: BoxShape.circle),
                          child: Icon(
                            promo.link == PromoLink.flagship ? Icons.place_outlined : Icons.add_rounded,
                            size: 15,
                            color: p.brand,
                          ),
                        ),
                        const SizedBox(width: 8),
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
