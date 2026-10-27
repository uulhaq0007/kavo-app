import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavo_app/app.dart';
import 'package:kavo_app/theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('boots into fashion, switches store and keeps the shared cart', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Building a theme registers the bundled Jost weights; let them load so the
    // first frame measures text with the real font.
    buildKavoTheme(KavoPalette.fashion);
    await tester.runAsync(GoogleFonts.pendingFonts);

    await tester.pumpWidget(const KavoApp());
    await tester.pumpAndSettle();

    expect(find.text('KAVO'), findsOneWidget);
    expect(find.text('BEST FOR YOUR CATEGORIES'), findsOneWidget);

    // Switching storefront swaps the whole home.
    await tester.tap(find.text('GROCERY'));
    await tester.pumpAndSettle();
    expect(find.text('SHOP BY AISLE'), findsOneWidget);

    // The cart was seeded from all three stores and survives the switch.
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Atlantic Salmon Fillet'), findsOneWidget);
    expect(find.text('Everyday Cotton Set'), findsOneWidget);
    expect(find.text('Ash Perch Stool'), findsOneWidget);
  });
}
