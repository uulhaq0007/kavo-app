import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/stores.dart';
import '../models/format.dart';
import '../models/product.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/product_card.dart';

/// `/:store/product/:id`. Photo, price, rating, variants (size and colour,
/// weight, or finish), quantity, add to cart and related products.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Product? _product = productById(widget.productId);
  late Map<String, String> _options = _product?.defaultOptions ?? {};
  int _qty = 1;

  @override
  void didUpdateWidget(ProductScreen old) {
    super.didUpdateWidget(old);
    if (old.productId != widget.productId) {
      _product = productById(widget.productId);
      _options = _product?.defaultOptions ?? {};
      _qty = 1;
    }
  }

  void _addToCart(Product product) {
    context.readCart.add(product, options: _options, qty: _qty);
    showSnack(
      context,
      'Added ${_qty > 1 ? '$_qty × ' : ''}${product.name}',
      icon: Icons.check_circle_rounded,
      action: 'View cart',
      onAction: () => context.go('/${product.store.name}/cart'),
    );
  }

  Future<void> _share(Product product) async {
    await Clipboard.setData(ClipboardData(text: 'https://kavo.example/${product.store.name}/product/${product.id}'));
    if (mounted) showSnack(context, 'Link copied to clipboard', icon: Icons.link_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(leading: const KavoBackButton(fallback: '/fashion')),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Product not found',
          message: 'It may have sold out for the season.',
          action: 'Back to the shop',
          onAction: () => context.go('/fashion/shop'),
        ),
      );
    }

    final top = MediaQuery.paddingOf(context).top;
    final saved = context.wishlist.contains(product);
    final cartCount = context.cart.count;
    final p = context.palette;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 440 + top * 0.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'product-${product.id}', child: KavoImage(product.image)),
                  // The white lip makes the details read as a sheet pulled over
                  // the photo. (A translated sibling sliver would paint under it.)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: -1,
                    height: 29,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: top + 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        KavoBackButton(fallback: '/${product.store.name}/shop', floating: true),
                        const Spacer(),
                        RoundIconButton(icon: Icons.ios_share_rounded, tooltip: 'Share', onPressed: () => _share(product)),
                        const SizedBox(width: 10),
                        RoundIconButton(
                          icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: saved ? p.brand : null,
                          tooltip: saved ? 'Remove from saved' : 'Save',
                          onPressed: () => toggleSaved(context, product),
                        ),
                        const SizedBox(width: 10),
                        Badge(
                          isLabelVisible: cartCount > 0,
                          label: Text('$cartCount'),
                          offset: const Offset(-2, 2),
                          child: RoundIconButton(
                            icon: Icons.shopping_bag_outlined,
                            tooltip: 'Cart',
                            onPressed: () => context.go('/${product.store.name}/cart'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Details(
              product: product,
              options: _options,
              onOption: (group, value) => setState(() => _options = {..._options, group: value}),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BuyBar(
        product: product,
        qty: _qty,
        unitPrice: product.priceFor(_options),
        onQty: (q) => setState(() => _qty = q),
        onAdd: () => _addToCart(product),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.product, required this.options, required this.onOption});

  final Product product;
  final Map<String, String> options;
  final void Function(String group, String value) onOption;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final p = context.palette;
    final unit = product.priceFor(options);
    final was = product.was == null ? null : product.was! + (unit - product.price);
    final related = relatedTo(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StoreChip(product.store),
                  const SizedBox(width: 8),
                  Expanded(child: Text(product.category, style: t.bodySmall!.copyWith(fontSize: 13))),
                  StarRating(product.rating, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    '${product.rating.toStringAsFixed(1)} (${product.reviews})',
                    style: t.labelMedium!.copyWith(color: KavoColors.ink, fontSize: 12.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(product.name, style: t.headlineSmall!.copyWith(fontSize: 26)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(money(unit), style: t.headlineSmall!.copyWith(fontSize: 26, color: p.brandDark)),
                  if (was != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      money(was),
                      style: t.bodyLarge!.copyWith(
                        color: KavoColors.body,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: KavoColors.body,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'Save ${product.percentOff}%',
                        style: t.labelMedium!.copyWith(color: p.brandDark, fontSize: 12),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _StockLabel(product: product),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
              for (final group in product.variants) ...[
                _VariantPicker(
                  group: group,
                  selected: options[group.name] ?? group.options.first.label,
                  onSelected: (v) => onOption(group.name, v),
                ),
                const SizedBox(height: 22),
              ],
              Text('Description', style: t.titleMedium),
              const SizedBox(height: 8),
              Text(product.description, style: t.bodyMedium!.copyWith(fontSize: 15, height: 1.65)),
              const SizedBox(height: 14),
              for (final h in product.highlights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: p.brand),
                      const SizedBox(width: 10),
                      Expanded(child: Text(h, style: t.bodyMedium!.copyWith(color: KavoColors.ink))),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              _DeliveryCard(product: product),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SectionHeader(
          title: 'You may also like',
          subtitle: 'More from ${product.category.toLowerCase()} and the ${product.store.label.toLowerCase()} range',
          onAction: () => context.openShop(product.store),
        ),
        ProductRail(products: related, aspect: product.store.name == 'fashion' ? 560 / 640 : 1),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final (color, label) = !product.inStock
        ? (KavoColors.danger, 'Sold out')
        : product.lowStock
        ? (KavoColors.warning, 'Only ${product.stock} left')
        : (KavoColors.success, 'In stock');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: context.text.labelMedium!.copyWith(color: color, fontSize: 12.5)),
      ],
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({required this.group, required this.selected, required this.onSelected});

  final VariantGroup group;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: group.name,
            style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600),
            children: [TextSpan(text: '   $selected', style: t.bodyMedium)],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final o in group.options)
              group.isSwatch
                  ? _Swatch(option: o, selected: o.label == selected, onTap: () => onSelected(o.label))
                  : Semantics(
                      button: true,
                      selected: o.label == selected,
                      child: GestureDetector(
                        onTap: () => onSelected(o.label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 46,
                          constraints: const BoxConstraints(minWidth: 54),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: o.label == selected ? p.brand : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: o.label == selected ? p.brand : KavoColors.line, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                o.label,
                                style: t.titleSmall!.copyWith(
                                  color: o.label == selected ? Colors.white : KavoColors.ink,
                                  fontSize: 14,
                                ),
                              ),
                              if (o.priceDelta != 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${o.priceDelta > 0 ? '+' : '−'}${money(o.priceDelta.abs())}',
                                  style: t.bodySmall!.copyWith(
                                    color: o.label == selected ? Colors.white70 : KavoColors.body,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.option, required this.selected, required this.onTap});

  final VariantOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final light = option.swatch!.computeLuminance() > 0.7;
    return Tooltip(
      message: option.label,
      child: Semantics(
        button: true,
        selected: selected,
        label: option.label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? p.brand : Colors.transparent, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: option.swatch,
                shape: BoxShape.circle,
                border: Border.all(color: light ? KavoColors.line : Colors.transparent),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 18, color: light ? KavoColors.ink : Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = storeOf(product.store);
    final rows = [
      (Icons.local_shipping_outlined, 'Free delivery over \$150', 'Standard \$8.00 · Express \$15.00'),
      (Icons.schedule_rounded, store.deliveryNote, 'From the Kavo ${store.label.toLowerCase()} warehouse in Bellhaven'),
      (Icons.autorenew_rounded, '30 day returns', 'Unused items go back for a full refund.'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          for (final (icon, title, sub) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: context.palette.brand),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleSmall!.copyWith(fontSize: 14)),
                        Text(sub, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.product,
    required this.qty,
    required this.unitPrice,
    required this.onQty,
    required this.onAdd,
  });

  final Product product;
  final int qty;
  final double unitPrice;
  final ValueChanged<int> onQty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final alert = context.account.wantsRestockAlert(product);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: KavoColors.line)),
      ),
      child: product.inStock
          ? Row(
              children: [
                QtyStepper(
                  qty: qty,
                  onMinus: qty > 1 ? () => onQty(qty - 1) : null,
                  onPlus: qty < product.stock ? () => onQty(qty + 1) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Add to cart · ${moneyExact(unitPrice * qty)}', maxLines: 1),
                    ),
                  ),
                ),
              ],
            )
          : FilledButton.icon(
              onPressed: () {
                final on = context.readAccount.toggleRestockAlert(product);
                showSnack(
                  context,
                  on ? 'We’ll email you when ${product.name} is back' : 'Back-in-stock alert removed',
                  icon: on ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                );
              },
              style: alert
                  ? FilledButton.styleFrom(backgroundColor: KavoColors.ink)
                  : null,
              icon: Icon(alert ? Icons.notifications_active_rounded : Icons.notifications_none_rounded),
              label: Text(alert ? 'Alert set · tap to cancel' : 'Notify me when it’s back'),
            ),
    );
  }
}
