import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Deep Emerald & Gold Accents
  static const Color primary = Color(0xFF2D5F5D); // Deep emerald - luxury, trust
  static const Color primaryLight = Color(0xFF3D7F7D);
  static const Color primaryDark = Color(0xFF1D3F3D);

  // Accent Colors - Warm Gold & Cool Blue
  static const Color accent = Color(0xFFD4AF37); // Luxurious gold
  static const Color accentBlue = Color(0xFF5B9BD5); // Professional blue

  // Background & Surfaces - Rich Dark Theme
  static const Color background = Color(0xFF0A0E0F); // Deep charcoal
  static const Color surface = Color(0xFF141A1C); // Elevated surface
  static const Color surfaceVariant = Color(0xFF1E2628); // Card backgrounds

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5); // Off-white
  static const Color textSecondary = Color(0xFFB8C5CB); // Muted blue-gray
  static const Color textTertiary = Color(0xFF6B7880); // Subtle gray

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color error = Color(0xFFEF4444); // Warm red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Status Colors for Applications
  static const Color statusPending = Color(0xFFFBBF24); // Amber
  static const Color statusAccepted = Color(0xFF10B981); // Green
  static const Color statusRejected = Color(0xFFEF4444); // Red

  // Border & Dividers
  static const Color border = Color(0xFF2D3748);
  static const Color divider = Color(0xFF1E2628);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D5F5D),
      Color(0xFF1D4F4D),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFB8960E),
    ],
  );

  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D5F5D),
      Color(0xFF1D3F3D),
      Color(0xFF0A0E0F),
    ],
  );

  // Glass Morphism
  static Color glass = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: accent.withOpacity(0.4),
      blurRadius: 40,
      spreadRadius: 2,
    ),
  ];

  static Color get accentPink => const Color(0xFFF472B6);

  static Color get accentPurple => const Color(0xFF9370DB);
}