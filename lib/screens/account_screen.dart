import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/stores.dart';
import '../models/commerce.dart';
import '../models/format.dart';
import '../models/store.dart';
import '../router.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/basics.dart';
import '../widgets/chrome.dart';
import '../widgets/sheets.dart';
import 'order_detail_screen.dart';

/// `/:store/account`. Profile, order history and settings.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final account = context.account;
    final t = context.text;
    final key = store.key;

    return Scaffold(
      appBar: TabHeader(
        title: 'Account',
        subtitle: Text('Member since ${account.profile.memberSince}', style: t.bodySmall!.copyWith(fontSize: 13)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          _ProfileCard(store: key),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: Text('Your orders', style: t.titleLarge!.copyWith(fontSize: 19))),
              Text(plural(account.orders.length, 'order'), style: t.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          for (final order in account.orders) ...[
            _OrderCard(order: order, onTap: () => context.openOrder(key, order.id)),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Text('Settings', style: t.titleLarge!.copyWith(fontSize: 19)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: KavoColors.line),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.place_outlined,
                  title: 'Saved addresses',
                  subtitle: '${account.address.label} · ${account.address.line1}',
                  onTap: () => showAddressesSheet(context),
                ),
                _MenuTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Payment methods',
                  subtitle: account.payment.title,
                  onTap: () => showPaymentsSheet(context),
                ),
                _MenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: '${account.prefs.values.where((v) => v).length} of ${account.prefs.length} turned on',
                  onTap: () => showNotificationPrefsSheet(context),
                ),
                _MenuTile(
                  icon: Icons.storefront_outlined,
                  title: 'Storefront',
                  subtitle: '${key.label} · ${store.tagline}',
                  trailing: PaletteSwatch(store: key),
                  onTap: () => showStorefrontSheet(context, key),
                ),
                _MenuTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Help & support',
                  subtitle: Brand.phone,
                  onTap: () => showHelpSheet(context),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Kavo · ${Brand.address}',
            textAlign: TextAlign.center,
            style: t.bodySmall,
          ),
        ],
      ),
      bottomNavigationBar: KavoNavBar(store: key, current: KavoTab.account),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.store});

  final StoreKey store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    final account = context.account;
    final profile = account.profile;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.brand, Color.lerp(p.brandDark, KavoColors.ink, 0.35)!],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(profile.initials, style: t.titleLarge!.copyWith(color: p.brandDark)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: t.titleLarge!.copyWith(color: Colors.white)),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                onPressed: () => showEditProfileSheet(context),
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 21),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                _Stat(value: '${account.orders.length}', label: 'Orders', onTap: null),
                const SizedBox(width: 10),
                _Stat(
                  value: '${context.wishlist.count}',
                  label: 'Saved',
                  onTap: () => context.go('/${store.name}/saved'),
                ),
                const SizedBox(width: 10),
                _Stat(
                  value: '${context.cart.count}',
                  label: 'In cart',
                  onTap: () => context.go('/${store.name}/cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Expanded(
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Column(
              children: [
                Text(value, style: t.titleLarge!.copyWith(color: Colors.white, height: 1.1)),
                Text(label, style: t.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final thumbs = order.lines.take(3).toList();
    final extra = order.lines.length - thumbs.length;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: KavoColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.id, style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          '${formatDate(order.placedAt)} · ${plural(order.itemCount, 'item')}',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final line in thumbs) ...[
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: KavoImage(line.product.image, radius: BorderRadius.circular(12)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (extra > 0)
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(12)),
                      child: Text('+$extra', style: t.labelMedium!.copyWith(color: KavoColors.ink)),
                    ),
                  const Spacer(),
                  Text(moneyExact(order.total), style: t.titleMedium),
                  const Icon(Icons.chevron_right_rounded, color: KavoColors.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: KavoColors.line)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: p.brand),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            const Icon(Icons.chevron_right_rounded, color: KavoColors.body),
          ],
        ),
      ),
    );
  }
}
