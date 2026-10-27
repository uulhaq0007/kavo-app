import 'package:material_ui/material_ui.dart';

import '../models/format.dart';
import '../models/product.dart';
import '../models/shop_filters.dart';
import '../theme.dart';
import 'sheets.dart';

/// Opens the shop's filter sheet and resolves to the applied filters, or null
/// when dismissed.
Future<ShopFilters?> showFilterSheet(
  BuildContext context, {
  required ShopFilters initial,
  required List<Product> products,
  required List<String> categories,
}) {
  return showKavoSheet<ShopFilters>(
    context,
    (_) => FilterSheet(initial: initial, products: products, categories: categories),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial, required this.products, required this.categories});

  final ShopFilters initial;
  final List<Product> products;
  final List<String> categories;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ShopFilters _f = widget.initial;
  late final PriceBounds _bounds = PriceBounds.of(widget.products);

  static const _ratings = [0.0, 4.0, 4.5, 4.8];

  int get _matches => widget.products.where(_f.matches).length;

  void _set(ShopFilters f) => setState(() => _f = f);

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final p = context.palette;
    final range = _f.price ?? _bounds.full;
    final count = _matches;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.86),
      child: KavoSheet(
        title: 'Filters',
        subtitle: '${plural(count, 'product')} match',
        trailing: TextButton(
          onPressed: _f.activeCount == 0 ? null : () => _set(const ShopFilters()),
          child: const Text('Reset all'),
        ),
        footer: FilledButton(
          onPressed: count == 0 ? null : () => Navigator.of(context).pop(_f),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              count == 0 ? 'No products match' : 'Show ${plural(count, 'product')}',
              key: ValueKey(count),
            ),
          ),
        ),
        children: [
          _Section(
            title: 'Category',
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final c in widget.categories)
                  FilterChip(
                    label: Text(c),
                    selected: _f.categories.contains(c),
                    side: BorderSide(color: _f.categories.contains(c) ? p.brand : KavoColors.line),
                    backgroundColor: Colors.white,
                    onSelected: (on) => _set(
                      _f.copyWith(categories: on ? {..._f.categories, c} : ({..._f.categories}..remove(c))),
                    ),
                  ),
              ],
            ),
          ),
          _Section(
            title: 'Price range',
            trailing: Text(
              '${money(range.start)} – ${money(range.end)}',
              style: t.titleSmall!.copyWith(color: p.brandDark, fontWeight: FontWeight.w600),
            ),
            child: Column(
              children: [
                RangeSlider(
                  values: range,
                  min: _bounds.min,
                  max: _bounds.max,
                  divisions: _bounds.divisions,
                  onChanged: (v) => _set(
                    v.start <= _bounds.min && v.end >= _bounds.max ? _f.copyWith(clearPrice: true) : _f.copyWith(price: v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _PriceBox(label: 'Min', value: money(range.start)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(width: 14, height: 1.5, color: KavoColors.body),
                      ),
                      _PriceBox(label: 'Max', value: money(range.end)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Rating',
            child: Row(
              children: [
                for (final r in _ratings) ...[
                  Expanded(
                    child: ChoiceChip(
                      selected: _f.minRating == r,
                      onSelected: (_) => _set(_f.copyWith(minRating: r)),
                      side: BorderSide(color: _f.minRating == r ? p.brand : KavoColors.line),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      labelPadding: EdgeInsets.zero,
                      label: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (r > 0) ...[
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: _f.minRating == r ? Colors.white : p.brand,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(r == 0 ? 'Any' : '${r.toStringAsFixed(1)}+'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (r != _ratings.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          _Section(
            title: 'Availability',
            child: Column(
              children: [
                _SwitchRow(
                  title: 'In stock only',
                  subtitle: 'Hide sold-out pieces',
                  value: _f.inStockOnly,
                  onChanged: (v) => _set(_f.copyWith(inStockOnly: v)),
                ),
                _SwitchRow(
                  title: 'On sale',
                  subtitle: 'Only show reduced prices',
                  value: _f.onSaleOnly,
                  onChanged: (v) => _set(_f.copyWith(onSaleOnly: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: context.text.titleMedium)),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: KavoColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.text.bodySmall!.copyWith(fontSize: 11.5)),
            Text(value, style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  Text(subtitle, style: context.text.bodySmall),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
