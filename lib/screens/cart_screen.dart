import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/stores.dart';
import '../models/commerce.dart';
import '../models/format.dart';
import '../models/store.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../state/cart_controller.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';

/// `/:store/cart`. The shared cart: lines from every storefront, each tagged
/// with its store, plus the free-shipping meter, promo codes and totals.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.store});

  final Store store;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _code = TextEditingController();
  String? _codeError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _apply() {
    final error = context.readCart.applyPromo(_code.text);
    setState(() => _codeError = error);
    if (error == null) {
      FocusScope.of(context).unfocus();
      _code.clear();
    }
  }

  void _remove(CartLine line) {
    final cart = context.readCart;
    final index = cart.remove(line);
    showSnack(
      context,
      'Removed ${line.product.name}',
      icon: Icons.delete_outline_rounded,
      action: 'Undo',
      onAction: () => cart.restore(line, index),
    );
  }

  Future<void> _confirmClear() async {
    final cart = context.readCart;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear your cart?'),
        content: Text('This removes all ${plural(cart.count, 'item')} from ${plural(cart.stores.length, 'store')}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep items')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );
    if (ok ?? false) cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.cart;
    final store = widget.store.key;

    return Scaffold(
      appBar: TabHeader(
        title: 'Cart',
        subtitle: Text(
          cart.isEmpty
              ? 'Shared across all three stores'
              : '${plural(cart.count, 'item')} from ${plural(cart.stores.length, 'store')}',
          style: context.text.bodySmall!.copyWith(fontSize: 13),
        ),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: _confirmClear,
              style: TextButton.styleFrom(foregroundColor: KavoColors.body),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message: 'Everything you add from fashion, grocery or furniture lands here, in one basket.',
              action: 'Start shopping',
              onAction: () => context.openShop(store),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                FreeShippingMeter(cart: cart),
                const SizedBox(height: 18),
                for (final line in cart.lines) ...[
                  Dismissible(
                    key: ValueKey(line.key),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _remove(line),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: KavoColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: KavoColors.danger),
                    ),
                    child: CartLineTile(line: line, onRemove: () => _remove(line)),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                if (cart.promo == null)
                  _PromoField(controller: _code, error: _codeError, onApply: _apply)
                else
                  _AppliedPromo(cart: cart),
                const SizedBox(height: 16),
                OrderTotals(
                  subtotal: cart.subtotal,
                  discount: cart.discount,
                  promoCode: cart.promo?.code,
                  shipping: cart.shippingFor(DeliveryOption.standard),
                  shippingLabel: 'Standard shipping',
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 15, color: KavoColors.body),
                    const SizedBox(width: 6),
                    Text('Secure checkout · 30 day returns', style: context.text.bodySmall),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!cart.isEmpty)
            _CheckoutBar(
              total: cart.totalFor(DeliveryOption.standard),
              onCheckout: () => context.push('/${store.name}/cart/checkout'),
            ),
          KavoNavBar(store: store, current: KavoTab.cart),
        ],
      ),
    );
  }
}

class FreeShippingMeter extends StatelessWidget {
  const FreeShippingMeter({super.key, required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final unlocked = cart.freeShipping;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  unlocked ? Icons.celebration_outlined : Icons.local_shipping_outlined,
                  color: p.brand,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked
                          ? 'You’ve unlocked free shipping'
                          : '${moneyExact(cart.toFreeShipping)} away from free shipping',
                      style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      unlocked ? 'Standard delivery is on us for this order.' : 'Free shipping over \$150',
                      style: t.bodySmall!.copyWith(color: p.brandDark.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(end: cart.freeShippingProgress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(value: value, minHeight: 8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(moneyExact(cart.merchandise), style: t.labelMedium!.copyWith(color: p.brandDark, fontSize: 12)),
              const Spacer(),
              Text(
                '${money(Brand.freeShippingOver)} free shipping',
                style: t.bodySmall!.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartLineTile extends StatelessWidget {
  const CartLineTile({super.key, required this.line, required this.onRemove});

  final CartLine line;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final cart = context.readCart;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: KavoColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.openProduct(line.product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 86,
                height: 104,
                child: KavoImage(line.product.image, radius: BorderRadius.circular(14)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StoreChip(line.product.store),
                        const Spacer(),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            tooltip: 'Remove',
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            onPressed: onRemove,
                            icon: const Icon(Icons.close_rounded, color: KavoColors.body),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      line.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(line.optionsLabel, style: t.bodySmall),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text(moneyExact(line.lineTotal), style: t.titleMedium)),
                        QtyStepper(
                          compact: true,
                          qty: line.qty,
                          onMinus: () => line.qty == 1 ? onRemove() : cart.decrement(line),
                          onPlus: line.qty < line.product.stock ? () => cart.increment(line) : null,
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

class _PromoField extends StatelessWidget {
  const _PromoField({required this.controller, required this.error, required this.onApply});

  final TextEditingController controller;
  final String? error;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => onApply(),
                style: context.text.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Promo code',
                  prefixIcon: const Icon(Icons.sell_outlined, size: 20),
                  errorText: error,
                  errorMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(backgroundColor: KavoColors.ink, minimumSize: const Size(92, 54)),
              child: const Text('Apply'),
            ),
          ],
        ),
        if (error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Furniture flat-sale codes DESK30 and SEAT10 work here.',
              style: context.text.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _AppliedPromo extends StatelessWidget {
  const _AppliedPromo({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final promo = cart.promo!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: KavoColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: KavoColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${promo.code} · ${promo.percent}% off ${promo.category.toLowerCase()}',
              style: context.text.titleSmall,
            ),
          ),
          TextButton(
            onPressed: cart.clearPromo,
            style: TextButton.styleFrom(foregroundColor: KavoColors.body),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Subtotal / promo / shipping / total card, shared with checkout and orders.
class OrderTotals extends StatelessWidget {
  const OrderTotals({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    this.promoCode,
    this.shippingLabel = 'Shipping',
  });

  final double subtotal;
  final double discount;
  final double shipping;
  final String? promoCode;
  final String shippingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          SummaryRow('Subtotal', moneyExact(subtotal)),
          if (discount > 0)
            SummaryRow('Promo${promoCode == null ? '' : ' $promoCode'}', '−${moneyExact(discount)}', valueColor: KavoColors.success),
          SummaryRow(shippingLabel, shipping == 0 ? 'Free' : moneyExact(shipping), valueColor: shipping == 0 ? KavoColors.success : null),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          SummaryRow('Total', moneyExact(subtotal - discount + shipping), emphasis: true),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});

  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: KavoColors.line)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: context.text.bodySmall),
              Text(moneyExact(total), style: context.text.titleLarge!.copyWith(fontSize: 21)),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: FilledButton(
              onPressed: onCheckout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Checkout'), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 19)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
