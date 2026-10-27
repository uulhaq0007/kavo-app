import 'package:material_ui/material_ui.dart';

import 'product.dart';

enum ShopSort {
  featured('Featured'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  rating('Top rated'),
  name('Name: A–Z');

  const ShopSort(this.label);

  final String label;

  static ShopSort parse(String? value) =>
      values.firstWhere((s) => s.name == value, orElse: () => ShopSort.featured);

  List<Product> apply(List<Product> products) {
    final list = [...products];
    switch (this) {
      case ShopSort.featured:
        break;
      case ShopSort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ShopSort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ShopSort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case ShopSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }
}

/// Price bounds for a store's slider, rounded out to a friendly step.
class PriceBounds {
  const PriceBounds(this.min, this.max, this.step);

  factory PriceBounds.of(List<Product> products) {
    final prices = products.map((p) => p.price);
    final hi = prices.reduce((a, b) => a > b ? a : b);
    final step = hi > 1000 ? 50.0 : hi > 200 ? 10.0 : 1.0;
    final lo = prices.reduce((a, b) => a < b ? a : b);
    return PriceBounds((lo / step).floor() * step, (hi / step).ceil() * step, step);
  }

  final double min;
  final double max;
  final double step;

  int get divisions => ((max - min) / step).round();
  RangeValues get full => RangeValues(min, max);
}

@immutable
class ShopFilters {
  const ShopFilters({
    this.categories = const {},
    this.price,
    this.minRating = 0,
    this.inStockOnly = false,
    this.onSaleOnly = false,
  });

  /// Reads `cat`, `min`, `max`, `rating`, `stock` and `sale` query parameters,
  /// so any filtered view can be opened straight from a URL.
  factory ShopFilters.fromQuery(Map<String, String> q, PriceBounds bounds) {
    final min = double.tryParse(q['min'] ?? '');
    final max = double.tryParse(q['max'] ?? '');
    return ShopFilters(
      categories: (q['cat'] ?? '').split(',').where((c) => c.trim().isNotEmpty).toSet(),
      price: min == null && max == null
          ? null
          : RangeValues((min ?? bounds.min).clamp(bounds.min, bounds.max), (max ?? bounds.max).clamp(bounds.min, bounds.max)),
      minRating: double.tryParse(q['rating'] ?? '') ?? 0,
      inStockOnly: q['stock'] == '1',
      onSaleOnly: q['sale'] == '1',
    );
  }

  final Set<String> categories;
  final RangeValues? price;
  final double minRating;
  final bool inStockOnly;
  final bool onSaleOnly;

  /// Filters other than category (category has its own chip row).
  int get extraCount => (price != null ? 1 : 0) + (minRating > 0 ? 1 : 0) + (inStockOnly ? 1 : 0) + (onSaleOnly ? 1 : 0);
  int get activeCount => categories.length + extraCount;

  bool matches(Product p) =>
      (categories.isEmpty || categories.contains(p.category)) &&
      (price == null || (p.price >= price!.start && p.price <= price!.end)) &&
      p.rating >= minRating &&
      (!inStockOnly || p.inStock) &&
      (!onSaleOnly || p.onSale);

  ShopFilters copyWith({
    Set<String>? categories,
    RangeValues? price,
    bool clearPrice = false,
    double? minRating,
    bool? inStockOnly,
    bool? onSaleOnly,
  }) => ShopFilters(
    categories: categories ?? this.categories,
    price: clearPrice ? null : price ?? this.price,
    minRating: minRating ?? this.minRating,
    inStockOnly: inStockOnly ?? this.inStockOnly,
    onSaleOnly: onSaleOnly ?? this.onSaleOnly,
  );
}
