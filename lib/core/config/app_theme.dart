import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData defaultThemeData = ThemeData(
    useMaterial3: true,
    //font family
    scaffoldBackgroundColor: AppColors.whiteColor,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    iconTheme: const IconThemeData(opacity: 1),
    fontFamily: 'prompt',
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: AppColors.greyColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none, // Invisible border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none, // Invisible border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none, // Invisible border
      ),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.textBlackColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      /// Button text ========>
      labelLarge: TextStyle(color: AppColors.blackColor, fontSize: 18, fontWeight: FontWeight.w700),

      /// Label for the text Form =====>
      labelMedium: TextStyle(
        color: AppColors.blackColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        color: AppColors.textBlackColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),

      /// ========> Appbar text &&  form hint text
      displayMedium: TextStyle(color: AppColors.textBlackColor, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w400),
      titleMedium: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),

      /// Card title ======>
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    dividerColor: Colors.grey,
    dividerTheme: DividerThemeData(color: Colors.grey),
  );
}
