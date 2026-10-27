import 'package:flutter/foundation.dart';

import '../data/stores.dart';
import '../models/commerce.dart';
import '../models/product.dart';
import '../models/store.dart';

/// The one cart shared by all three storefronts. It lives above the router,
/// so switching store never touches it.
class CartController extends ChangeNotifier {
  CartController([List<CartLine> lines = const []]) : _lines = [...lines];

  final List<CartLine> _lines;
  PromoCode? _promo;

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get count => _lines.fold(0, (n, l) => n + l.qty);
  Set<StoreKey> get stores => {for (final l in _lines) l.product.store};
  PromoCode? get promo => _promo;

  double get subtotal => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  /// Codes only discount the lines they were printed for.
  double get discount {
    final promo = _promo;
    if (promo == null) return 0;
    final eligible = _lines
        .where((l) => l.product.store == promo.store && l.product.category == promo.category)
        .fold<double>(0, (sum, l) => sum + l.lineTotal);
    return (eligible * promo.percent / 100 * 100).roundToDouble() / 100;
  }

  double get merchandise => subtotal - discount;
  bool get freeShipping => merchandise >= Brand.freeShippingOver;
  double get toFreeShipping => (Brand.freeShippingOver - merchandise).clamp(0, Brand.freeShippingOver);
  double get freeShippingProgress => (merchandise / Brand.freeShippingOver).clamp(0, 1);

  double shippingFor(DeliveryOption option) => switch (option) {
    DeliveryOption.express => Brand.expressShipping,
    DeliveryOption.standard => freeShipping || isEmpty ? 0 : Brand.standardShipping,
  };

  double totalFor(DeliveryOption option) => merchandise + shippingFor(option);

  int quantityOf(Product product) =>
      _lines.where((l) => l.product.id == product.id).fold(0, (n, l) => n + l.qty);

  void add(Product product, {Map<String, String>? options, int qty = 1}) {
    final line = CartLine(product: product, options: options ?? product.defaultOptions, qty: qty);
    final i = _lines.indexWhere((l) => l.key == line.key);
    if (i >= 0) {
      _lines[i] = _lines[i].copyWith(qty: _lines[i].qty + qty);
    } else {
      _lines.add(line);
    }
    notifyListeners();
  }

  void increment(CartLine line) => setQty(line, line.qty + 1);

  /// Dropping below one removes the line rather than leaving a zero-qty row.
  void decrement(CartLine line) => line.qty <= 1 ? remove(line) : setQty(line, line.qty - 1);

  void setQty(CartLine line, int qty) {
    final i = _lines.indexWhere((l) => l.key == line.key);
    if (i < 0) return;
    _lines[i] = _lines[i].copyWith(qty: qty.clamp(1, 99));
    notifyListeners();
  }

  /// Returns the index the line held, so an undo can put it back in place.
  int remove(CartLine line) {
    final i = _lines.indexWhere((l) => l.key == line.key);
    if (i >= 0) {
      _lines.removeAt(i);
      notifyListeners();
    }
    return i;
  }

  void restore(CartLine line, int index) {
    _lines.insert(index.clamp(0, _lines.length), line);
    notifyListeners();
  }

  /// Returns an error message, or null when the code was applied.
  String? applyPromo(String raw) {
    final code = raw.trim().toUpperCase();
    final promo = promoCodes[code];
    if (code.isEmpty) return 'Enter a promo code';
    if (promo == null) return '“$code” isn’t a valid code';
    final eligible = _lines.any((l) => l.product.store == promo.store && l.product.category == promo.category);
    if (!eligible) return '$code takes ${promo.percent}% off ${promo.category.toLowerCase()}. Add one to use it.';
    _promo = promo;
    notifyListeners();
    return null;
  }

  void clearPromo() {
    _promo = null;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _promo = null;
    notifyListeners();
  }
}
