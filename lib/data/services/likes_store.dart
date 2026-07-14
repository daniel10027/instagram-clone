import 'package:hive/hive.dart';

/// Persiste, cote client, l'ensemble des identifiants de photos "likees"
/// par chaque utilisateur, dans une base cle/valeur embarquee (Hive).
///
/// Hive est utilise comme equivalent a "Level" demande par le cahier des
/// charges : c'est une base NoSQL cle/valeur embarquee, ecrite en Dart pur
/// (donc sans binding natif a compiler, contrairement au module Node
/// "level"), qui persiste les donnees sur le disque de l'appareil et
/// survit aux redemarrages de l'application (voir README).
class LikesStore {
  static const String boxName = 'likes_box';

  final Box<List<dynamic>> _box;

  LikesStore(this._box);

  static Future<LikesStore> open() async {
    final box = await Hive.openBox<List<dynamic>>(boxName);
    return LikesStore(box);
  }

  String _keyFor(String username) => 'likes:$username';

  /// Retourne l'ensemble des identifiants de photos likees par l'utilisateur.
  Set<String> getLikedPhotoIds(String username) {
    final stored = _box.get(_keyFor(username));
    if (stored == null) return <String>{};
    return stored.cast<String>().toSet();
  }

  /// Inverse l'etat "like" d'une photo pour un utilisateur donne, persiste
  /// le resultat, et retourne le nouvel etat (true = likee).
  Future<bool> toggleLike(String username, String photoId) async {
    final current = getLikedPhotoIds(username);
    final isLiked = current.contains(photoId);

    if (isLiked) {
      current.remove(photoId);
    } else {
      current.add(photoId);
    }

    await _box.put(_keyFor(username), current.toList());
    return !isLiked;
  }

  Future<void> close() => _box.close();
}
