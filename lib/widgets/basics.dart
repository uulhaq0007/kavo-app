import 'package:material_ui/material_ui.dart';

import '../models/store.dart';
import '../theme.dart';

/// An asset photo on a mist backdrop that fades in once decoded, so a grid
/// never flashes empty boxes.
class KavoImage extends StatelessWidget {
  const KavoImage(
    this.asset, {
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius = BorderRadius.zero,
    this.background = KavoColors.mist,
  });

  final String asset;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius radius;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: background,
        child: Image.asset(
          asset,
          fit: fit,
          alignment: alignment,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, sync) => sync
              ? child
              : AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  child: child,
                ),
        ),
      ),
    );
  }
}

/// Small pill that says which storefront something belongs to, in that
/// store's own colours (whatever the current theme is).
class StoreChip extends StatelessWidget {
  const StoreChip(this.store, {super.key, this.onDark = false});

  final StoreKey store;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final p = KavoPalette.of(store);
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
      decoration: BoxDecoration(
        color: onDark ? Colors.white : p.brandSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            store.label,
            style: context.text.labelSmall!.copyWith(color: p.brandDark, letterSpacing: 0.3, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.action = 'See all', this.onAction});

  final String title;
  final String? subtitle;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: context.text.titleLarge!.copyWith(fontSize: 19, letterSpacing: 0.3),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: context.text.bodySmall!.copyWith(fontSize: 13)),
                ],
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(action),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  const StarRating(this.rating, {super.key, this.size = 15});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = context.palette.brand;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star_rounded
                : rating >= i - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: brand,
          ),
      ],
    );
  }
}

/// − qty + in a rounded outline.
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
    this.compact = false,
  });

  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final h = compact ? 34.0 : 54.0;
    Widget button(IconData icon, VoidCallback? onTap, String label) => SizedBox(
      width: h,
      height: h,
      child: IconButton(
        onPressed: onTap,
        tooltip: label,
        padding: EdgeInsets.zero,
        iconSize: compact ? 16 : 20,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          foregroundColor: KavoColors.ink,
          disabledForegroundColor: KavoColors.line,
        ),
      ),
    );

    return Container(
      height: h,
      decoration: BoxDecoration(
        border: Border.all(color: KavoColors.line),
        borderRadius: BorderRadius.circular(compact ? 99 : context.palette.buttonRadius.clamp(0, 27)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove_rounded, onMinus, 'Decrease'),
          SizedBox(
            width: compact ? 22 : 28,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600, fontSize: compact ? 14 : 16),
            ),
          ),
          button(Icons.add_rounded, onPlus, 'Increase'),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(color: context.palette.brandSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: context.palette.brand),
            ),
            const SizedBox(height: 22),
            Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: context.text.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// A white circular button that floats over photos.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.5, color: color ?? KavoColors.ink),
          ),
        ),
      ),
    );
  }
}

/// A bordered, tappable card used for selectable options (addresses, cards,
/// delivery speeds).
class SelectCard extends StatelessWidget {
  const SelectCard({super.key, required this.selected, required this.onTap, required this.child});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.brandSoft.withValues(alpha: 0.55) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? p.brand : KavoColors.line, width: selected ? 1.6 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: SelectDot(selected: selected)),
              const SizedBox(width: 14),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectDot extends StatelessWidget {
  const SelectDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final brand = context.palette.brand;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? brand : const Color(0xFFC9C9CC), width: selected ? 6.5 : 1.6),
      ),
    );
  }
}

/// Label / value row used in order summaries.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.emphasis = false, this.valueColor});

  final String label;
  final String value;
  final bool emphasis;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasis ? t.titleMedium : t.bodyMedium!.copyWith(fontSize: 14.5),
            ),
          ),
          Text(
            value,
            style: emphasis
                ? t.titleLarge!.copyWith(fontSize: 21)
                : t.titleSmall!.copyWith(color: valueColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

void showSnack(BuildContext context, String message, {IconData? icon, String? action, VoidCallback? onAction}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2600),
        content: Row(
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 12)],
            Expanded(child: Text(message)),
          ],
        ),
        action: action == null ? null : SnackBarAction(label: action, onPressed: onAction ?? () {}),
      ),
    );
}
