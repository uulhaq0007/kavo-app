import 'package:material_ui/material_ui.dart';

/// The three storefronts. The enum name doubles as the first URL segment.
enum StoreKey {
  fashion('Fashion'),
  grocery('Grocery'),
  furniture('Furniture');

  const StoreKey(this.label);

  final String label;

  String get path => '/$name';

  static StoreKey? tryParse(String? value) {
    for (final key in values) {
      if (key.name == value) return key;
    }
    return null;
  }
}

class StoreHero {
  const StoreHero({
    required this.eyebrow,
    required this.title,
    required this.price,
    required this.cta,
    required this.image,
    this.priceLabel,
  });

  final String eyebrow;
  final String title;
  final String? priceLabel;
  final double price;
  final String cta;
  final String image;
}

class StoreCategory {
  const StoreCategory({required this.name, required this.image, required this.count, required this.filter});

  final String name;
  final String image;
  final int count;

  /// The product category this tile filters the shop by.
  final String filter;
}

/// Where a promo banner leads when tapped.
enum PromoLink { shop, onSale, category, flagship }

class StorePromo {
  const StorePromo({
    required this.kicker,
    required this.title,
    required this.image,
    this.sub,
    this.code,
    this.link = PromoLink.shop,
    this.category,
    this.cta = 'Shop Now',
    this.endsInHours,
  });

  final String kicker;
  final String title;
  final String? sub;
  final String image;
  final String? code;
  final PromoLink link;
  final String? category;
  final String cta;

  /// Furniture flat sales show a live countdown.
  final int? endsInHours;
}

class TrustPoint {
  const TrustPoint({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;
}

class Store {
  const Store({
    required this.key,
    required this.tagline,
    required this.announce,
    required this.announceIcon,
    required this.hero,
    required this.categories,
    required this.promos,
    required this.railTitle,
    required this.railSub,
    required this.gridTitle,
    required this.gridSub,
    required this.deliveryNote,
    required this.searchHint,
    required this.popularSearches,
    this.sideCard,
    this.banner,
  });

  final StoreKey key;
  final String tagline;
  final String announce;
  final IconData announceIcon;
  final StoreHero hero;
  final List<StoreCategory> categories;
  final List<StorePromo> promos;
  final String railTitle;
  final String railSub;
  final String gridTitle;
  final String gridSub;
  final String deliveryNote;
  final String searchHint;
  final List<String> popularSearches;

  /// Grocery's "never miss an ingredient" card.
  final StorePromo? sideCard;

  /// Furniture's wide closing banner.
  final StorePromo? banner;

  String get label => key.label;
}
