import 'package:material_ui/material_ui.dart';

import '../models/product.dart';
import '../models/store.dart';

// Names, categories, prices, badges and photos come from the web storefront.
// Ratings, stock, copy and variants are sample data for the app.

const _fa = 'assets/images/fa';
const _gr = 'assets/images/gr';
const _fu = 'assets/images/fu';

const _apparelSizes = VariantGroup('Size', [
  VariantOption('XS'),
  VariantOption('S'),
  VariantOption('M'),
  VariantOption('L'),
  VariantOption('XL'),
]);

const _shoeSizes = VariantGroup('Size', [
  VariantOption('UK 5'),
  VariantOption('UK 6'),
  VariantOption('UK 7'),
  VariantOption('UK 8'),
  VariantOption('UK 9'),
  VariantOption('UK 10'),
]);

const _woodFinish = VariantGroup('Finish', [
  VariantOption('Natural Oak', swatch: Color(0xFFD9BC8C)),
  VariantOption('Smoked Walnut', swatch: Color(0xFF6B4A33)),
  VariantOption('Black Ash', swatch: Color(0xFF2B2A28)),
]);

const _black = Color(0xFF1C1C1C);
const _oatLinen = Color(0xFFDCD2C1);
const _forestVelvet = Color(0xFF2F5D50);
const _rustVelvet = Color(0xFFB4532A);

