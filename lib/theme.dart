import 'dart:ui' show lerpDouble;

import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'models/store.dart';

/// Neutrals shared by every storefront (straight from the web project's Tailwind config).
abstract final class KavoColors {
  static const ink = Color(0xFF141414);
  static const body = Color(0xFF74787C);
  static const line = Color(0xFFE3E3E3);
  static const mist = Color(0xFFF6F6F7);
  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFD98A12);
  static const danger = Color(0xFFD93A3A);
}

/// Everything that changes between storefronts. The web app swaps these as CSS
/// custom properties on a wrapper; here they become a [ThemeExtension], so
/// `MaterialApp` can animate between them when the store changes.
@immutable
class KavoPalette extends ThemeExtension<KavoPalette> {
  const KavoPalette({
    required this.brand,
    required this.brandDark,
    required this.brandSoft,
    required this.bar,
    required this.barInk,
    required this.mark,
    required this.heroTint,
    required this.switcherTrack,
    required this.switcherThumb,
    required this.switcherThumbInk,
    required this.announce,
    required this.announceInk,
    required this.buttonRadius,
  });

  final Color brand;
  final Color brandDark;
  final Color brandSoft;

  /// Top bar behind the wordmark and the store switcher.
  final Color bar;
  final Color barInk;

  /// Colour of the cart mark next to the wordmark.
  final Color mark;

  /// Warm backdrop used behind hero art and offer cards.
  final Color heroTint;

  final Color switcherTrack;
  final Color switcherThumb;
  final Color switcherThumbInk;

  final Color announce;
  final Color announceInk;

  /// Fashion is crisp, grocery uses pills, furniture stays near-square.
  final double buttonRadius;

  bool get barIsDark => bar.computeLuminance() < 0.4;

  static const fashion = KavoPalette(
    brand: Color.fromRGBO(229, 62, 62, 1),
    brandDark: Color.fromRGBO(197, 48, 48, 1),
    brandSoft: Color.fromRGBO(254, 240, 240, 1),
    bar: Color.fromRGBO(20, 20, 20, 1),
    barInk: Colors.white,
    mark: Color.fromRGBO(229, 62, 62, 1),
    heroTint: Color(0xFFF4EFEC),
    switcherTrack: Color(0x24FFFFFF),
    switcherThumb: Colors.white,
    switcherThumbInk: KavoColors.ink,
    announce: Color.fromRGBO(254, 240, 240, 1),
    announceInk: Color.fromRGBO(197, 48, 48, 1),
    buttonRadius: 12,
  );

  static const grocery = KavoPalette(
    brand: Color.fromRGBO(103, 176, 46, 1),
    brandDark: Color.fromRGBO(84, 145, 36, 1),
    brandSoft: Color.fromRGBO(240, 248, 235, 1),
    bar: Color.fromRGBO(103, 176, 46, 1),
    barInk: Colors.white,
    mark: Colors.white,
    heroTint: Color(0xFFF3E7DC),
    switcherTrack: Color(0x29000000),
    switcherThumb: Colors.white,
    switcherThumbInk: Color.fromRGBO(84, 145, 36, 1),
    announce: Color.fromRGBO(240, 248, 235, 1),
    announceInk: Color.fromRGBO(84, 145, 36, 1),
    buttonRadius: 999,
  );

  static const furniture = KavoPalette(
    brand: Color.fromRGBO(136, 91, 58, 1),
    brandDark: Color.fromRGBO(111, 73, 45, 1),
    brandSoft: Color.fromRGBO(247, 243, 239, 1),
    bar: Colors.white,
    barInk: KavoColors.ink,
    mark: Color.fromRGBO(136, 91, 58, 1),
    heroTint: Color(0xFFF2EFEA),
    switcherTrack: Color(0xFFF1ECE6),
    switcherThumb: Color.fromRGBO(136, 91, 58, 1),
    switcherThumbInk: Colors.white,
    announce: KavoColors.ink,
    announceInk: Colors.white,
    buttonRadius: 6,
  );

  static KavoPalette of(StoreKey key) => switch (key) {
    StoreKey.fashion => fashion,
    StoreKey.grocery => grocery,
    StoreKey.furniture => furniture,
  };

  @override
  KavoPalette copyWith({Color? brand, Color? brandDark, Color? brandSoft}) => KavoPalette(
    brand: brand ?? this.brand,
    brandDark: brandDark ?? this.brandDark,
    brandSoft: brandSoft ?? this.brandSoft,
    bar: bar,
    barInk: barInk,
    mark: mark,
    heroTint: heroTint,
    switcherTrack: switcherTrack,
    switcherThumb: switcherThumb,
    switcherThumbInk: switcherThumbInk,
    announce: announce,
    announceInk: announceInk,
    buttonRadius: buttonRadius,
  );

  @override
  KavoPalette lerp(KavoPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return KavoPalette(
      brand: c(brand, other.brand),
      brandDark: c(brandDark, other.brandDark),
      brandSoft: c(brandSoft, other.brandSoft),
      bar: c(bar, other.bar),
      barInk: c(barInk, other.barInk),
      mark: c(mark, other.mark),
      heroTint: c(heroTint, other.heroTint),
      switcherTrack: c(switcherTrack, other.switcherTrack),
      switcherThumb: c(switcherThumb, other.switcherThumb),
      switcherThumbInk: c(switcherThumbInk, other.switcherThumbInk),
      announce: c(announce, other.announce),
      announceInk: c(announceInk, other.announceInk),
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t)!,
    );
  }
}

