import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../data/models/unsplash_photo.dart';
import 'image_placeholder.dart';

/// Publication du feed, reprenant la structure visuelle d'un post
/// Instagram : en-tete (auteur), image, barre d'actions avec bouton
/// "like" fonctionnel, puis legende.
class PostCard extends StatelessWidget {
  final UnsplashPhoto photo;
  final bool isLiked;
  final VoidCallback onToggleLike;

  const PostCard({
    super.key,
    required this.photo,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(authorName: photo.authorName),
        AspectRatio(
          aspectRatio: photo.aspectRatio.clamp(0.6, 1.9).toDouble(),
          child: CachedNetworkImage(
            imageUrl: photo.regularUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ImagePlaceholder(),
            errorWidget: (context, url, error) =>
                const ImagePlaceholder(isError: true),
          ),
        ),
        _ActionsRow(isLiked: isLiked, onToggleLike: onToggleLike),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${photo.likesCount + (isLiked ? 1 : 0)} mentions J\'aime',
            style: AppTextStyles.username,
          ),
        ),
        if ((photo.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
                children: [
                  TextSpan(text: photo.authorName, style: AppTextStyles.username),
                  const TextSpan(text: '  '),
                  TextSpan(text: photo.description),
                ],
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String authorName;

  const _Header({required this.authorName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.border,
            child: Text(
              authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
              style: AppTextStyles.username,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              authorName,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.username,
            ),
          ),
          const Icon(Icons.more_vert, size: 20, color: AppColors.primaryText),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onToggleLike;

  const _ActionsRow({required this.isLiked, required this.onToggleLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
         const IconButton(
            onPressed: null,
            icon: Icon(Icons.mode_comment_outlined, size: 24),
            color: AppColors.primaryText,
            disabledColor: AppColors.primaryText,
          ),
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.send_outlined, size: 24),
            color: AppColors.primaryText,
            disabledColor: AppColors.primaryText,
          ),
          const Spacer(),
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.bookmark_border, size: 24),
            color: AppColors.primaryText,
            disabledColor: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}
