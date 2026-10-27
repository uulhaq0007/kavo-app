import 'package:flutter/foundation.dart';

import '../data/catalog.dart';
import '../models/product.dart';

/// Saved products across all three stores, newest first.
class WishlistController extends ChangeNotifier {
  WishlistController([Iterable<String> ids = const []]) : _ids = [...ids];

  final List<String> _ids;

  int get count => _ids.length;
  List<Product> get products => [for (final id in _ids) ?productById(id)];

  bool contains(Product product) => _ids.contains(product.id);

  /// Returns true when the product is now saved.
  bool toggle(Product product) {
    final saved = !_ids.remove(product.id);
    if (saved) _ids.insert(0, product.id);
    notifyListeners();
    return saved;
  }
}