const List<Product> catalog = [
  // ------------------------------------------------------------------ FASHION
  Product(
    id: 'cable-knit-poncho',
    store: StoreKey.fashion,
    name: 'Cable Knit Poncho',
    category: 'Women Wear',
    price: 128,
    was: 160,
    badge: 'Sale',
    image: '$_fa/p1.jpg',
    rating: 4.8,
    reviews: 126,
    stock: 14,
    description:
        'A loose, open-stitch poncho knitted from a soft cotton and wool blend. The fringed hem and dropped '
        'V-neck sit well over a slim knit or a plain tee, and it folds small enough to live in a tote.',
    highlights: ['60% cotton, 40% wool', 'Hand wash cold, dry flat', 'Model is 5′9″ and wears S'],
    variants: [
      _apparelSizes,
      VariantGroup('Colour', [
        VariantOption('Oat', swatch: Color(0xFFE9DFCC)),
        VariantOption('Charcoal', swatch: Color(0xFF4A4A4A)),
        VariantOption('Rose', swatch: Color(0xFFD9A5A0)),
      ]),
    ],
  ),
  Product(
    id: 'structured-top-handle-bag',
    store: StoreKey.fashion,
    name: 'Structured Top Handle Bag',
    category: 'Bags',
    price: 245,
    image: '$_fa/p2.jpg',
    rating: 4.9,
    reviews: 88,
    stock: 6,
    description:
        'A compact top-handle bag in pebbled leather, with a structured base that keeps its shape. A turn-lock '
        'front, a detachable crossbody strap and a slip pocket for your phone take it from desk to dinner.',
    highlights: ['Full-grain pebbled leather', 'Detachable 120 cm strap', '24 × 18 × 11 cm'],
    variants: [
      VariantGroup('Colour', [
        VariantOption('Teal', swatch: Color(0xFF1F6F78)),
        VariantOption('Black', swatch: _black),
        VariantOption('Tan', swatch: Color(0xFFB07A4F)),
      ]),
    ],
  ),
  Product(
    id: 'court-runner-low',
    store: StoreKey.fashion,
    name: 'Court Runner Low',
    category: 'Shoes',
    price: 96,
    was: 120,
    badge: 'Sale',
    image: '$_fa/p3.jpg',
    rating: 4.6,
    reviews: 214,
    stock: 22,
    description:
        'A low-profile court runner with a cushioned midsole and a grippy rubber cupsole. The mesh and suede '
        'upper breathes on long days, and a padded collar keeps the heel locked in.',
    highlights: ['Suede and mesh upper', 'EVA cushioned midsole', 'True to size'],
    variants: [
      _shoeSizes,
      VariantGroup('Colour', [
        VariantOption('Coral', swatch: Color(0xFFF0643C)),
        VariantOption('Chalk', swatch: Color(0xFFEDEBE6)),
      ]),
    ],
  ),
  Product(
    id: 'velocity-trainer-red',
    store: StoreKey.fashion,
    name: 'Velocity Trainer Red',
    category: 'Shoes',
    price: 110,
    badge: 'New',
    image: '$_fa/p4.jpg',
    rating: 4.7,
    reviews: 64,
    stock: 18,
    description:
        'A knit-upper trainer that is light enough for a 10k and soft enough for the commute. The one-piece sock '
        'fit hugs the foot, and a foam midsole gives back energy with every stride.',
    highlights: ['Engineered knit upper', 'Responsive foam midsole', 'Weighs 240 g in UK 8'],
    variants: [
      _shoeSizes,
      VariantGroup('Colour', [
        VariantOption('Crimson', swatch: Color(0xFFB3202A)),
        VariantOption('Black', swatch: _black),
      ]),
    ],
  ),
  Product(
    id: 'suede-derby-tan',
    store: StoreKey.fashion,
    name: 'Suede Derby Tan',
    category: 'Shoes',
    price: 155,
    image: '$_fa/p5.jpg',
    rating: 4.8,
    reviews: 97,
    stock: 9,
    description:
        'A relaxed suede derby on a chunky cupsole. Open lacing gives a forgiving fit across the instep, and the '
        'leather lining softens the more you wear it.',
    highlights: ['Water-repellent suede', 'Leather lining', 'Stitched rubber cupsole'],
    variants: [
      _shoeSizes,
      VariantGroup('Colour', [
        VariantOption('Tan', swatch: Color(0xFFB07A4F)),
        VariantOption('Chocolate', swatch: Color(0xFF5B3A29)),
      ]),
    ],
  ),
  Product(
    id: 'field-smartwatch-42mm',
    store: StoreKey.fashion,
    name: 'Field Smartwatch 42mm',
    category: 'Watches',
    price: 219,
    image: '$_fa/p6.jpg',
    rating: 4.5,
    reviews: 152,
    stock: 11,
    description:
        'An aluminium smartwatch with an always-on display, heart-rate and sleep tracking, and up to six days of '
        'battery. Swim-proof to 50 m, with quick-release straps that swap in seconds.',
    highlights: ['1.4″ AMOLED display', 'Six-day battery', 'Water resistant to 50 m'],
    variants: [
      VariantGroup('Size', [VariantOption('42 mm'), VariantOption('46 mm', priceDelta: 30)]),
      VariantGroup('Colour', [
        VariantOption('Graphite', swatch: Color(0xFF3A3A3C)),
        VariantOption('Silver', swatch: Color(0xFFC9CCD1)),
      ]),
    ],
  ),
  Product(
    id: 'loafer-green-calf',
    store: StoreKey.fashion,
    name: 'Loafer Green Calf',
    category: 'Shoes',
    price: 175,
    image: '$_fa/p7.jpg',
    rating: 4.7,
    reviews: 41,
    stock: 0,
    description:
        'A Blake-stitched loafer in brushed suede calf, finished with a hand-punched apron and a stacked leather '
        'heel. Slim enough for tailoring, easy enough for weekends.',
    highlights: ['Brushed suede calf', 'Blake-stitched leather sole', 'Runs half a size large'],
    variants: [
      _shoeSizes,
      VariantGroup('Colour', [
        VariantOption('Sage', swatch: Color(0xFF5E9C8F)),
        VariantOption('Black', swatch: _black),
      ]),
    ],
  ),
  Product(
    id: 'everyday-cotton-set',
    store: StoreKey.fashion,
    name: 'Everyday Cotton Set',
    category: 'Shirts & Knits',
    price: 84,
    was: 99,
    badge: 'Sale',
    image: '$_fa/cat-shirts.jpg',
    rating: 4.6,
    reviews: 73,
    stock: 30,
    description:
        'Two heavyweight cotton tees, garment-dyed for a soft, lived-in hand. Pre-washed so they keep their '
        'shape, with a boxy fit that works tucked or loose.',
    highlights: ['220 gsm organic cotton', 'Pre-washed, no shrinkage', 'Pack of two'],
    variants: [
      _apparelSizes,
      VariantGroup('Colour', [
        VariantOption('Sage', swatch: Color(0xFF7C9A86)),
        VariantOption('Stone', swatch: Color(0xFFD8D2C4)),
        VariantOption('Navy', swatch: Color(0xFF1F2A44)),
      ]),
    ],
  ),
  Product(
    id: 'freshwater-pearl-pendant',
    store: StoreKey.fashion,
    name: 'Freshwater Pearl Pendant',
    category: 'Jewellery',
    price: 68,
    badge: 'New',
    image: '$_fa/cat-jewellery.jpg',
    rating: 4.9,
    reviews: 38,
    stock: 25,
    description:
        'A single freshwater pearl on a fine gold-filled chain. Light enough to wear every day and easy to layer '
        'with a longer chain.',
    highlights: ['14k gold-filled chain', 'Hypoallergenic', 'Arrives in a gift box'],
    variants: [
      VariantGroup('Size', [VariantOption('16″'), VariantOption('18″'), VariantOption('20″', priceDelta: 6)]),
      VariantGroup('Colour', [
        VariantOption('Gold', swatch: Color(0xFFD4AF37)),
        VariantOption('Silver', swatch: Color(0xFFC4C6CA)),
      ]),
    ],
  ),
  Product(
    id: 'orbit-sport-watch',
    store: StoreKey.fashion,
    name: 'Orbit Sport Watch',
    category: 'Watches',
    price: 189,
    image: '$_fa/cat-watches.jpg',
    rating: 4.4,
    reviews: 58,
    stock: 4,
    description:
        'A lightweight sport watch with built-in GPS, interval timers and a face you can read in full sun. The '
        'vented silicone strap stays comfortable through sweaty sessions.',
    highlights: ['Built-in GPS', 'Interval and tempo timers', '10-day battery'],
    variants: [
      VariantGroup('Size', [VariantOption('40 mm'), VariantOption('44 mm', priceDelta: 20)]),
      VariantGroup('Colour', [
        VariantOption('Black', swatch: _black),
        VariantOption('Olive', swatch: Color(0xFF5B6B3A)),
      ]),
    ],
  ),

  // ------------------------------------------------------------------ GROCERY
  Product(
    id: 'rainbow-grain-bowl',
    store: StoreKey.grocery,
    name: 'Rainbow Grain Bowl',
    category: 'Deli & Ready',
    price: 8.5,
    badge: 'New',
    image: '$_gr/p1.jpg',
    rating: 4.7,
    reviews: 312,
    stock: 40,
    description:
        'Quinoa and brown rice topped with roast salmon, a soft-boiled egg, red cabbage, sweetcorn and cucumber, '
        'with a ginger and sesame dressing on the side. Made fresh every morning in our Bellhaven kitchen.',
    highlights: ['Ready to eat, no heating needed', 'Best within 2 days', 'Contains fish, egg and sesame'],
    variants: [
      VariantGroup('Weight', [VariantOption('350 g'), VariantOption('500 g', priceDelta: 2.5)]),
    ],
  ),
  Product(
    id: 'atlantic-salmon-fillet',
    store: StoreKey.grocery,
    name: 'Atlantic Salmon Fillet',
    category: 'Meat & Fish',
    price: 14.2,
    was: 17,
    badge: 'Sale',
    image: '$_gr/p2.jpg',
    rating: 4.8,
    reviews: 189,
    stock: 26,
    description:
        'Skin-on Atlantic salmon fillets, pin-boned and responsibly farmed in Norwegian fjords. Rich, buttery '
        'and ready to pan-fry in eight minutes.',
    highlights: ['ASC certified', 'Pin-boned, skin on', 'Keep chilled, use within 3 days'],
    variants: [
      VariantGroup('Weight', [VariantOption('280 g'), VariantOption('560 g', priceDelta: 13.4)]),
    ],
  ),
  Product(
    id: 'roasted-squash-soup',
    store: StoreKey.grocery,
    name: 'Roasted Squash Soup',
    category: 'Deli & Ready',
    price: 5.9,
    image: '$_gr/p3.jpg',
    rating: 4.6,
    reviews: 141,
    stock: 34,
    description:
        'Butternut squash slow-roasted with garlic and thyme, blended with coconut milk and finished with '
        'toasted pumpkin seeds. Vegan, and ready in three minutes on the hob.',
    highlights: ['Vegan and gluten free', 'Serves two', 'Freezes for up to 3 months'],
    variants: [
      VariantGroup('Weight', [VariantOption('600 g'), VariantOption('1 kg', priceDelta: 3.4)]),
    ],
  ),
  Product(
    id: 'citrus-garden-salad',
    store: StoreKey.grocery,
    name: 'Citrus Garden Salad',
    category: 'Fresh Vegetables',
    price: 6.4,
    image: '$_gr/p4.jpg',
    rating: 4.5,
    reviews: 97,
    stock: 18,
    description:
        'Baby spinach, red onion, shaved carrot and toasted seeds with a bright orange and mustard vinaigrette. '
        'Washed, ready and packed the morning it ships.',
    highlights: ['Washed and ready to eat', 'Dressing packed separately', 'Vegetarian'],
    variants: [
      VariantGroup('Weight', [VariantOption('250 g'), VariantOption('500 g', priceDelta: 4.6)]),
    ],
  ),
  Product(
    id: 'whole-milk-2l',
    store: StoreKey.grocery,
    name: 'Whole Milk 2L',
    category: 'Milk & Cream',
    price: 3.1,
    image: '$_gr/p5.jpg',
    rating: 4.9,
    reviews: 428,
    stock: 60,
    description:
        'Whole milk from grass-fed herds on three family farms within 60 miles of Bellhaven. Gently pasteurised '
        'and never homogenised, so the cream rises to the top.',
    highlights: ['Grass-fed, local farms', 'Non-homogenised', 'Returnable glass bottle'],
    variants: [
      VariantGroup('Weight', [VariantOption('2 L'), VariantOption('2 × 2 L', priceDelta: 2.8)]),
    ],
  ),
  Product(
    id: 'buttermilk-pancake-mix',
    store: StoreKey.grocery,
    name: 'Buttermilk Pancake Mix',
    category: 'Bread & Bakery',
    price: 4.75,
    was: 6,
    badge: 'Sale',
    image: '$_gr/p6.jpg',
    rating: 4.7,
    reviews: 203,
    stock: 45,
    description:
        'Stone-ground flour, malted buttermilk and a touch of vanilla. Add an egg and water for a stack of twelve '
        'tall, fluffy pancakes.',
    highlights: ['Makes 12 pancakes per 500 g', 'No palm oil', 'Just add egg and water'],
    variants: [
      VariantGroup('Weight', [VariantOption('500 g'), VariantOption('1 kg', priceDelta: 3.9)]),
    ],
  ),
  Product(
    id: 'seasonal-veg-box',
    store: StoreKey.grocery,
    name: 'Seasonal Veg Box',
    category: 'Fresh Vegetables',
    price: 22,
    badge: 'Best',
    image: '$_gr/p7.jpg',
    rating: 4.8,
    reviews: 534,
    stock: 15,
    description:
        'Eight to ten varieties of whatever is best this week, picked by our growers the morning it ships. This '
        'week: vine tomatoes, rainbow chard, avocados, chickpeas, sweet potatoes and red cabbage.',
    highlights: ['8–10 seasonal varieties', 'Grown within 60 miles', 'Recipe card in every box'],
    variants: [
      VariantGroup('Weight', [VariantOption('4 kg'), VariantOption('7 kg', priceDelta: 12)]),
    ],
  ),
  Product(
    id: 'breakfast-fruit-crate',
    store: StoreKey.grocery,
    name: 'Breakfast Fruit Crate',
    category: 'Fresh Fruit',
    price: 18.5,
    image: '$_gr/p8.jpg',
    rating: 4.6,
    reviews: 87,
    stock: 0,
    description:
        'A crate of breakfast-ready fruit: bananas, berries, kiwi, mango and citrus. Enough for a week of bowls '
        'and smoothies for two.',
    highlights: ['Ripe and ready this week', 'Plastic-free crate', 'Serves two for a week'],
    variants: [
      VariantGroup('Weight', [VariantOption('3 kg'), VariantOption('5 kg', priceDelta: 9)]),
    ],
  ),
  Product(
    id: 'grain-free-puppy-kibble',
    store: StoreKey.grocery,
    name: 'Grain-Free Puppy Kibble',
    category: 'Pet Supplies',
    price: 16.9,
    image: '$_gr/cat-pet.jpg',
    rating: 4.7,
    reviews: 66,
    stock: 20,
    description:
        'Grain-free kibble for puppies up to 12 months, made with free-range chicken, sweet potato and salmon '
        'oil for a glossy coat. Small, crunchy pieces sized for little mouths.',
    highlights: ['Free-range chicken first', 'No wheat, corn or soy', 'Resealable bag'],
    variants: [
      VariantGroup('Weight', [VariantOption('2 kg'), VariantOption('6 kg', priceDelta: 24)]),
    ],
  ),

  // ---------------------------------------------------------------- FURNITURE
  Product(
    id: 'linden-three-seater',
    store: StoreKey.furniture,
    name: 'Linden Three Seater',
    category: 'Sofas',
    price: 1240,
    was: 1490,
    badge: 'Sale',
    image: '$_fu/p1.jpg',
    rating: 4.8,
    reviews: 64,
    stock: 5,
    description:
        'A deep three-seater with a kiln-dried hardwood frame, sinuous springs and feather-wrapped seat '
        'cushions. Shown in forest velvet on tapered solid oak legs.',
    highlights: ['W 214 × D 92 × H 84 cm', 'Removable, dry-clean covers', '10-year frame guarantee'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Forest Velvet', swatch: _forestVelvet),
        VariantOption('Rust Velvet', swatch: _rustVelvet),
        VariantOption('Oat Linen', swatch: _oatLinen),
      ]),
    ],
  ),
  Product(
    id: 'marlow-two-seater',
    store: StoreKey.furniture,
    name: 'Marlow Two Seater',
    category: 'Sofas',
    price: 980,
    image: '$_fu/p2.jpg',
    rating: 4.7,
    reviews: 38,
    stock: 7,
    description:
        'A compact two-seater with a high, supportive back and track arms, sized for apartments and reading '
        'corners. Shown in rust velvet.',
    highlights: ['W 168 × D 88 × H 86 cm', 'Fits through a 76 cm door', 'Pocket-sprung seat'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Rust Velvet', swatch: _rustVelvet),
        VariantOption('Forest Velvet', swatch: _forestVelvet),
        VariantOption('Oat Linen', swatch: _oatLinen),
      ]),
    ],
  ),
  Product(
    id: 'ash-perch-stool',
    store: StoreKey.furniture,
    name: 'Ash Perch Stool',
    category: 'Chairs',
    price: 145,
    badge: 'New',
    image: '$_fu/p3.jpg',
    rating: 4.6,
    reviews: 52,
    stock: 20,
    description:
        'A counter-height stool in solid ash with a dished seat and a footrest at just the right height. '
        'Delivered fully assembled.',
    highlights: ['Seat height 65 cm', 'Solid ash', 'Arrives assembled'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Natural Ash', swatch: Color(0xFFE3D3B8)),
        VariantOption('Smoked Ash', swatch: Color(0xFF6B5444)),
        VariantOption('Black Ash', swatch: Color(0xFF2B2A28)),
      ]),
    ],
  ),
  Product(
    id: 'tufted-accent-chair',
    store: StoreKey.furniture,
    name: 'Tufted Accent Chair',
    category: 'Chairs',
    price: 620,
    image: '$_fu/p4.jpg',
    rating: 4.8,
    reviews: 29,
    stock: 0,
    description:
        'A scallop-backed accent chair with deep button tufting and turned white legs. Sized for a bedroom '
        'corner or a dressing table.',
    highlights: ['W 68 × D 64 × H 82 cm', 'Hand-tufted back', 'Solid beech legs'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Ivory Bouclé', swatch: Color(0xFFEFEBE3)),
        VariantOption('Dove Grey', swatch: Color(0xFFB9B7B2)),
      ]),
    ],
  ),
  Product(
    id: 'moulded-dining-chair',
    store: StoreKey.furniture,
    name: 'Moulded Dining Chair',
    category: 'Chairs',
    price: 210,
    was: 260,
    badge: 'Sale',
    image: '$_fu/p5.jpg',
    rating: 4.5,
    reviews: 117,
    stock: 32,
    description:
        'A moulded shell with a padded seat on solid beech legs. Stacks two high and wipes clean after dinner.',
    highlights: ['Seat height 46 cm', 'Solid beech legs', 'Sold individually'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Black', swatch: _black),
        VariantOption('Chalk', swatch: Color(0xFFEDEBE6)),
        VariantOption('Sage', swatch: Color(0xFF8FA89A)),
      ]),
    ],
  ),
  Product(
    id: 'saffron-lounge-chair',
    store: StoreKey.furniture,
    name: 'Saffron Lounge Chair',
    category: 'Chairs',
    price: 540,
    image: '$_fu/p6.jpg',
    rating: 4.7,
    reviews: 44,
    stock: 9,
    description:
        'A mid-century lounge chair with a sculpted wingback, a tight seat and solid walnut legs. The saffron '
        'wool blend brings warmth to a neutral room.',
    highlights: ['W 74 × D 80 × H 98 cm', 'Wool-blend upholstery', 'Solid walnut legs'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Saffron', swatch: Color(0xFFE0A526)),
        VariantOption('Teal', swatch: Color(0xFF2F6F73)),
        VariantOption('Oat Linen', swatch: _oatLinen),
      ]),
    ],
  ),
  Product(
    id: 'bramley-armchair',
    store: StoreKey.furniture,
    name: 'Bramley Armchair',
    category: 'Chairs',
    price: 495,
    badge: 'Best',
    image: '$_fu/p7.jpg',
    rating: 4.9,
    reviews: 156,
    stock: 12,
    description:
        'A generous wing armchair with feather-blend cushions on a solid oak base. Pair it with the matching '
        'footstool for the full Sunday-papers setup.',
    highlights: ['W 80 × D 86 × H 102 cm', 'Feather-blend cushions', 'Solid oak base'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Mustard', swatch: Color(0xFFD6A136)),
        VariantOption('Oat Linen', swatch: _oatLinen),
        VariantOption('Forest Velvet', swatch: _forestVelvet),
      ]),
    ],
  ),
  Product(
    id: 'wall-shelf-system',
    store: StoreKey.furniture,
    name: 'Wall Shelf System',
    category: 'Storage',
    price: 320,
    image: '$_fu/p8.jpg',
    rating: 4.6,
    reviews: 71,
    stock: 14,
    description:
        'A modular wall system of floating shelves and cabinets in oak veneer. Mix the units to fit an alcove or '
        'a whole wall; every fixing is included.',
    highlights: ['7 modular pieces', 'Holds 25 kg per shelf', 'Fixings included'],
    variants: [_woodFinish],
  ),
  Product(
    id: 'hollis-linen-bed',
    store: StoreKey.furniture,
    name: 'Hollis Linen Bed',
    category: 'Beds',
    price: 1150,
    image: '$_fu/cat-beds.jpg',
    rating: 4.8,
    reviews: 47,
    stock: 6,
    description:
        'An upholstered king bed with a soft, low headboard in washed linen and a sprung slatted base that needs '
        'no box spring.',
    highlights: ['King, 150 × 200 cm mattress', 'Washed linen cover', 'Sprung slatted base'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Sage Linen', swatch: Color(0xFF9DAA94)),
        VariantOption('Oat Linen', swatch: _oatLinen),
        VariantOption('Slate Linen', swatch: Color(0xFF6E737A)),
      ]),
    ],
  ),
  Product(
    id: 'atelier-work-desk',
    store: StoreKey.furniture,
    name: 'Atelier Work Desk',
    category: 'Desks',
    price: 690,
    image: '$_fu/cat-desks.jpg',
    rating: 4.6,
    reviews: 33,
    stock: 10,
    description:
        'A solid oak work desk with a cable tray hidden under the top and a slim drawer for everyday clutter. '
        'At 140 cm wide there is room for two screens.',
    highlights: ['W 140 × D 70 × H 75 cm', 'Hidden cable tray', 'Solid oak top'],
    variants: [_woodFinish],
  ),
  Product(
    id: 'retro-instant-camera',
    store: StoreKey.furniture,
    name: 'Retro Instant Camera',
    category: 'Decor',
    price: 129,
    image: '$_fu/cat-decor.jpg',
    rating: 4.5,
    reviews: 82,
    stock: 16,
    description:
        'A working instant camera in a retro two-tone body, as happy on a bookshelf as it is at a party. Prints '
        'credit-card-sized photos in about ninety seconds.',
    highlights: ['Prints in about 90 seconds', 'Built-in flash', 'Rechargeable battery'],
    variants: [
      VariantGroup('Finish', [
        VariantOption('Cream', swatch: Color(0xFFEDE7DA)),
        VariantOption('Black', swatch: _black),
      ]),
    ],
  ),
];

