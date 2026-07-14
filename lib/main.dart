import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/env.dart';
import 'data/services/likes_store.dart';
import 'data/services/unsplash_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final likesStore = await LikesStore.open();

  final unsplashService = UnsplashService(accessKey: Env.unsplashAccessKey);

  runApp(InstagramCloneApp(
    likesStore: likesStore,
    unsplashService: unsplashService,
  ));
}

class InstagramCloneApp extends StatelessWidget {
  final LikesStore likesStore;
  final UnsplashService unsplashService;

  const InstagramCloneApp({
    super.key,
    required this.likesStore,
    required this.unsplashService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LikesStore>.value(value: likesStore),
        Provider<UnsplashService>.value(value: unsplashService),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Instagram Clone - Evaluation FFK',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.actionBlue,
            surface: AppColors.background,
          ),
          fontFamily: 'Roboto',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
