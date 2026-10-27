import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../models/commerce.dart';
import '../models/format.dart';
import '../models/store.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/sheets.dart';
import 'cart_screen.dart';

/// `/:store/cart/checkout`. Three steps (address, payment, review), then the
/// order is filed in the account history and the cart empties.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.store, this.initialStep});

  final Store store;
  final int? initialStep;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _steps = ['Address', 'Payment', 'Review'];

  late int _step = (widget.initialStep ?? 1).clamp(1, 3);
  DeliveryOption _delivery = DeliveryOption.standard;
  bool _placing = false;

  String get _cartPath => '/${widget.store.key.name}/cart';

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.back(_cartPath);
    }
  }

  Future<void> _next() async {
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    setState(() => _placing = true);
    // A short pause stands in for the payment round-trip.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final order = context.readAccount.placeOrder(context.readCart, _delivery);
    context.go('/${widget.store.key.name}/order-placed/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.cart;

    if (cart.isEmpty && !_placing) {
      return Scaffold(
        appBar: AppBar(leading: KavoBackButton(fallback: _cartPath), title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Nothing to check out',
          message: 'Your cart is empty. Add something from any of the three stores first.',
          action: 'Back to the shop',
          onAction: () => context.openShop(widget.store.key),
        ),
      );
    }

    final total = cart.totalFor(_delivery);
    final label = switch (_step) {
      1 => 'Continue to payment',
      2 => 'Review order',
      _ => 'Place order',
    };

    return PopScope(
      canPop: _step == 1 && !_placing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_placing && _step > 1) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(tooltip: 'Back', onPressed: _placing ? null : _back, icon: const Icon(Icons.arrow_back_rounded)),
          titleSpacing: 4,
          title: const Text('Checkout'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: _StepIndicator(step: _step, labels: _steps),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: switch (_step) {
              1 => _AddressStep(delivery: _delivery, onDelivery: (d) => setState(() => _delivery = d)),
              2 => const _PaymentStep(),
              _ => _ReviewStep(delivery: _delivery, onEdit: (step) => setState(() => _step = step)),
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
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
                  onPressed: _placing ? null : _next,
                  style: FilledButton.styleFrom(
                    disabledBackgroundColor: context.palette.brand.withValues(alpha: 0.75),
                    disabledForegroundColor: Colors.white,
                  ),
                  child: _placing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_step == 3) ...[const Icon(Icons.lock_outline_rounded, size: 18), const SizedBox(width: 8)],
                            Flexible(child: Text(label, maxLines: 1)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.labels});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 1; i <= labels.length; i++) ...[
            SizedBox(
              width: 64,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i <= step ? p.brand : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: i <= step ? p.brand : KavoColors.line, width: 1.5),
                    ),
                    child: i < step
                        ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                        : Text(
                            '$i',
                            style: t.labelMedium!.copyWith(color: i == step ? Colors.white : KavoColors.body),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i - 1],
                    style: t.labelMedium!.copyWith(
                      fontSize: 12,
                      color: i <= step ? KavoColors.ink : KavoColors.body,
                      fontWeight: i == step ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (i < labels.length)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 2,
                    decoration: BoxDecoration(
                      color: i < step ? p.brand : KavoColors.line,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.title, {this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium!.copyWith(fontSize: 17.5))),
          ?trailing,
        ],
      ),
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({required this.delivery, required this.onDelivery});

  final DeliveryOption delivery;
  final ValueChanged<DeliveryOption> onDelivery;

  @override
  Widget build(BuildContext context) {
    final account = context.account;
    final cart = context.cart;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        const _StepTitle('Delivery address'),
        for (final a in account.addresses) ...[
          SelectCard(
            selected: a.id == account.address.id,
            onTap: () => context.readAccount.selectAddress(a.id),
            child: AddressText(address: a),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () async {
            final address = await showAddressForm(context);
            if (address != null && context.mounted) context.readAccount.addAddress(address);
          },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: KavoColors.line)),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add a new address'),
        ),
        const SizedBox(height: 28),
        const _StepTitle('Delivery speed'),
        for (final option in DeliveryOption.values) ...[
          SelectCard(
            selected: option == delivery,
            onTap: () => onDelivery(option),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.label, style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
                      Text(option.window, style: context.text.bodySmall),
                    ],
                  ),
                ),
                Text(
                  cart.shippingFor(option) == 0 ? 'Free' : moneyExact(cart.shippingFor(option)),
                  style: context.text.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cart.shippingFor(option) == 0 ? KavoColors.success : KavoColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep();

  @override
  Widget build(BuildContext context) {
    final account = context.account;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        _CardPreview(method: account.payment, holder: account.profile.name),
        const SizedBox(height: 26),
        const _StepTitle('Pay with'),
        for (final m in account.payments) ...[
          SelectCard(
            selected: m.id == account.payment.id,
            onTap: () => context.readAccount.selectPayment(m.id),
            child: PaymentText(method: m),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () async {
            final card = await showCardForm(context);
            if (card != null && context.mounted) context.readAccount.addPayment(card);
          },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: KavoColors.line)),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add a new card'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, size: 16, color: KavoColors.body),
            const SizedBox(width: 6),
            Text('Card details are tokenised and never touch our servers.', style: context.text.bodySmall),
          ],
        ),
      ],
    );
  }
}

