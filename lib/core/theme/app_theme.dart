import 'package:material_ui/material_ui.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final brand = AppTokens.brandOf(brightness);
    final surface = AppTokens.surfaceOf(brightness);
    final surfaceAlt = AppTokens.surfaceAltOf(brightness);
    final ink = AppTokens.inkOf(brightness);
    final inkSecondary = AppTokens.inkSecondaryOf(brightness);
    final hairline = AppTokens.hairlineOf(brightness);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
    ).copyWith(
      primary: brand,
      onPrimary: brightness == Brightness.dark ? AppTokens.ink : Colors.white,
      primaryContainer: AppTokens.brandSelectOf(brightness),
      onPrimaryContainer: brand,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: surfaceAlt,
      onSurfaceVariant: inkSecondary,
      error: AppTokens.danger,
      outline: hairline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      dividerColor: hairline,
      textTheme: _textTheme(ink),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: AppTokens.title,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        iconTheme: IconThemeData(color: ink, size: 20),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radiusLgBorder,
          side: BorderSide(color: hairline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
          vertical: AppTokens.spaceMd,
        ),
        hintStyle: TextStyle(fontSize: AppTokens.body, color: inkSecondary),
        border: _inputBorder(hairline),
        enabledBorder: _inputBorder(hairline),
        focusedBorder: _inputBorder(brand),
        prefixIconColor: inkSecondary,
        suffixIconColor: inkSecondary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: brightness == Brightness.dark
              ? AppTokens.ink
              : Colors.white,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radiusMdBorder,
          ),
          textStyle: const TextStyle(
            fontSize: AppTokens.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(fontSize: AppTokens.body),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: inkSecondary,
          minimumSize: const Size(44, 44),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: AppTokens.caption, color: inkSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? brand : inkSecondary,
            size: 20,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radiusXlBorder,
        ),
        titleTextStyle: TextStyle(
          fontSize: AppTokens.title,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radiusMdBorder,
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppTokens.spaceMd,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceLg,
        ),
        iconColor: inkSecondary,
        titleTextStyle: TextStyle(
          fontSize: AppTokens.emphasis,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: AppTokens.sm,
          color: inkSecondary,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: AppTokens.radiusMdBorder,
        borderSide: BorderSide(color: color),
      );

  static TextTheme _textTheme(Color ink) => TextTheme(
        bodyLarge: TextStyle(fontSize: AppTokens.body, color: ink),
        bodyMedium: TextStyle(fontSize: AppTokens.body, color: ink),
        bodySmall: TextStyle(fontSize: AppTokens.sm, color: ink),
        titleLarge: TextStyle(
          fontSize: AppTokens.title,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: AppTokens.emphasis,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        titleSmall: TextStyle(fontSize: AppTokens.body, color: ink),
        headlineSmall: TextStyle(
          fontSize: AppTokens.heading,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
          color: ink,
        ),
        displaySmall: TextStyle(
          fontSize: AppTokens.display,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
          color: ink,
        ),
        labelSmall: const TextStyle(fontSize: AppTokens.caption),
      );
}
