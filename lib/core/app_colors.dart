import 'package:flutter/material.dart';

/// Palette de couleurs reprenant fidelement l'identite visuelle
/// de l'interface Instagram (fond blanc, texte noir, bordures grises,
/// bouton d'action bleu).
class AppColors {
  AppColors._();

  static const Color background = Colors.white;
  static const Color primaryText = Color(0xFF262626);
  static const Color secondaryText = Color(0xFF8E8E8E);
  static const Color border = Color(0xFFDBDBDB);
  static const Color inputBackground = Color(0xFFFAFAFA);

  static const Color actionBlue = Color(0xFF0095F6);
  static const Color actionBlueDisabled = Color(0xFFB2DFFC);
  static const Color linkBlue = Color(0xFF00376B);
  static const Color facebookBlue = Color(0xFF385185);

  static const Color error = Color(0xFFED4956);
  static const Color likeRed = Color(0xFFED4956);
  static const Color divider = Color(0xFFEFEFEF);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
