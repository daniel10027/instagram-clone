import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unsplash_photo.dart';

/// Exception levee lorsque l'appel a l'API Unsplash echoue
/// (cle invalide, quota depasse, probleme reseau...).
class UnsplashException implements Exception {
  final String message;
  const UnsplashException(this.message);

  @override
  String toString() => message;
}

/// Resultat d'une page de photos, avec l'information necessaire pour
/// savoir s'il reste des pages a charger (scroll infini).
class UnsplashPage {
  final List<UnsplashPhoto> photos;
  final int page;
  final bool hasMore;

  const UnsplashPage({
    required this.photos,
    required this.page,
    required this.hasMore,
  });
}

/// Client de l'API Unsplash. Le http.Client est injectable afin de
/// pouvoir etre remplace par un mock dans les tests unitaires, sans
/// effectuer de veritable appel reseau.
class UnsplashService {
  final String accessKey;
  final http.Client _client;
  static const String _baseUrl = 'https://api.unsplash.com';

  UnsplashService({required this.accessKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<UnsplashPage> fetchPhotos({
    required int page,
    int perPage = 15,
  }) async {
    if (accessKey.isEmpty) {
      throw const UnsplashException(
        "La cle d'acces Unsplash (UNSPLASH_ACCESS_KEY) est manquante. "
        'Consultez le README pour la configurer.',
      );
    }

    final uri = Uri.parse('$_baseUrl/photos').replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
      'order_by': 'popular',
    });

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $accessKey',
          'Accept-Version': 'v1',
        },
      );
    } catch (_) {
      throw const UnsplashException(
        'Impossible de contacter Unsplash. Verifiez votre connexion internet.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const UnsplashException(
        "Cle d'acces Unsplash invalide ou quota depasse.",
      );
    }

    if (response.statusCode != 200) {
      throw UnsplashException(
        "Erreur lors de l'appel a l'API Unsplash (statut ${response.statusCode})",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const UnsplashException('Reponse Unsplash invalide.');
    }

    final photos = decoded
        .whereType<Map<String, dynamic>>()
        .map(UnsplashPhoto.fromJson)
        .toList();

    return UnsplashPage(
      photos: photos,
      page: page,
      hasMore: photos.length >= perPage,
    );
  }

  void dispose() => _client.close();
}
