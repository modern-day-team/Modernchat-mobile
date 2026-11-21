import 'package:material_ui/material_ui.dart';

abstract final class AppTokens {
  static const brand = Color(0xFF0052D9);
  static const brandDark = Color(0xFF7CB8FF);
  static const brandSelect = Color(0x290052D9);
  static const brandSelectDark = Color(0x477CB8FF);
  static const ink = Color(0xFF0F172A);
  static const inkDark = Color(0xFFE6EAF2);
  static const inkSecondary = Color(0xB30F172A);
  static const inkSecondaryDark = Color(0xB3E6EAF2);
  static const inkFaint = Color(0xFF6B6B6B);
  static const inkFaintDark = Color(0xFFA8A8A8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF17191F);
  static const surfaceAlt = Color(0xFFF5F7FA);
  static const surfaceAltDark = Color(0xFF1F222B);
  static const hairline = Color(0x140F172A);
  static const hairlineDark = Color(0x14FFFFFF);
  static const danger = Color(0xFFD64949);
  static const success = Color(0xFF2BA471);

  static const caption = 11.0;
  static const sm = 12.0;
  static const body = 13.0;
  static const emphasis = 14.0;
  static const title = 16.0;
  static const heading = 20.0;
  static const display = 26.0;

  static const spaceXs = 4.0;
  static const spaceSm = 8.0;
  static const spaceMd = 12.0;
  static const spaceLg = 16.0;
  static const spaceXl = 20.0;
  static const spaceXxl = 24.0;
  static const spaceXxxl = 32.0;

  static const radiusSm = 6.0;
  static const radiusMd = 10.0;
  static const radiusLg = 14.0;
  static const radiusXl = 20.0;
  static const radiusPill = 999.0;

  static const durInstant = Duration(milliseconds: 120);
  static const durBase = Duration(milliseconds: 200);
  static const durSlow = Duration(milliseconds: 280);
  static const easeOut = Cubic(0.22, 1, 0.36, 1);
  static const easeInOut = Cubic(0.4, 0, 0.2, 1);
  static const easeSpring = Cubic(0.34, 1.56, 0.64, 1);

  static BorderRadius get radiusSmBorder => BorderRadius.circular(radiusSm);
  static BorderRadius get radiusMdBorder => BorderRadius.circular(radiusMd);
  static BorderRadius get radiusLgBorder => BorderRadius.circular(radiusLg);
  static BorderRadius get radiusXlBorder => BorderRadius.circular(radiusXl);
  static BorderRadius get pillBorder => BorderRadius.circular(radiusPill);

  static Color brandOf(Brightness brightness) =>
      brightness == Brightness.dark ? brandDark : brand;
  static Color surfaceOf(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surface;
  static Color surfaceAltOf(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceAltDark : surfaceAlt;
  static Color inkOf(Brightness brightness) =>
      brightness == Brightness.dark ? inkDark : ink;
  static Color inkSecondaryOf(Brightness brightness) =>
      brightness == Brightness.dark ? inkSecondaryDark : inkSecondary;
  static Color inkFaintOf(Brightness brightness) =>
      brightness == Brightness.dark ? inkFaintDark : inkFaint;
  static Color hairlineOf(Brightness brightness) =>
      brightness == Brightness.dark ? hairlineDark : hairline;
  static Color brandSelectOf(Brightness brightness) =>
      brightness == Brightness.dark ? brandSelectDark : brandSelect;
}
