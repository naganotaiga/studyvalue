/// StudyValue - 世界最高水準のデザインシステム
/// Figma、Apple Human Interface Guidelines に準拠
library;

import 'package:flutter/cupertino.dart';

class AppTheme {
  // == カラーパレット ==
  // Primary Colors
  static const primaryBlue = Color(0xFF3B82F6);      // Blue-500
  static const primaryIndigo = Color(0xFF6366F1);    // Indigo-500  
  static const primaryPurple = Color(0xFF8B5CF6);    // Purple-500
  
  // Success & Growth
  static const successGreen = Color(0xFF10B981);     // Emerald-500
  static const lightGreen = Color(0xFF34D399);       // Emerald-400
  static const darkGreen = Color(0xFF059669);        // Emerald-600
  
  // Warning & Energy
  static const warningOrange = Color(0xFFF59E0B);    // Amber-500
  static const lightOrange = Color(0xFFFBBF24);      // Amber-400
  static const darkOrange = Color(0xFFD97706);       // Amber-600
  
  // Error & Urgency
  static const errorRed = Color(0xFFEF4444);         // Red-500
  static const lightRed = Color(0xFFF87171);         // Red-400
  static const darkRed = Color(0xFFDC2626);          // Red-600
  
  // Neutral Colors
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
  
  // == グラデーション ==
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryIndigo, primaryPurple],
  );
  
  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, successGreen],
  );
  
  static const warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightOrange, warningOrange],
  );
  
  static const errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightRed, errorRed],
  );
  
  // == タイポグラフィ ==
  // Display - ヒーローセクション用
  static const displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.02,
    height: 1.0,
    color: gray900,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    height: 1.1,
    color: gray900,
  );
  
  // Heading - セクションタイトル用
  static const headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.2,
    color: gray900,
  );
  
  static const headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    height: 1.2,
    color: gray900,
  );
  
  static const headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: gray900,
  );
  
  // Body - 本文用
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: gray700,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: gray700,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: gray600,
  );
  
  // Label - ラベル・キャプション用
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: gray900,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: gray700,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: gray500,
  );
  
  // == スペーシング ==
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // == 角丸 ==
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusFull = 9999.0;
  
  // == 影 ==
  static const shadowSmall = [
    BoxShadow(
      color: Color(0x0F000000), // black with 6% opacity
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x1A000000), // black with 10% opacity  
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  
  static const shadowMedium = [
    BoxShadow(
      color: Color(0x0F000000), // black with 6% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A000000), // black with 10% opacity
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  
  static const shadowLarge = [
    BoxShadow(
      color: Color(0x0F000000), // black with 6% opacity
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x14000000), // black with 8% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const shadowXLarge = [
    BoxShadow(
      color: Color(0x14000000), // black with 8% opacity
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x1A000000), // black with 10% opacity
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
  
  // == アニメーション ==
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveSnappy = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
}