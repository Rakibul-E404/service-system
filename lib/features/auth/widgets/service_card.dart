
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
  final bool showFavorite;
  final bool showLocationAndRating;
  final double? width;
  final double? height;
  final bool isGuestMode; // New parameter for guest mode

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
    this.showFavorite = true,
    this.showLocationAndRating = true,
    this.width,
    this.height,
    this.isGuestMode = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 200,
        height: height ?? 250,
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
                  // Hide favorite button in guest mode or when showFavorite is false
                  if (showFavorite && !isGuestMode)
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
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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

                    // Location and Rating Row
                    // Hide in guest mode OR when showLocationAndRating is false
                    if (showLocationAndRating && !isGuestMode)
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
                          Icon(Icons.star, size: 14, color: Color(0xffed9d34)),
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

