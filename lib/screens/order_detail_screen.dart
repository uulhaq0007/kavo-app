import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../models/commerce.dart';
import '../models/format.dart';
import '../models/store.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/sheets.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

/// `/:store/account/orders/:id`. Status tracker, items, address, payment,
/// totals, plus "Buy again" and "Get help".
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.store, required this.orderId});

  final Store store;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = context.account.orderById(orderId);
    final accountPath = '/${store.key.name}/account';
    final t = context.text;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(leading: KavoBackButton(fallback: accountPath)),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Order not found',
          message: 'We couldn’t find order $orderId.',
          action: 'Back to your orders',
          onAction: () => context.go(accountPath),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: KavoBackButton(fallback: accountPath),
        titleSpacing: 4,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ${order.id}', style: t.titleLarge),
            Text('Placed ${formatDate(order.placedAt)}', style: t.bodySmall),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _StatusCard(order: order),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text('Items', style: t.titleMedium)),
              Text(plural(order.itemCount, 'item'), style: t.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            decoration: BoxDecoration(
              border: Border.all(color: KavoColors.line),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (final line in order.lines) ...[
                  if (line != order.lines.first) const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(alignment: Alignment.centerLeft, child: StoreChip(line.product.store)),
                  ),
                  CompactLine(line: line),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          _InfoBlock(
            icon: Icons.place_outlined,
            title: 'Delivery address',
            child: AddressText(address: order.address),
          ),
          const SizedBox(height: 12),
          _InfoBlock(
            icon: Icons.local_shipping_outlined,
            title: '${order.delivery.label} delivery',
            child: Text(order.delivery.window, style: t.bodyMedium),
          ),
          const SizedBox(height: 12),
          _InfoBlock(
            icon: Icons.credit_card_rounded,
            title: 'Payment',
            child: PaymentText(method: order.payment),
          ),
          const SizedBox(height: 22),
          OrderTotals(
            subtotal: order.subtotal,
            discount: order.discount,
            promoCode: order.promoCode,
            shipping: order.shipping,
            shippingLabel: '${order.delivery.label} shipping',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: KavoColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => showHelpSheet(context),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: KavoColors.line)),
                child: const Text('Get help'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  final cart = context.readCart;
                  for (final line in order.lines) {
                    if (line.product.inStock) cart.add(line.product, options: line.options, qty: line.qty);
                  }
                  showSnack(
                    context,
                    'Added ${plural(order.itemCount, 'item')} from ${order.id} to your cart',
                    icon: Icons.check_circle_rounded,
                    action: 'View cart',
                    onAction: () => context.go('/${store.key.name}/cart'),
                  );
                },
                icon: const Icon(Icons.replay_rounded, size: 19),
                label: const Text('Buy again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final Order order;

  static const _steps = ['Placed', 'Packed', 'Shipped', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final reached = switch (order.status) {
      OrderStatus.processing => 0,
      OrderStatus.shipped => 2,
      OrderStatus.delivered => 3,
    };
    final headline = switch (order.status) {
      OrderStatus.processing => 'Being packed',
      OrderStatus.shipped => 'On the way',
      OrderStatus.delivered => 'Delivered',
    };
    final sub = order.status == OrderStatus.delivered
        ? 'Delivered ${formatDay(order.eta)}'
        : 'Arriving ${formatDay(order.eta)}';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  order.status == OrderStatus.delivered ? Icons.inventory_2_outlined : Icons.local_shipping_outlined,
                  color: p.brand,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headline, style: t.titleLarge!.copyWith(fontSize: 19)),
                    Text(sub, style: t.bodyMedium!.copyWith(color: p.brandDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: i <= reached ? p.brand : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: i <= reached ? p.brand : KavoColors.line, width: 1.5),
                        ),
                        child: i <= reached ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _steps[i],
                        style: t.labelMedium!.copyWith(
                          fontSize: 11.5,
                          color: i <= reached ? KavoColors.ink : KavoColors.body,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _steps.length - 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(height: 2, color: i < reached ? p.brand : KavoColors.line),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.processing => KavoColors.warning,
      OrderStatus.shipped => const Color(0xFF2F6FDB),
      OrderStatus.delivered => KavoColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
      child: Text(status.label, style: context.text.labelMedium!.copyWith(color: color, fontSize: 12)),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: context.palette.brand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