final Map<String, Product> _byId = {for (final p in catalog) p.id: p};

Product? productById(String id) => _byId[id];

List<Product> productsOf(StoreKey store) => [
  for (final p in catalog)
    if (p.store == store) p,
];

/// Product categories in the order the store's category rail lists them.
List<String> categoriesOf(StoreKey store) {
  final present = {for (final p in productsOf(store)) p.category};
  return [
    for (final p in productsOf(store))
      if (present.remove(p.category)) p.category,
  ];
}

/// Same category first, then the rest of the store.
List<Product> relatedTo(Product product, {int count = 6}) {
  final others = productsOf(product.store).where((p) => p.id != product.id).toList()
    ..sort((a, b) => (b.category == product.category ? 1 : 0).compareTo(a.category == product.category ? 1 : 0));
  return others.take(count).toList();
}

/// Matches every word of the query against name, category, store and
/// description. Name and category matches rank above description-only ones.
List<Product> search(String query, {StoreKey? store}) {
  final words = query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return const [];
  bool hits(String text) => words.every(text.toLowerCase().contains);

  final strong = <Product>[];
  final weak = <Product>[];
  for (final p in catalog) {
    if (store != null && p.store != store) continue;
    if (hits('${p.name} ${p.category} ${p.store.label}')) {
      strong.add(p);
    } else if (hits('${p.name} ${p.category} ${p.store.label} ${p.description}')) {
      weak.add(p);
    }
  }
  return [...strong, ...weak];
}
