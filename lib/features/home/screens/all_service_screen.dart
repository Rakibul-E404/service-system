import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllServicesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  const AllServicesScreen({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text(
          "All Services (${services.length})",
          style: context.txtTheme.headlineLarge?.copyWith(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back,
            size: 25,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: services.length,
            itemBuilder: (BuildContext context, int index) {
              final item = services[index];
              final serviceId = item['_id']?.toString() ?? '';
              final serviceName = item['name']?.toString() ?? 'No Name';
              final serviceDescription = item['description']?.toString() ?? '';
              final serviceLocation = item['location']?.toString() ?? '';
              final serviceImage = item['image']?.toString() ?? '';
              final serviceRating = (item['rating']?.toDouble() ?? 0.0);
              final author = item['author'];
              final completeImageUrl = serviceImage.isNotEmpty && serviceImage.startsWith('http')
                  ? serviceImage
                  : serviceImage.isNotEmpty
                  ? '${AppUrl.imageBaseUrl}/$serviceImage'
                  : '';

              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.homeServiceDetailsRoute,
                    arguments: {
                      '_id': serviceId,
                      'serviceId': serviceId,
                      'serviceName': serviceName,
                      'serviceDescription': serviceDescription,
                      'serviceLocation': serviceLocation,
                      'serviceImage': completeImageUrl,
                      'serviceRating': serviceRating,
                      'author': author,
                      'authorId': author is String ? author : (author is Map ? author['_id'] : null),
                    },
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.borderRadiusMd),
                        ),
                        child: completeImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: completeImageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (BuildContext context, String url) => Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (BuildContext context, String url, Object error) =>
                              Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(Icons.error, size: 40, color: Colors.grey),
                              ),
                        )
                            : Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    serviceDescription,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.grey, size: 12),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          serviceLocation,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        serviceRating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const Spacer(),
                                      if (item['price'] != null)
                                        Text(
                                          '\$${item['price']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                    ],
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
            },
          ),
        ),
      ),
    );
  }
}