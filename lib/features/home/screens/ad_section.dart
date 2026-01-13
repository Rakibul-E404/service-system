import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

class AdSection extends StatelessWidget {
  const AdSection({super.key});

  final List<Map<String, dynamic>> _ads = const [
    {
      'id': 'ad1',
      'title': 'Need Professional Help?',
      'description': 'Find the best service providers in your area',
      'image':
      'https://images.unsplash.com/photo-1551434678-e076c223a692?w=800&h-400&fit=crop',
      'cta': 'Explore Now',
      'bgColor': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Sponsored",
                style: context.txtTheme.headlineSmall?.copyWith(
                  color: AppColors.blackColor,
                  fontSize: 18,
                ),
              ),
              Text(
                " Providers",
                style: context.txtTheme.headlineSmall?.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            height: 180,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              color: _ads[0]['bgColor'] as Color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(AppSizes.borderRadiusMd),
                    child: CachedNetworkImage(
                      imageUrl: _ads[0]['image'] as String,
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.overlay,
                      color: Colors.black.withOpacity(0.1),
                      placeholder: (BuildContext context, String url) =>
                          Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      errorWidget:
                          (BuildContext context, String url, Object error) =>
                          Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _ads[0]['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        _ads[0]['description'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}