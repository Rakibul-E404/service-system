import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

class FeaturedProvidersSection extends StatelessWidget {
  const FeaturedProvidersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Providers",
            style: context.txtTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(5, (int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150,
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius:
                      BorderRadius.circular(AppSizes.borderRadiusMd),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {},
                        borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppSizes.borderRadiusMd)),
                              child: Ink(
                                height: 100,
                                width: double.infinity,
                                color: Colors.white,
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: SvgPicture.asset(
                                        'assets/icons/sponsor_icon.svg',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Platform Service Co.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Residential Plumbing",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.grey, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        "Crock Ireland",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}