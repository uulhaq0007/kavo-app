import '../models/commerce.dart';
import 'catalog.dart';

/// Demo state so every screen opens looking lived-in.

CartLine _line(String id, Map<String, String> options, int qty) =>
    CartLine(product: productById(id)!, options: options, qty: qty);

/// One line from each storefront: the cart is shared across all three.
List<CartLine> seedCart() => [
  _line('everyday-cotton-set', {'Size': 'M', 'Colour': 'Sage'}, 1),
  _line('atlantic-salmon-fillet', {'Weight': '280 g'}, 2),
  _line('ash-perch-stool', {'Finish': 'Natural Ash'}, 1),
];

const seedWishlist = [
  'velocity-trainer-red',
  'structured-top-handle-bag',
  'seasonal-veg-box',
  'saffron-lounge-chair',
  'linden-three-seater',
  'freshwater-pearl-pendant',
];

const seedProfile = Profile(
  name: 'Amelia Hart',
  email: 'amelia.hart@example.com',
  phone: '+1 (503) 555 0148',
  memberSince: 'March 2024',
);

const seedAddresses = [
  Address(
    id: 'home',
    label: 'Home',
    name: 'Amelia Hart',
    line1: '24 Juniper Lane',
    line2: 'Apt 3B',
    city: 'Bellhaven, OR 97205',
    phone: '+1 (503) 555 0148',
  ),
  Address(
    id: 'work',
    label: 'Work',
    name: 'Amelia Hart',
    line1: 'Northwind Studio, 410 Alder Street',
    line2: 'Floor 6',
    city: 'Bellhaven, OR 97204',
    phone: '+1 (503) 555 0148',
  ),
];

const seedPayments = [
  PaymentMethod(id: 'visa', brand: CardBrand.visa, last4: '4242', expiry: '08/28', holder: 'Amelia Hart'),
  PaymentMethod(id: 'mc', brand: CardBrand.mastercard, last4: '8210', expiry: '11/27', holder: 'Amelia Hart'),
  PaymentMethod(id: 'cash', brand: CardBrand.cash),
];

List<Order> seedOrders() => [
  Order(
    id: 'KV-25230',
    placedAt: DateTime(2026, 10, 26, 9, 14),
    eta: DateTime(2026, 10, 29),
    status: OrderStatus.processing,
    lines: [
      _line('seasonal-veg-box', {'Weight': '4 kg'}, 1),
      _line('whole-milk-2l', {'Weight': '2 L'}, 2),
      _line('roasted-squash-soup', {'Weight': '600 g'}, 2),
    ],
    address: seedAddresses[0],
    payment: seedPayments[0],
    delivery: DeliveryOption.standard,
    subtotal: 40,
    discount: 0,
    shipping: 8,
  ),
  Order(
    id: 'KV-25102',
    placedAt: DateTime(2026, 10, 21, 18, 40),
    eta: DateTime(2026, 10, 30),
    status: OrderStatus.shipped,
    lines: [
      _line('saffron-lounge-chair', {'Finish': 'Saffron'}, 1),
      _line('court-runner-low', {'Size': 'UK 7', 'Colour': 'Coral'}, 1),
    ],
    address: seedAddresses[0],
    payment: seedPayments[1],
    delivery: DeliveryOption.standard,
    subtotal: 636,
    discount: 0,
    shipping: 0,
  ),
  Order(
    id: 'KV-24817',
    placedAt: DateTime(2026, 10, 9, 12, 5),
    eta: DateTime(2026, 10, 12),
    status: OrderStatus.delivered,
    lines: [
      _line('suede-derby-tan', {'Size': 'UK 8', 'Colour': 'Tan'}, 1),
      _line('freshwater-pearl-pendant', {'Size': '18″', 'Colour': 'Gold'}, 1),
    ],
    address: seedAddresses[1],
    payment: seedPayments[0],
    delivery: DeliveryOption.express,
    subtotal: 223,
    discount: 0,
    shipping: 15,
  ),
];

const seedRecentSearches = ['linen', 'oak shelf', 'salmon'];

const seedNotificationPrefs = {
  'Order updates': true,
  'Offers & promo codes': true,
  'Back-in-stock alerts': false,
  'Monthly newsletter': false,
};
