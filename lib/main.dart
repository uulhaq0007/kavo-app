import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Jost ships in assets/fonts, so the app never fetches fonts at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Jost'], license);
  });

  // Building a theme registers every Jost weight it uses. Waiting for them
  // means no text (chips especially) is ever measured with a fallback font.
  buildKavoTheme(KavoPalette.fashion);
  await GoogleFonts.pendingFonts();

  runApp(const KavoApp());
}
