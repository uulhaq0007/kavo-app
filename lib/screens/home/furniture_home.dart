import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/catalog.dart';
import '../../models/format.dart';
import '../../models/store.dart';
import '../../router.dart';
import '../../theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/product_card.dart';
import 'home_parts.dart';

/// Furniture: split hero on the circle motif, flat-sale cards with promo codes
/// and live countdowns, "Featured Items", rooms and a wide closing banner.
class FurnitureHome extends StatefulWidget {
  const FurnitureHome({super.key, required this.store});

  final Store store;

  @override
  State<FurnitureHome> createState() => _FurnitureHomeState();
}

class _FurnitureHomeState extends State<FurnitureHome> {
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
          child: PromoCarousel(
            height: 222,
            count: store.promos.length,
            itemBuilder: (context, i) => _FlatSaleCard(store: store, promo: store.promos[i]),
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
        SliverToBoxAdapter(
          child: SectionHeader(
            title: store.railTitle,
            subtitle: store.railSub,
            onAction: () => context.openShop(store.key),
          ),
        ),
        SliverToBoxAdapter(child: CategoryTileRail(store: store, size: 138, overlay: true)),
        homeGap,
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(child: _WideBanner(store: store)),
        ),
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
      child: Container(
        decoration: BoxDecoration(color: p.heroTint, borderRadius: BorderRadius.circular(26)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -110,
              top: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), shape: BoxShape.circle),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.eyebrow.toUpperCase(),
                    style: t.titleSmall!.copyWith(
                      color: KavoColors.ink.withValues(alpha: 0.65),
                      letterSpacing: 3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(hero.title.toUpperCase(), style: t.displaySmall!.copyWith(fontSize: 42, height: 1)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: '${hero.priceLabel} ',
                            style: t.bodyLarge!.copyWith(color: KavoColors.body),
                            children: [
                              TextSpan(
                                text: money(hero.price),
                                style: t.titleLarge!.copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.openShop(store.key),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          hero.cta.toUpperCase(),
                          style: t.labelMedium!.copyWith(letterSpacing: 1.4, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 1.45,
                    child: KavoImage(hero.image, radius: BorderRadius.circular(18), alignment: const Alignment(0, 0.3)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlatSaleCard extends StatelessWidget {
  const _FlatSaleCard({required this.store, required this.promo});

  final Store store;
  final StorePromo promo;

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: promo.code!));
    if (!context.mounted) return;
    showSnack(context, '${promo.code} copied. Paste it in your cart.', icon: Icons.content_copy_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.text;
    return Container(
      decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 128,
            child: KavoImage(promo.image),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 140, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.kicker.toUpperCase(),
                  style: t.labelSmall!.copyWith(color: p.brand, letterSpacing: 1.1, fontSize: 10.5),
                ),
                const SizedBox(height: 4),
                Text(promo.title, style: t.headlineSmall!.copyWith(fontSize: 23)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _copyCode(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Text.rich(
                    TextSpan(
                      text: 'Code ',
                      style: t.bodySmall!.copyWith(fontSize: 13),
                      children: [
                        TextSpan(
                          text: promo.code,
                          style: t.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontSize: 13.5,
                          ),
                        ),
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(Icons.content_copy_rounded, size: 13, color: KavoColors.body),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Countdown(hours: promo.endsInHours ?? 72),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () => openPromo(context, store.key, promo),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      promo.cta.toUpperCase(),
                      style: t.labelSmall!.copyWith(letterSpacing: 1.2, fontSize: 11.5),
                    ),
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

/// Live d / h / m / s boxes counting down to a fixed offset from first build,
/// so the digits always move.
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.hours});

  final int hours;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late final DateTime _end = DateTime.now().add(Duration(hours: widget.hours, seconds: -8));
  late Duration _left = _end.difference(DateTime.now());
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final left = _end.difference(DateTime.now());
        _left = left.isNegative ? Duration.zero : left;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _left.inSeconds;
    final parts = [
      ('${s ~/ 86400}', 'd'),
      ('${(s % 86400) ~/ 3600}', 'h'),
      ('${(s % 3600) ~/ 60}', 'm'),
      ('${s % 60}', 's'),
    ];
    return Semantics(
      label: 'Offer ends in ${parts.map((p) => '${p.$1}${p.$2}').join(' ')}',
      child: Row(
        children: [
          for (final (v, u) in parts) ...[
            Container(
              width: 38,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: KavoColors.line),
              ),
              child: Text(
                '$v$u',
                style: context.text.labelMedium!.copyWith(color: KavoColors.ink, fontSize: 12.5),
              ),
            ),
            if (u != 's') const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _WideBanner extends StatelessWidget {
  const _WideBanner({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final banner = store.banner!;
    final t = context.text;
    return Pressable(
      onTap: () => context.openShop(store.key),
      child: SizedBox(
        height: 210,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              KavoImage(banner.image, alignment: const Alignment(0.3, 0)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xD9141414), Color(0x80141414), Color(0x14141414)],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.kicker.toUpperCase(),
                      style: t.labelSmall!.copyWith(color: Colors.white70, letterSpacing: 1.6),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      banner.title.toUpperCase(),
                      style: t.headlineSmall!.copyWith(color: Colors.white, fontSize: 23, height: 1.15),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.openShop(store.key),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: KavoColors.ink,
                        minimumSize: const Size(0, 44),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(banner.cta),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
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
