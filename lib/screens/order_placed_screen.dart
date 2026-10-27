import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../models/commerce.dart';
import '../models/format.dart';
import '../models/store.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';

/// `/:store/order-placed/:id`. Confirmation with the order number.
class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key, required this.store, required this.orderId});

  final Store store;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final account = context.account;
    final order = account.orderById(orderId);
    final home = '/${store.key.name}';

    if (order == null) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Order not found',
          message: 'We couldn’t find order $orderId.',
          action: 'Go to your account',
          onAction: () => context.go('$home/account'),
        ),
      );
    }

    final t = context.text;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            const Center(child: _SuccessBadge()),
            const SizedBox(height: 26),
            Text('Order placed', textAlign: TextAlign.center, style: t.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Thanks, ${account.profile.firstName}. We’ve emailed your receipt to ${account.profile.email}.',
              textAlign: TextAlign.center,
              style: t.bodyMedium,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
              decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(22)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order number', style: t.bodySmall),
                            Text(order.id, style: t.headlineSmall!.copyWith(letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy order number',
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: order.id));
                          if (context.mounted) showSnack(context, 'Order number copied', icon: Icons.content_copy_rounded);
                        },
                        icon: const Icon(Icons.content_copy_rounded, size: 20),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 10, 10, 6), child: Divider()),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        SummaryRow('Estimated delivery', formatDay(order.eta)),
                        SummaryRow('Items', '${plural(order.itemCount, 'item')} · ${plural(order.storeCount, 'store')}'),
                        SummaryRow('Deliver to', order.address.line1),
                        SummaryRow('Paid', moneyExact(order.total)),
                        SummaryRow('Payment', order.payment.title),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Shipping from', style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _ThumbStrip(order: order),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => context.go('$home/account/orders/${order.id}'),
              child: const Text('Track order'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.go(home),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: KavoColors.line)),
              child: const Text('Continue shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        width: 136,
        height: 136,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.brandSoft, shape: BoxShape.circle),
        child: Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            color: p.brand,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: p.brand.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
        ),
      ),
    );
  }
}

/// Each line's photo with its store chip underneath.
class _ThumbStrip extends StatelessWidget {
  const _ThumbStrip({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: order.lines.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final line = order.lines[i];
          return Column(
            children: [
              SizedBox(width: 78, height: 78, child: KavoImage(line.product.image, radius: BorderRadius.circular(16))),
              const SizedBox(height: 8),
              StoreChip(line.product.store),
            ],
          );
        },
      ),
    );
  }
}
