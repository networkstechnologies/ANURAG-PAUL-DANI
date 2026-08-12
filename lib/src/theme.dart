import 'package:flutter/material.dart';

/// Account Keeping — teal & gold identity.
class AkTheme {
  static const Color teal900 = Color(0xFF063B3E);
  static const Color teal800 = Color(0xFF0B5F59);
  static const Color teal600 = Color(0xFF08706F);
  static const Color teal500 = Color(0xFF0F8F7F);
  static const Color navy = Color(0xFF102033);
  static const Color gold = Color(0xFFF2B035);
  static const Color goldDark = Color(0xFFC98A1E);
  static const Color bg = Color(0xFFF4F8F7);
  static const Color soft = Color(0xFFE7F7F4);
  static const Color line = Color(0xFFCADAD7);
  static const Color green = Color(0xFF15A86A);
  static const Color danger = Color(0xFFE11D48);
  static const Color muted = Color(0xFF5B6B74);

  static ThemeData get theme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: teal600,
        secondary: gold,
        surface: Colors.white,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: teal800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(bodyColor: navy, displayColor: navy),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        border: _border(line),
        enabledBorder: _border(line),
        focusedBorder: _border(teal500, 2),
        labelStyle: const TextStyle(color: teal800, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: soft,
      ),
    );
  }

  static OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: c, width: w),
      );

  static ButtonStyle get goldButton => ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: navy,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal900, teal600],
  );

  static BoxDecoration get card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
      );
}
