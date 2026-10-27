# Kavo — mobile app

The Flutter companion to the [Kavo storefront](https://github.com/uulhaq0007/kavo-store): one app, three
storefronts (fashion, grocery and furniture) and one shared cart. Switching store re-themes the whole
app. Every widget is written once against a theme built from a palette object, so the same screens
render in red, green or brown.

All data is sample data in Dart. There is no backend.

## Features

- **Three store homes** (`/fashion`, `/grocery`, `/furniture`), each with its own layout and content
  from the web project: hero, categories, promos and a product grid with *All / On sale / New / Best
  sellers* chips. A segmented store switcher in the header slides between them while
  `MaterialApp` animates the palette.
- **Shop** with category chips, sort (featured, price, rating, name) and a filter sheet (category,
  price range, rating, in stock, on sale). Filters can be set from the URL, e.g.
  `/fashion/shop?filters=1&cat=Shoes&min=90&max=200`.
- **Product detail**: price and old price, rating, stock, variants (size and colour for fashion, weight
  for grocery, finish for furniture) with price deltas, a quantity stepper, add to cart, share (copies
  a link), save, back-in-stock alerts for sold-out items and related products.
- **Shared cart**: lines from every store tagged with their store, quantity steppers, swipe or tap to
  remove with undo, a free-shipping meter (free over $150), promo codes from the furniture flat sales
  (`DESK30`, `SEAT10`) and totals.
- **Checkout** in three steps (address, payment, review), with add-address and add-card forms,
  standard or express delivery, then an **order-placed** screen with the order number. The order is
  filed in the account history and the cart empties.
- **Search** across the current store, with matches from the other two stores listed below,
  popular and recent searches.
- **Saved** items across all stores, filterable by store.
- **Account**: profile (editable), order history with status, **order detail** with a tracker and
  *Buy again*, saved addresses, payment methods, notification settings, storefront picker and help.

## Run it

```sh
flutter pub get
flutter run            # on a device or simulator
flutter run -d chrome  # in the browser
```

Add `?shot=1` to any web URL to simulate an iPhone's safe areas (used for portfolio screenshots).

## Structure

```
lib/
  main.dart            URL strategy, bundled fonts, runApp
  app.dart             controllers, MaterialApp.router, theme follows the URL's store
  router.dart          go_router routes, page transitions, navigation helpers
  theme.dart           KavoPalette (ThemeExtension) per store + buildKavoTheme(palette)
  data/                stores (from the web project), catalog, seed data
  models/              store, product, cart/order/account types, filters, formatting
  state/               CartController, WishlistController, AccountController, AppScope
  screens/             home (one file per store), shop, product, cart, checkout,
                       order placed, saved, search, account, order detail
  widgets/             product card and grid, header and switcher, nav bar, sheets, filter sheet
assets/
  images/{fa,gr,fu}/   photos from the web project, resized to 800px max
  fonts/               Jost (OFL), bundled so the app never fetches fonts at runtime
```

State is plain `ChangeNotifier`s exposed through `InheritedNotifier`, placed above the router so the
cart, wishlist and orders survive every navigation, including switching store.

Packages: `go_router`, `google_fonts`, `material_ui` (the Material library both of those build on).