extension KavoThemeContext on BuildContext {
  KavoPalette get palette => Theme.of(this).extension<KavoPalette>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

/// Builds the whole Material theme from one palette. Every widget in the app is
/// written against this theme, so it renders correctly in all three schemes.
ThemeData buildKavoTheme(KavoPalette p) {
  const ink = KavoColors.ink;
  const body = KavoColors.body;

  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: p.brand,
    onPrimary: Colors.white,
    primaryContainer: p.brandSoft,
    onPrimaryContainer: p.brandDark,
    secondary: ink,
    onSecondary: Colors.white,
    secondaryContainer: KavoColors.mist,
    onSecondaryContainer: ink,
    tertiary: p.brandDark,
    onTertiary: Colors.white,
    error: KavoColors.danger,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: ink,
    onSurfaceVariant: body,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFAFAFA),
    surfaceContainer: KavoColors.mist,
    surfaceContainerHigh: const Color(0xFFF0F0F1),
    surfaceContainerHighest: const Color(0xFFEBEBEC),
    outline: const Color(0xFFD4D4D6),
    outlineVariant: KavoColors.line,
    inverseSurface: ink,
    onInverseSurface: Colors.white,
    inversePrimary: p.brandSoft,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final jost = GoogleFonts.jostTextTheme(base.textTheme);
  final text = jost.copyWith(
    displaySmall: jost.displaySmall!.copyWith(fontSize: 34, fontWeight: FontWeight.w600, height: 1.05, color: ink),
    headlineMedium: jost.headlineMedium!.copyWith(fontSize: 28, fontWeight: FontWeight.w600, height: 1.1, color: ink),
    headlineSmall: jost.headlineSmall!.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.15, color: ink),
    titleLarge: jost.titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: ink),
    titleMedium: jost.titleMedium!.copyWith(fontSize: 16.5, fontWeight: FontWeight.w600, height: 1.25, color: ink),
    titleSmall: jost.titleSmall!.copyWith(fontSize: 15, fontWeight: FontWeight.w500, height: 1.25, color: ink),
    bodyLarge: jost.bodyLarge!.copyWith(fontSize: 16, height: 1.55, color: ink),
    bodyMedium: jost.bodyMedium!.copyWith(fontSize: 14.5, height: 1.55, color: body),
    bodySmall: jost.bodySmall!.copyWith(fontSize: 12.5, height: 1.4, color: body),
    labelLarge: jost.labelLarge!.copyWith(fontSize: 15.5, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: jost.labelMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelSmall: jost.labelSmall!.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(p.buttonRadius));
  const buttonSize = Size(0, 54);

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    splashFactory: InkRipple.splashFactory,
    extensions: [p],
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.white,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      titleTextStyle: text.titleLarge,
      iconTheme: const IconThemeData(color: ink, size: 24),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: KavoColors.line,
        disabledForegroundColor: body,
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        side: const BorderSide(color: ink, width: 1.2),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.brand,
        textStyle: text.labelMedium!.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: ink)),
    chipTheme: ChipThemeData(
      backgroundColor: KavoColors.mist,
      selectedColor: p.brand,
      disabledColor: KavoColors.mist,
      labelStyle: text.labelMedium!.copyWith(color: ink, fontSize: 13.5),
      secondaryLabelStyle: text.labelMedium!.copyWith(color: Colors.white, fontSize: 13.5),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 66,
      indicatorColor: p.brandSoft,
      indicatorShape: const StadiumBorder(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelMedium!.copyWith(
          fontSize: 11.5,
          color: states.contains(WidgetState.selected) ? ink : body,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(size: 24, color: states.contains(WidgetState.selected) ? p.brand : body),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Colors.white,
      showDragHandle: true,
      dragHandleColor: Color(0xFFD9D9DB),
      dragHandleSize: Size(40, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: text.bodyMedium!.copyWith(color: Colors.white, fontSize: 14),
      actionTextColor: Color.lerp(p.brand, Colors.white, 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: KavoColors.mist,
      hintStyle: text.bodyMedium!.copyWith(color: body),
      labelStyle: text.bodyMedium,
      floatingLabelStyle: text.bodyMedium!.copyWith(color: p.brandDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.brand, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: KavoColors.danger, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: KavoColors.danger, width: 1.4),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.brand,
      inactiveTrackColor: KavoColors.line,
      thumbColor: p.brand,
      overlayColor: p.brand.withValues(alpha: 0.12),
      trackHeight: 4,
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11, elevation: 2),
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
      tickMarkShape: SliderTickMarkShape.noTickMark,
      showValueIndicator: ShowValueIndicator.never,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.brand : const Color(0xFFDCDCDE),
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.brand, linearTrackColor: Colors.white),
    dividerTheme: const DividerThemeData(color: KavoColors.line, thickness: 1, space: 1),
    badgeTheme: BadgeThemeData(backgroundColor: p.brand, textColor: Colors.white),
    listTileTheme: ListTileThemeData(
      iconColor: ink,
      titleTextStyle: text.titleSmall,
      subtitleTextStyle: text.bodySmall,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: text.titleSmall,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: p.brand,
      collapsedIconColor: body,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.brand,
      selectionColor: p.brand.withValues(alpha: 0.25),
      selectionHandleColor: p.brand,
    ),
  );
}