/// The selected card drawn as a card, in the store's colours.
class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.method, required this.holder});

  final PaymentMethod method;
  final String holder;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final white = t.titleSmall!.copyWith(color: Colors.white);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.brand, Color.lerp(p.brandDark, KavoColors.ink, 0.55)!],
        ),
        boxShadow: [BoxShadow(color: p.brand.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -110,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: method.isCard
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('KAVO', style: white.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                          const Spacer(),
                          CardBrandMark(brand: method.brand, onDark: true),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '••••  ••••  ••••  ${method.last4}',
                        style: t.titleLarge!.copyWith(color: Colors.white, letterSpacing: 1.6, fontSize: 21),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _CardField(label: 'Card holder', value: method.holder.isEmpty ? holder : method.holder)),
                          _CardField(label: 'Expires', value: method.expiry),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.payments_outlined, color: Colors.white, size: 30),
                      const Spacer(),
                      Text('Cash on delivery', style: t.titleLarge!.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Pay the driver by card or cash when your order arrives.',
                        style: t.bodySmall!.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: t.labelSmall!.copyWith(color: Colors.white60, fontSize: 9.5, letterSpacing: 1.2)),
        const SizedBox(height: 2),
        Text(value, style: t.titleSmall!.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.delivery, required this.onEdit});

  final DeliveryOption delivery;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    final cart = context.cart;
    final account = context.account;
    final t = context.text;
    final byStore = <StoreKey, List<CartLine>>{};
    for (final line in cart.lines) {
      byStore.putIfAbsent(line.product.store, () => []).add(line);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        _StepTitle('Your items', trailing: Text(plural(cart.count, 'item'), style: t.bodySmall)),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          decoration: BoxDecoration(
            border: Border.all(color: KavoColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (final entry in byStore.entries) ...[
                if (entry.key != byStore.keys.first) const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 2),
                  child: Row(
                    children: [
                      StoreChip(entry.key),
                      const Spacer(),
                      Text(
                        storeOfDelivery(entry.key),
                        style: t.bodySmall!.copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                for (final line in entry.value) CompactLine(line: line),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        _ReviewBlock(
          title: 'Deliver to',
          onChange: () => onEdit(1),
          child: AddressText(address: account.address),
        ),
        const SizedBox(height: 12),
        _ReviewBlock(
          title: '${delivery.label} delivery',
          onChange: () => onEdit(1),
          child: Text(
            '${delivery.window} · ${cart.shippingFor(delivery) == 0 ? 'Free' : moneyExact(cart.shippingFor(delivery))}',
            style: t.bodyMedium,
          ),
        ),
        const SizedBox(height: 12),
        _ReviewBlock(
          title: 'Pay with',
          onChange: () => onEdit(2),
          child: PaymentText(method: account.payment),
        ),
        const SizedBox(height: 22),
        OrderTotals(
          subtotal: cart.subtotal,
          discount: cart.discount,
          promoCode: cart.promo?.code,
          shipping: cart.shippingFor(delivery),
          shippingLabel: '${delivery.label} shipping',
        ),
        const SizedBox(height: 14),
        Text(
          'Each store ships separately. You’ll get tracking for every parcel by email.',
          textAlign: TextAlign.center,
          style: t.bodySmall,
        ),
      ],
    );
  }
}

String storeOfDelivery(StoreKey key) => switch (key) {
  StoreKey.fashion => 'Ships today',
  StoreKey.grocery => 'Same-day delivery',
  StoreKey.furniture => 'Made to order · 4–6 weeks',
};

class _ReviewBlock extends StatelessWidget {
  const _ReviewBlock({required this.title, required this.child, required this.onChange});

  final String title;
  final Widget child;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
      decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600))),
              TextButton(onPressed: onChange, child: const Text('Change')),
            ],
          ),
          Padding(padding: const EdgeInsets.only(right: 8), child: child),
        ],
      ),
    );
  }
}

/// Thumbnail, name, options × qty and price on one row.
class CompactLine extends StatelessWidget {
  const CompactLine({super.key, required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return InkWell(
      onTap: () => context.openProduct(line.product),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 52, height: 52, child: KavoImage(line.product.image, radius: BorderRadius.circular(12))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall!.copyWith(fontSize: 14.5),
                  ),
                  Text('${line.optionsLabel}  ×${line.qty}', style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(moneyExact(line.lineTotal), style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
