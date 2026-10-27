import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../models/format.dart';
import '../models/product.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import 'basics.dart';

/// Height of the text block under a product photo. Fixed so grid rows line up.
const double kProductInfoHeight = 112;

/// Product tile shared by all three storefronts. Its accent comes from the
/// theme, so the same widget renders red, green or brown.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.showStore = false});

  final Product product;

  /// Saved items and search mix stores, so they show a store chip.
  final bool showStore;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final saved = context.wishlist.contains(product);

    return Semantics(
      button: true,
      label: product.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.openProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: KavoImage(product.image, radius: BorderRadius.circular(18)),
                    ),
                  ),
                  Positioned(left: 10, top: 10, child: _Badges(product: product)),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: _HeartButton(saved: saved, onTap: () => toggleSaved(context, product)),
                  ),
                  if (!product.inStock)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _Tag(label: 'Sold out', color: Colors.white.withValues(alpha: 0.92), ink: KavoColors.ink),
                    ),
                  if (showStore)
                    Positioned(left: 10, bottom: product.inStock ? 10 : 40, child: StoreChip(product.store, onDark: true)),
                ],
              ),
            ),
            SizedBox(
              height: kProductInfoHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall!.copyWith(fontSize: 12),
                          ),
                        ),
                        Icon(Icons.star_rounded, size: 14, color: p.brand),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: t.labelMedium!.copyWith(fontSize: 12, color: KavoColors.ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      height: 38,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleSmall!.copyWith(fontSize: 14.5, height: 1.3),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            spacing: 6,
                            children: [
                              Text(money(product.price), style: t.titleMedium!.copyWith(fontSize: 16.5)),
                              if (product.was != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.5),
                                  child: Text(
                                    money(product.was!),
                                    style: t.bodySmall!.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: KavoColors.body,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (product.inStock) _AddButton(onTap: () => quickAdd(context, product)),
                      ],
                    ),
                    const SizedBox(height: 4),
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

/// Adds the default variant and offers a shortcut to the cart.
void quickAdd(BuildContext context, Product product) {
  context.readCart.add(product);
  final defaults = product.defaultOptions.values.join(' · ');
  showSnack(
    context,
    'Added ${product.name}${defaults.isEmpty ? '' : ' ($defaults)'}',
    icon: Icons.check_circle_rounded,
    action: 'View cart',
    onAction: () => context.go('/${product.store.name}/cart'),
  );
}

void toggleSaved(BuildContext context, Product product) {
  final saved = context.readWishlist.toggle(product);
  showSnack(
    context,
    saved ? 'Saved ${product.name}' : 'Removed ${product.name} from saved',
    icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    action: saved ? 'View saved' : 'Undo',
    onAction: saved
        ? () => context.go('/${product.store.name}/saved')
        : () => context.readWishlist.toggle(product),
  );
}

class _Badges extends StatelessWidget {
  const _Badges({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final off = product.percentOff;
    return Row(
      children: [
        if (product.badge != null) _Tag(label: product.badge!.toUpperCase(), color: p.brand, ink: Colors.white),
        if (product.badge != null && off != null) const SizedBox(width: 4),
        if (off != null) _Tag(label: '-$off%', color: KavoColors.ink, ink: Colors.white),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.ink});

  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
      child: Text(label, style: context.text.labelSmall!.copyWith(color: ink, fontSize: 10.5, letterSpacing: 0.5)),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.saved, required this.onTap});

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RoundIconButton(
      size: 34,
      tooltip: saved ? 'Remove from saved' : 'Save',
      icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      color: saved ? context.palette.brand : KavoColors.ink,
      onPressed: onTap,
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.brand,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Tooltip(
          message: 'Add to cart',
          child: SizedBox(width: 34, height: 34, child: Icon(Icons.add_rounded, color: Colors.white, size: 20)),
        ),
      ),
    );
  }
}

/// Two-column product grid as a sliver. Row height is computed from the
/// photo's aspect ratio so cards never stretch or clip.
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.products,
    this.aspect = 1,
    this.showStore = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<Product> products;

  /// Photo width / height.
  final double aspect;
  final bool showStore;
  final EdgeInsets padding;

  static const gap = 14.0;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.crossAxisExtent - gap) / 2;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: gap,
              mainAxisSpacing: 18,
              mainAxisExtent: width / aspect + kProductInfoHeight,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => ProductCard(product: products[i], showStore: showStore),
              childCount: products.length,
            ),
          );
        },
      ),
    );
  }
}

/// Horizontal strip of product cards ("You may also like").
class ProductRail extends StatelessWidget {
  const ProductRail({super.key, required this.products, this.width = 160, this.aspect = 1});

  final List<Product> products;
  final double width;
  final double aspect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: width / aspect + kProductInfoHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => SizedBox(width: width, child: ProductCard(product: products[i])),
      ),
    );
  }
}
