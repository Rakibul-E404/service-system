import 'package:flutter/material.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';

class ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String location;
  final double rating;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;
  final bool showFavorite; // Control favorite button visibility
  final bool showLocationAndRating; // Control location and rating visibility
  final double? width;
  final double? height;

  const ServiceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.rating,
    this.onTap,
    this.onFavorite,
    this.isFavorited = false,
    this.showFavorite = true, // Default to true (show favorite button)
    this.showLocationAndRating = true, // Default to true (show location and rating)
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 200,
        height: height ?? 250,  // Provide default height to avoid unbounded height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image Section
            Container(
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CustomCachedImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Heart/Favorite Button (conditionally rendered)
                  if (showFavorite)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.red : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Section
            Flexible(
              fit: FlexFit.loose,  // Use Flexible instead of Expanded
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,  // Prevents infinite height
                  children: <Widget>[
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Subtitle (Description)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: showLocationAndRating ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Location and Rating Row (conditionally rendered)
                    if (showLocationAndRating)
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
