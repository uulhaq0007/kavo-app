import 'package:material_ui/material_ui.dart';

import '../models/store.dart';

/// Brand details, from the web project's `src/data/stores.js`.
abstract final class Brand {
  static const name = 'Kavo';
  static const wordmark = 'KAVO';
  static const phone = '+1 (402) 763 2824';
  static const email = 'help@kavo.example';
  static const address = '18 Marlow Street, Bellhaven, OR 97204';
  static const hours = 'Mon–Sat, 9:00–18:00';
  static const freeShippingOver = 150.0;
  static const standardShipping = 8.0;
  static const expressShipping = 15.0;
}

const _fa = 'assets/images/fa';
const _gr = 'assets/images/gr';
const _fu = 'assets/images/fu';

const fashionStore = Store(
  key: StoreKey.fashion,
  tagline: 'Womenswear, menswear & accessories',
  announce: 'Free shipping on every order over \$150',
  announceIcon: Icons.local_shipping_outlined,
  hero: StoreHero(
    eyebrow: 'Autumn 22 Collection',
    title: 'Super Collection\nFor Women',
    priceLabel: 'From',
    price: 320,
    cta: 'View Collections',
    image: '$_fa/hero.jpg',
  ),
  categories: [
    StoreCategory(name: 'Women Wear', image: '$_fa/cat-women.jpg', count: 42, filter: 'Women Wear'),
    StoreCategory(name: 'Shirts & Knits', image: '$_fa/cat-shirts.jpg', count: 28, filter: 'Shirts & Knits'),
    StoreCategory(name: 'Bag Collection', image: '$_fa/cat-bags.jpg', count: 19, filter: 'Bags'),
    StoreCategory(name: 'Shoes', image: '$_fa/cat-shoes.jpg', count: 36, filter: 'Shoes'),
    StoreCategory(name: 'Watches', image: '$_fa/cat-watches.jpg', count: 14, filter: 'Watches'),
    StoreCategory(name: 'Jewellery', image: '$_fa/cat-jewellery.jpg', count: 23, filter: 'Jewellery'),
  ],
  promos: [
    StorePromo(
      kicker: 'Special 40% off',
      title: 'The Latest Men’s\nTrends This Season',
      image: '$_fa/promo-men.jpg',
      link: PromoLink.onSale,
      cta: 'View Collections',
    ),
    StorePromo(
      kicker: 'New in',
      title: 'Activewear Built\nFor Real Movement',
      image: '$_fa/promo-active.jpg',
      link: PromoLink.category,
      category: 'Shoes',
      cta: 'View Collections',
    ),
    StorePromo(
      kicker: 'In store now',
      title: 'Visit The Bellhaven\nFlagship Floor',
      image: '$_fa/promo-store.jpg',
      link: PromoLink.flagship,
      cta: 'Opening hours',
    ),
  ],
  railTitle: 'Best For Your Categories',
  railSub: '6 categories across 162 products',
  gridTitle: 'Trending This Week',
  gridSub: 'Restocked every Thursday morning.',
  deliveryNote: 'Dispatched the same working day',
  searchHint: 'Search fashion',
  popularSearches: ['Trainer', 'Leather', 'Knit', 'Smartwatch', 'Pearl'],
);

const groceryStore = Store(
  key: StoreKey.grocery,
  tagline: 'Fresh produce, pantry & everyday essentials',
  announce: 'Same-day delivery on orders placed before 2pm',
  announceIcon: Icons.schedule_rounded,
  hero: StoreHero(
    eyebrow: 'Up to 30% off your first \$150 order',
    title: 'Organic Grocery',
    price: 69,
    cta: 'Shop Now',
    image: '$_gr/hero.jpg',
  ),
  sideCard: StorePromo(
    kicker: '−45% offer',
    title: 'With us, you will never\nmiss an ingredient',
    image: '$_gr/side.jpg',
    link: PromoLink.onSale,
  ),
  categories: [
    StoreCategory(name: 'Fresh Vegetables', image: '$_gr/cat-veg.jpg', count: 34, filter: 'Fresh Vegetables'),
    StoreCategory(name: 'Fresh Fruit', image: '$_gr/cat-fruit.jpg', count: 28, filter: 'Fresh Fruit'),
    StoreCategory(name: 'Milk & Cream', image: '$_gr/cat-dairy.jpg', count: 16, filter: 'Milk & Cream'),
    StoreCategory(name: 'Bread & Bakery', image: '$_gr/cat-bakery.jpg', count: 21, filter: 'Bread & Bakery'),
    StoreCategory(name: 'Deli & Ready', image: '$_gr/cat-deli.jpg', count: 12, filter: 'Deli & Ready'),
    StoreCategory(name: 'Pet Supplies', image: '$_gr/cat-pet.jpg', count: 9, filter: 'Pet Supplies'),
  ],
  promos: [
    StorePromo(
      kicker: 'Weekend discount',
      title: 'Feed The Best\nEnergy Booster',
      sub: 'Do not miss the special offer this week',
      image: '$_gr/promo-1.jpg',
      link: PromoLink.category,
      category: 'Deli & Ready',
    ),
    StorePromo(
      kicker: 'Weekend discount',
      title: 'Our Garden Fresh\nVegetables',
      sub: 'Do not miss the special offer this week',
      image: '$_gr/promo-2.jpg',
      link: PromoLink.category,
      category: 'Fresh Vegetables',
    ),
  ],
  railTitle: 'Shop By Aisle',
  railSub: 'Everything picked the morning it ships.',
  gridTitle: 'Fresh This Morning',
  gridSub: 'Picked, packed and out the door the same day.',
  deliveryNote: 'Same-day delivery on orders placed before 2pm',
  searchHint: 'Search fresh produce, dairy & more',
  popularSearches: ['Salmon', 'Veg box', 'Milk', 'Soup', 'Pancake'],
);

