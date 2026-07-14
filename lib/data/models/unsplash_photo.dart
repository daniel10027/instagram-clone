/// Represente une photo Unsplash telle qu'utilisee par l'application.
/// Seuls les champs necessaires a l'affichage du feed sont conserves,
/// afin de garder un modele simple et facile a tester.
class UnsplashPhoto {
  final String id;
  final String? description;
  final int width;
  final int height;
  final String thumbUrl;
  final String regularUrl;
  final String photoPageUrl;
  final String authorName;
  final String authorProfileUrl;
  final int likesCount;

  const UnsplashPhoto({
    required this.id,
    required this.description,
    required this.width,
    required this.height,
    required this.thumbUrl,
    required this.regularUrl,
    required this.photoPageUrl,
    required this.authorName,
    required this.authorProfileUrl,
    required this.likesCount,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>? ?? const {};
    final links = json['links'] as Map<String, dynamic>? ?? const {};
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final userLinks = user['links'] as Map<String, dynamic>? ?? const {};

    return UnsplashPhoto(
      id: json['id'] as String? ?? '',
      description:
          (json['description'] ?? json['alt_description']) as String?,
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      thumbUrl: urls['thumb'] as String? ?? '',
      regularUrl: urls['regular'] as String? ?? urls['small'] as String? ?? '',
      photoPageUrl: links['html'] as String? ?? '',
      authorName: user['name'] as String? ?? 'Inconnu',
      authorProfileUrl: userLinks['html'] as String? ?? '',
      likesCount: (json['likes'] as num?)?.toInt() ?? 0,
    );
  }

  /// Ratio hauteur/largeur, utilise pour reserver l'espace correct dans
  /// la liste avant meme que l'image ne soit chargee (evite les sauts
  /// de mise en page pendant le scroll infini).
  double get aspectRatio => height == 0 ? 1.0 : width / height;
}
