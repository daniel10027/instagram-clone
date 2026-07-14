import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Styles de texte partages dans toute l'application, afin de garder
/// une identite typographique coherente sans dupliquer les valeurs.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle wordmark = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.5,
    color: AppColors.primaryText,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    color: AppColors.primaryText,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryText,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.linkBlue,
  );

  static const TextStyle footerText = TextStyle(
    fontSize: 13,
    color: AppColors.secondaryText,
  );

  static const TextStyle footerAction = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.actionBlue,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const TextStyle username = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
}