const furnitureStore = Store(
  key: StoreKey.furniture,
  tagline: 'Seating, storage & considered home pieces',
  announce: '20% off everything with a minimum spend — sale ends Sunday',
  announceIcon: Icons.sell_outlined,
  hero: StoreHero(
    eyebrow: 'Ready to ship',
    title: 'Home Decor',
    priceLabel: 'From',
    price: 299,
    cta: 'Explore Items',
    image: '$_fu/hero.jpg',
  ),
  categories: [
    StoreCategory(name: 'Sofas', image: '$_fu/cat-sofas.jpg', count: 24, filter: 'Sofas'),
    StoreCategory(name: 'Chairs', image: '$_fu/cat-chairs.jpg', count: 38, filter: 'Chairs'),
    StoreCategory(name: 'Beds', image: '$_fu/cat-beds.jpg', count: 16, filter: 'Beds'),
    StoreCategory(name: 'Desks', image: '$_fu/cat-desks.jpg', count: 12, filter: 'Desks'),
    StoreCategory(name: 'Storage', image: '$_fu/cat-storage.jpg', count: 27, filter: 'Storage'),
    StoreCategory(name: 'Decor', image: '$_fu/cat-decor.jpg', count: 45, filter: 'Decor'),
  ],
  promos: [
    StorePromo(
      kicker: 'Unique office desk',
      title: '30% Flat Sale',
      code: 'DESK30',
      image: '$_fu/promo-1.jpg',
      link: PromoLink.category,
      category: 'Desks',
      cta: 'Start Shopping',
      endsInHours: 72,
    ),
    StorePromo(
      kicker: 'Elegant comfort sofa',
      title: '10% Flat Sale',
      code: 'SEAT10',
      image: '$_fu/promo-2.jpg',
      link: PromoLink.category,
      category: 'Sofas',
      cta: 'Start Shopping',
      endsInHours: 120,
    ),
  ],
  banner: StorePromo(
    kicker: 'The Kavo range',
    title: 'Built To Last,\nPriced To Live With',
    image: '$_fu/banner.jpg',
    cta: 'Shop The Range',
  ),
  railTitle: 'Shop By Room',
  railSub: 'Browse the range by where it goes.',
  gridTitle: 'Featured Items',
  gridSub: 'Made to order, delivered in four to six weeks.',
  deliveryNote: 'Made to order, delivered in four to six weeks',
  searchHint: 'Search sofas, chairs & storage',
  popularSearches: ['Velvet sofa', 'Armchair', 'Oak', 'Desk', 'Shelf'],
);

const stores = {
  StoreKey.fashion: fashionStore,
  StoreKey.grocery: groceryStore,
  StoreKey.furniture: furnitureStore,
};

Store storeOf(StoreKey key) => stores[key]!;

const trustPoints = [
  TrustPoint(
    icon: Icons.local_shipping_outlined,
    title: 'Free Delivery',
    text: 'On orders over \$150, dispatched the same working day.',
  ),
  TrustPoint(
    icon: Icons.autorenew_rounded,
    title: '30 Day Returns',
    text: 'Unused items go back for a full refund, no questions.',
  ),
  TrustPoint(
    icon: Icons.verified_user_outlined,
    title: 'Secure Checkout',
    text: 'Card details are tokenised and never touch our servers.',
  ),
  TrustPoint(
    icon: Icons.headset_mic_outlined,
    title: 'Real Support',
    text: 'A person answers between 9 and 6, Monday to Saturday.',
  ),
];

/// Promo codes printed on the furniture flat-sale banners.
class PromoCode {
  const PromoCode({required this.code, required this.percent, required this.category, required this.store});

  final String code;
  final int percent;
  final String category;
  final StoreKey store;
}

const promoCodes = {
  'DESK30': PromoCode(code: 'DESK30', percent: 30, category: 'Desks', store: StoreKey.furniture),
  'SEAT10': PromoCode(code: 'SEAT10', percent: 10, category: 'Sofas', store: StoreKey.furniture),
};
