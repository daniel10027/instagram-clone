import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../data/services/likes_store.dart';
import '../data/services/unsplash_service.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import 'login_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = context.read<AuthProvider>().currentUsername ?? '';

    return ChangeNotifierProvider<FeedProvider>(
      create: (context) => FeedProvider(
        unsplashService: context.read<UnsplashService>(),
        likesStore: context.read<LikesStore>(),
        username: username,
      )..loadInitial(),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView();

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 400;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      context.read<FeedProvider>().loadMore();
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    // On differe la reinitialisation de l'etat d'authentification pour
    // eviter de reconstruire cet ecran pendant sa propre navigation.
    Future.microtask(() => context.read<AuthProvider>().logout());
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: AppColors.primaryText,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Se deconnecter',
            icon: const Icon(Icons.logout, color: AppColors.primaryText),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _buildBody(context, feedProvider),
    );
  }

  Widget _buildBody(BuildContext context, FeedProvider feedProvider) {
    if (feedProvider.isLoadingInitial && feedProvider.photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feedProvider.errorMessage != null && feedProvider.photos.isEmpty) {
      return _ErrorState(
        message: feedProvider.errorMessage!,
        onRetry: () => context.read<FeedProvider>().retry(),
      );
    }

    if (feedProvider.photos.isEmpty) {
      return const Center(child: Text('Aucune photo disponible pour le moment.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FeedProvider>().loadInitial(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: feedProvider.photos.length + 1,
        itemBuilder: (context, index) {
          if (index == feedProvider.photos.length) {
            return _FooterState(
              isLoadingMore: feedProvider.isLoadingMore,
              hasMore: feedProvider.hasMore,
              hasError: feedProvider.errorMessage != null,
              onRetry: () => context.read<FeedProvider>().loadMore(),
            );
          }

          final photo = feedProvider.photos[index];
          return PostCard(
            photo: photo,
            isLiked: feedProvider.isLiked(photo.id),
            onToggleLike: () => context.read<FeedProvider>().toggleLike(photo.id),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: AppColors.secondaryText),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.secondaryText)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.actionBlue),
              child: const Text('Reessayer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterState extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;
  final bool hasError;
  final VoidCallback onRetry;

  const _FooterState({
    required this.isLoadingMore,
    required this.hasMore,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: TextButton(
            onPressed: onRetry,
            child: const Text('Erreur de chargement — reessayer'),
          ),
        ),
      );
    }

    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Vous avez atteint la fin du feed.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}
