import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:instagram_clone/data/services/unsplash_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  late MockHttpClient mockClient;
  late UnsplashService service;

  setUp(() {
    mockClient = MockHttpClient();
    service = UnsplashService(accessKey: 'fake-access-key', client: mockClient);
  });

  const samplePhotoJson = {
    'id': 'abc123',
    'description': 'Une belle photo',
    'width': 4000,
    'height': 3000,
    'likes': 42,
    'urls': {
      'thumb': 'https://images.unsplash.com/thumb.jpg',
      'regular': 'https://images.unsplash.com/regular.jpg',
    },
    'links': {'html': 'https://unsplash.com/photos/abc123'},
    'user': {
      'name': 'Jane Doe',
      'links': {'html': 'https://unsplash.com/@janedoe'},
    },
  };

  group('UnsplashService', () {
    test('leve une exception si la cle est vide', () async {
      final serviceWithoutKey = UnsplashService(accessKey: '', client: mockClient);

      expect(
        () => serviceWithoutKey.fetchPhotos(page: 1),
        throwsA(isA<UnsplashException>()),
      );
    });

    test('retourne une liste de photos parsees correctement', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(jsonEncode([samplePhotoJson]), 200),
      );

      final result = await service.fetchPhotos(page: 1, perPage: 15);

      expect(result.photos, hasLength(1));
      expect(result.photos.first.id, 'abc123');
      expect(result.photos.first.authorName, 'Jane Doe');
      expect(result.photos.first.likesCount, 42);
    });

    test('hasMore est vrai quand le nombre de resultats atteint perPage', () async {
      final fullPage = List.generate(15, (_) => samplePhotoJson);
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(jsonEncode(fullPage), 200),
      );

      final result = await service.fetchPhotos(page: 1, perPage: 15);

      expect(result.hasMore, isTrue);
    });

    test('hasMore est faux quand la derniere page est incomplete', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(jsonEncode([samplePhotoJson]), 200),
      );

      final result = await service.fetchPhotos(page: 5, perPage: 15);

      expect(result.hasMore, isFalse);
    });

    test('leve UnsplashException sur une reponse 401', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response('Unauthorized', 401),
      );

      expect(
        () => service.fetchPhotos(page: 1),
        throwsA(isA<UnsplashException>()),
      );
    });

    test('leve UnsplashException sur une erreur reseau', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('network error'));

      expect(
        () => service.fetchPhotos(page: 1),
        throwsA(isA<UnsplashException>()),
      );
    });
  });
}
