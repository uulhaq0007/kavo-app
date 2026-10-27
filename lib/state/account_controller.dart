import 'package:flutter/foundation.dart';

import '../data/seed.dart';
import '../models/commerce.dart';
import '../models/product.dart';
import 'cart_controller.dart';

/// Profile, addresses, cards, order history and small preferences.
class AccountController extends ChangeNotifier {
  AccountController.seeded()
    : _profile = seedProfile,
      _addresses = [...seedAddresses],
      _payments = [...seedPayments],
      _orders = seedOrders(),
      _prefs = {...seedNotificationPrefs},
      _recentSearches = [...seedRecentSearches];

  Profile _profile;
  final List<Address> _addresses;
  final List<PaymentMethod> _payments;
  final List<Order> _orders;
  final Map<String, bool> _prefs;
  final List<String> _recentSearches;
  final Set<String> _restockAlerts = {};
  String _addressId = 'home';
  String _paymentId = 'visa';
  int _nextOrder = 25318;

  Profile get profile => _profile;
  List<Address> get addresses => List.unmodifiable(_addresses);
  List<PaymentMethod> get payments => List.unmodifiable(_payments);
  List<Order> get orders => List.unmodifiable(_orders);
  Map<String, bool> get prefs => Map.unmodifiable(_prefs);
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  Address get address => _addresses.firstWhere((a) => a.id == _addressId, orElse: () => _addresses.first);
  PaymentMethod get payment => _payments.firstWhere((p) => p.id == _paymentId, orElse: () => _payments.first);

  Order? orderById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  void updateProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  void selectAddress(String id) {
    _addressId = id;
    notifyListeners();
  }

  void selectPayment(String id) {
    _paymentId = id;
    notifyListeners();
  }

  void addAddress(Address address) {
    _addresses.add(address);
    _addressId = address.id;
    notifyListeners();
  }

  void addPayment(PaymentMethod method) {
    // Keep cash on delivery as the last option.
    _payments.insert(_payments.length - 1, method);
    _paymentId = method.id;
    notifyListeners();
  }

  void setPref(String key, bool value) {
    _prefs[key] = value;
    notifyListeners();
  }

  bool wantsRestockAlert(Product product) => _restockAlerts.contains(product.id);

  /// Returns true when an alert is now set.
  bool toggleRestockAlert(Product product) {
    final on = !_restockAlerts.remove(product.id);
    if (on) _restockAlerts.add(product.id);
    notifyListeners();
    return on;
  }

  void rememberSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;
    _recentSearches
      ..remove(q)
      ..insert(0, q);
    if (_recentSearches.length > 6) _recentSearches.removeLast();
    notifyListeners();
  }

  void clearSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  /// Turns the cart into an order, files it at the top of the history and
  /// empties the cart.
  Order placeOrder(CartController cart, DeliveryOption delivery) {
    final now = DateTime.now();
    final order = Order(
      id: 'KV-${_nextOrder++}',
      placedAt: now,
      eta: _addWorkingDays(now, delivery == DeliveryOption.express ? 1 : 3),
      status: OrderStatus.processing,
      lines: cart.lines,
      address: address,
      payment: payment,
      delivery: delivery,
      subtotal: cart.subtotal,
      discount: cart.discount,
      shipping: cart.shippingFor(delivery),
      promoCode: cart.promo?.code,
    );
    _orders.insert(0, order);
    cart.clear();
    notifyListeners();
    return order;
  }

  static DateTime _addWorkingDays(DateTime from, int days) {
    var d = DateTime(from.year, from.month, from.day);
    var left = days;
    while (left > 0) {
      d = d.add(const Duration(days: 1));
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) left--;
    }
    return d;
  }
}
