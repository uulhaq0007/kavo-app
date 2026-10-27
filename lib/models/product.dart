import 'package:material_ui/material_ui.dart';

import 'store.dart';

class VariantOption {
  const VariantOption(this.label, {this.swatch, this.priceDelta = 0});

  final String label;
  final Color? swatch;
  final double priceDelta;
}

/// Size and colour for fashion, weight for grocery, finish for furniture.
class VariantGroup {
  const VariantGroup(this.name, this.options);

  final String name;
  final List<VariantOption> options;

  bool get isSwatch => options.every((o) => o.swatch != null);
}

class Product {
  const Product({
    required this.id,
    required this.store,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.stock,
    required this.description,
    required this.highlights,
    required this.variants,
    this.was,
    this.badge,
  });

  final String id;
  final StoreKey store;
  final String name;
  final String category;
  final double price;
  final double? was;
  final String image;
  final String? badge;
  final double rating;
  final int reviews;
  final int stock;
  final String description;
  final List<String> highlights;
  final List<VariantGroup> variants;

  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 6;
  bool get onSale => was != null;
  bool get isNew => badge == 'New';
  int? get percentOff => was == null ? null : ((1 - price / was!) * 100).round();

  /// The first option of every group, used by quick "add" buttons.
  Map<String, String> get defaultOptions => {for (final g in variants) g.name: g.options.first.label};

  double priceFor(Map<String, String> options) {
    var total = price;
    for (final group in variants) {
      final picked = options[group.name];
      for (final option in group.options) {
        if (option.label == picked) total += option.priceDelta;
      }
    }
    return total;
  }
}
