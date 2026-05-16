import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryGold = Color(0xFFB8860B);
  static const Color secondaryNavy = Color(0xFF0F172A);
  static const Color tertiaryIvory = Color(0xFFFFFFF0);
  static const Color background = Color(0xFFFFFFF0);
  static const Color surfaceDefault = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFCA8A04);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0369A1);

  static const Color categoryStrategy = Color(0xFFB8860B);
  static const Color categoryFamily = Color(0xFFC2410C);
  static const Color categoryParty = Color(0xFF15803D);
  static const Color categoryCards = Color(0xFF0369A1);
  static const Color categoryCoop = Color(0xFF0369A1);
  static const Color categoryWord = Color(0xFF15803D);

  static Color textPrimary = secondaryNavy;
  static Color textSecondary = secondaryNavy.withValues(alpha: 0.55);
  static Color textMuted = secondaryNavy.withValues(alpha: 0.4);
  static Color divider = secondaryNavy.withValues(alpha: 0.08);
  static Color border = secondaryNavy.withValues(alpha: 0.1);
  static Color cardShadow = secondaryNavy.withValues(alpha: 0.06);

  static Color categoryFor(String category) {
    switch (category.toLowerCase()) {
      case 'strategy':
        return categoryStrategy;
      case 'family':
        return categoryFamily;
      case 'party':
        return categoryParty;
      case 'cards':
        return categoryCards;
      case 'co-op':
      case 'cooperative':
        return categoryCoop;
      case 'word':
        return categoryWord;
      default:
        return primaryGold;
    }
  }
}
