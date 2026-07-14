import 'package:flutter/material.dart';
import '../core/app_text_styles.dart';

/// Bloc-titre de l'ecran de connexion. Reprend l'esprit de la maquette
/// (typographie italique marquee, centree) sans reproduire le logotype
/// exact de la marque, qui est une oeuvre protegee.
class AppWordmark extends StatelessWidget {
  final String text;

  const AppWordmark({super.key, this.text = 'Instagram'});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.wordmark,
      textAlign: TextAlign.center,
    );
  }
}
