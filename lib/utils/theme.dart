import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF8A80);  // 연한 핑크
  static const Color accentColor = Color(0xFF64B5F6);   // 연한 파랑
  static const Color backgroundColor = Color(0xFFFFF8E1); // 연한 크림색
  static const Color textColor = Color(0xFF424242);     // 어두운 회색
  static const Color secondaryTextColor = Color(0xFF757575); // 중간 회색

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textColor,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.notoSansKrTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansKr(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: GoogleFonts.notoSansKr(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          fontSize: 14,
          color: textColor,
        ),
        bodySmall: GoogleFonts.notoSansKr(
          fontSize: 12,
          color: secondaryTextColor,
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSansKr(
          color: secondaryTextColor.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 3,
        color: Colors.white,
      ),
    );
  }
} 