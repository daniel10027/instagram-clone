import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:instagram_clone/data/services/likes_store.dart';

void main() {
  late Directory tempDir;
  late LikesStore likesStore;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('likes_store_test');
    Hive.init(tempDir.path);
    likesStore = await LikesStore.open();
  });

  tearDown(() async {
    await likesStore.close();
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LikesStore', () {
    test("un utilisateur sans historique n'a aucun like", () {
      expect(likesStore.getLikedPhotoIds('muser1'), isEmpty);
    });

    test('toggleLike ajoute un like et le persiste', () async {
      final isLiked = await likesStore.toggleLike('muser1', 'photo-1');

      expect(isLiked, isTrue);
      expect(likesStore.getLikedPhotoIds('muser1'), contains('photo-1'));
    });

    test('toggleLike deux fois de suite retire le like', () async {
      await likesStore.toggleLike('muser1', 'photo-1');
      final isLikedAfterSecondToggle = await likesStore.toggleLike('muser1', 'photo-1');

      expect(isLikedAfterSecondToggle, isFalse);
      expect(likesStore.getLikedPhotoIds('muser1'), isNot(contains('photo-1')));
    });

    test('les likes sont isoles par utilisateur', () async {
      await likesStore.toggleLike('muser1', 'photo-1');
      await likesStore.toggleLike('muser2', 'photo-2');

      expect(likesStore.getLikedPhotoIds('muser1'), {'photo-1'});
      expect(likesStore.getLikedPhotoIds('muser2'), {'photo-2'});
    });

    test('les likes persistent apres fermeture et reouverture de la base', () async {
      await likesStore.toggleLike('muser1', 'photo-1');
      await likesStore.toggleLike('muser1', 'photo-2');
      await likesStore.close();

      final reopened = await LikesStore.open();
      expect(reopened.getLikedPhotoIds('muser1'), {'photo-1', 'photo-2'});
      likesStore = reopened;
    });
  });
}
