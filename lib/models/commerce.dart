import 'product.dart';

/// One row in the cart (or in a placed order). The same product in two sizes
/// is two lines, so the key includes the chosen options.
class CartLine {
  const CartLine({required this.product, required this.options, required this.qty});

  final Product product;
  final Map<String, String> options;
  final int qty;

  String get key => '${product.id}|${options.entries.map((e) => '${e.key}=${e.value}').join(',')}';
  double get unitPrice => product.priceFor(options);
  double get lineTotal => unitPrice * qty;
  String get optionsLabel => options.values.join(' · ');

  CartLine copyWith({int? qty}) => CartLine(product: product, options: options, qty: qty ?? this.qty);
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.line1,
    required this.city,
    required this.phone,
    this.line2,
  });

  final String id;
  final String label;
  final String name;
  final String line1;
  final String? line2;
  final String city;
  final String phone;

  String get oneLine => [line1, ?line2, city].join(', ');
}

enum CardBrand { visa, mastercard, cash }

class PaymentMethod {
  const PaymentMethod({required this.id, required this.brand, this.last4 = '', this.expiry = '', this.holder = ''});

  final String id;
  final CardBrand brand;
  final String last4;
  final String expiry;
  final String holder;

  bool get isCard => brand != CardBrand.cash;

  String get title => switch (brand) {
    CardBrand.visa => 'Visa •••• $last4',
    CardBrand.mastercard => 'Mastercard •••• $last4',
    CardBrand.cash => 'Cash on delivery',
  };

  String get subtitle => isCard ? 'Expires $expiry' : 'Pay the driver by card or cash';
}

enum DeliveryOption {
  standard('Standard', '3–5 working days'),
  express('Express', 'Next working day');

  const DeliveryOption(this.label, this.window);

  final String label;
  final String window;
}

enum OrderStatus {
  processing('Processing'),
  shipped('On the way'),
  delivered('Delivered');

  const OrderStatus(this.label);

  final String label;
}

class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.eta,
    required this.status,
    required this.lines,
    required this.address,
    required this.payment,
    required this.delivery,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    this.promoCode,
  });

  final String id;
  final DateTime placedAt;
  final DateTime eta;
  final OrderStatus status;
  final List<CartLine> lines;
  final Address address;
  final PaymentMethod payment;
  final DeliveryOption delivery;
  final double subtotal;
  final double discount;
  final double shipping;
  final String? promoCode;

  double get total => subtotal - discount + shipping;
  int get itemCount => lines.fold(0, (n, l) => n + l.qty);
  int get storeCount => lines.map((l) => l.product.store).toSet().length;
}

class Profile {
  const Profile({required this.name, required this.email, required this.phone, required this.memberSince});

  final String name;
  final String email;
  final String phone;
  final String memberSince;

  String get firstName => name.split(' ').first;
  String get initials => name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();

  Profile copyWith({String? name, String? email, String? phone}) => Profile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    memberSince: memberSince,
  );
}
