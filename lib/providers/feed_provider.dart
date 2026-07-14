import 'package:flutter/foundation.dart';
import '../data/models/unsplash_photo.dart';
import '../data/services/likes_store.dart';
import '../data/services/unsplash_service.dart';

/// Gere le feed d'images : chargement paginé (scroll infini), etats de
/// chargement/erreur, et synchronisation des likes avec le stockage
/// persistant cote client.
class FeedProvider extends ChangeNotifier {
  final UnsplashService _unsplashService;
  final LikesStore _likesStore;
  final String username;

  static const int perPage = 15;

  FeedProvider({
    required UnsplashService unsplashService,
    required LikesStore likesStore,
    required this.username,
  })  : _unsplashService = unsplashService,
        _likesStore = likesStore {
    likedPhotoIds = _likesStore.getLikedPhotoIds(username);
  }

  final List<UnsplashPhoto> photos = [];
  late Set<String> likedPhotoIds;

  int _currentPage = 0;
  bool hasMore = true;
  bool isLoadingInitial = false;
  bool isLoadingMore = false;
  String? errorMessage;

  bool isLiked(String photoId) => likedPhotoIds.contains(photoId);

  Future<void> loadInitial() async {
    if (isLoadingInitial) return;

    isLoadingInitial = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _unsplashService.fetchPhotos(page: 1, perPage: perPage);
      photos
        ..clear()
        ..addAll(result.photos);
      _currentPage = 1;
      hasMore = result.hasMore;
    } on UnsplashException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || isLoadingInitial || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _unsplashService.fetchPhotos(page: nextPage, perPage: perPage);

      final existingIds = photos.map((photo) => photo.id).toSet();
      final newPhotos = result.photos.where((photo) => !existingIds.contains(photo.id));

      photos.addAll(newPhotos);
      _currentPage = nextPage;
      hasMore = result.hasMore;
      errorMessage = null;
    } on UnsplashException catch (error) {
      // On garde les photos deja chargees visibles ; seule l'erreur du
      // chargement supplementaire est signalee.
      errorMessage = error.message;
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String photoId) async {
    // Mise a jour optimiste de l'interface, puis persistance.
    final wasLiked = likedPhotoIds.contains(photoId);
    if (wasLiked) {
      likedPhotoIds.remove(photoId);
    } else {
      likedPhotoIds.add(photoId);
    }
    notifyListeners();

    await _likesStore.toggleLike(username, photoId);
  }

  Future<void> retry() => loadInitial();
}
