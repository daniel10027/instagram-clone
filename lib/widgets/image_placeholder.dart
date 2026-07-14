import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Placeholder affiche pendant le chargement d'une image, ou en cas
/// d'echec de chargement (icone d'image cassee).
class ImagePlaceholder extends StatelessWidget {
  final bool isError;

  const ImagePlaceholder({super.key, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.shimmerBase,
      alignment: Alignment.center,
      child: Icon(
        isError ? Icons.broken_image_outlined : Icons.image_outlined,
        color: AppColors.shimmerHighlight,
        size: 32,
      ),
    );
  }
}
