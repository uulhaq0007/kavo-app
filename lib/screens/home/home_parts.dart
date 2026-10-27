import 'package:material_ui/material_ui.dart';

import '../../data/stores.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../router.dart';
import '../../theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/sheets.dart';

/// Thin announcement strip, the app's version of the web utility bar.
class AnnounceBar extends StatelessWidget {
  const AnnounceBar({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: p.announce, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(store.announceIcon, size: 18, color: p.announceInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              store.announce,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium!.copyWith(color: p.announceInk, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Follows a promo banner's link: shop, a filtered shop, or the flagship sheet.
void openPromo(BuildContext context, StoreKey store, StorePromo promo) {
  switch (promo.link) {
    case PromoLink.shop:
      context.openShop(store);
    case PromoLink.onSale:
      context.openShop(store, query: {'sale': '1'});
    case PromoLink.category:
      context.openShop(store, query: {'cat': promo.category!});
    case PromoLink.flagship:
      showFlagshipSheet(context);
  }
}

void openCategory(BuildContext context, StoreKey store, StoreCategory category) =>
    context.openShop(store, query: {'cat': category.filter});

/// Square photo tiles with an uppercase label (fashion and furniture).
class CategoryTileRail extends StatelessWidget {
  const CategoryTileRail({super.key, required this.store, this.size = 112, this.overlay = false});

  final Store store;
  final double size;

  /// Furniture puts the label over the photo.
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return SizedBox(
      height: overlay ? size * 1.2 : size + 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: store.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = store.categories[i];
          if (overlay) {
            return Pressable(
              onTap: () => openCategory(context, store.key, c),
              child: SizedBox(
                width: size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    KavoImage(c.image, radius: BorderRadius.circular(18)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                          stops: [0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: t.titleSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('${c.count} pieces', style: t.bodySmall!.copyWith(color: Colors.white70, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Pressable(
            onTap: () => openCategory(context, store.key, c),
            child: SizedBox(
              width: size,
              child: Column(
                children: [
                  Container(
                    width: size,
                    height: size,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(20)),
                    child: KavoImage(c.image, radius: BorderRadius.circular(15)),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    c.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelSmall!.copyWith(color: KavoColors.ink, fontSize: 11, letterSpacing: 0.7),
                  ),
                  const SizedBox(height: 1),
                  Text('${c.count} items', style: t.bodySmall!.copyWith(fontSize: 11.5)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Scales down slightly while pressed, for photo tiles that have no ink.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}

/// "All items / On sale / New arrivals / Best sellers", as on the web grid.
enum GridFilter {
  all('All items'),
  sale('On sale'),
  fresh('New arrivals'),
  best('Best sellers');

  const GridFilter(this.label);

  final String label;

  List<Product> apply(List<Product> products) => switch (this) {
    GridFilter.all => products,
    GridFilter.sale => products.where((p) => p.onSale).toList(),
    GridFilter.fresh => products.where((p) => p.isNew || p.badge == null).take(4).toList(),
    GridFilter.best => ([...products]..sort((a, b) => b.reviews.compareTo(a.reviews))).take(4).toList(),
  };
}

class GridFilterChips extends StatelessWidget {
  const GridFilterChips({super.key, required this.value, required this.onChanged});

  final GridFilter value;
  final ValueChanged<GridFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: GridFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = GridFilter.values[i];
          return ChoiceChip(
            label: Text(f.label),
            selected: f == value,
            onSelected: (_) => onChanged(f),
          );
        },
      ),
    );
  }
}

/// Four reassurance cards from the web footer band.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: trustPoints.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final tp = trustPoints[i];
          return Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle),
                  child: Icon(tp.icon, color: p.brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tp.title, style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(tp.text, style: t.bodySmall!.copyWith(height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Horizontally paged promo cards with dots.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key, required this.height, required this.count, required this.itemBuilder});

  final double height;
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.89);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(left: i == 0 ? 20 : 6, right: i == widget.count - 1 ? 20 : 6),
              child: widget.itemBuilder(context, i),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? p.brand : KavoColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

const homeGap = SliverToBoxAdapter(child: SizedBox(height: 30));
