// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/common/components/custom_network_image.dart';
// import 'package:manx_mate/core/config/app_colors.dart';
// import 'package:manx_mate/core/extensions/context_extensions.dart';
// import '../../auth/widgets/app_custom_modal.dart';
//
// class HorizontalServiceCard extends StatelessWidget {
//   final String imageUrl;
//   final String title;
//   final String subtitle;
//   final String location;
//   final String rating;
//   final String status;
//   final VoidCallback? onTap;
//   final VoidCallback? onDelete; // For "Respond" button
//   final double? width;
//   final double? height;
//   final bool showStatus;
//
//   const HorizontalServiceCard({
//     super.key,
//     required this.imageUrl,
//     required this.title,
//     required this.subtitle,
//     required this.location,
//     required this.rating,
//     this.onTap,
//     this.onDelete,
//     this.width,
//     this.height,
//     required this.status,
//     this.showStatus = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: width,
//         height: height ?? 150,
//         // constraints: BoxConstraints(minHeight: height ?? 100),
//         // decoration: BoxDecoration(border: Border.all(color: AppColors.primaryColor)),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 8,
//           children: <Widget>[
//             Expanded(
//               flex: 2,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: CustomCachedImage(imageUrl: imageUrl, height: 120),
//               ),
//             ),
//             Expanded(
//               flex: 4,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(title, style: context.txtTheme.labelLarge),
//                   Text(subtitle),
//                   Row(
//                     children: <Widget>[
//                       const Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
//                       Text(
//                         location,
//                         style: context.txtTheme.bodyMedium?.copyWith(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: <Widget>[
//                       const Icon(Icons.star, color: AppColors.primaryColor),
//                       Text(rating),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: Column(
//                 children: <Widget>[
//                   IconButton(
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(24),
//                           ), // Curved top border
//                         ),
//                         builder: (BuildContext context) {
//                           return AppDeleteModal(
//                             onTap: () {
//                               Get.back();
//                             },
//                           );
//                         },
//                       );
//                     },
//                     icon: const Icon(CupertinoIcons.delete, color: Colors.red),
//                   ),
//                   if (showStatus == true) ...<Widget>[
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: status == "Requested"
//                             ? AppColors.primaryColor.withValues(alpha: 0.1)
//                             : status == "Processing"
//                             ? AppColors.greyColor
//                             : AppColors.successColor,
//                       ),
//                       child: Text(
//                         status,
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: status == "Requested"
//                               ? AppColors.primaryColor
//                               : AppColors.whiteColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../auth/widgets/app_custom_modal.dart';

class HorizontalServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;

  // final String rating;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // For "Respond" button
  final double? width;
  final double? height;
  final bool showStatus;

  const HorizontalServiceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    // required this.rating,
    this.onTap,
    this.onDelete,
    this.width,
    this.height,
    required this.status,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to adjust sizes dynamically
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Determine the card width and height based on screen size
    double cardWidth = width ?? screenWidth * 0.9;
    double cardHeight = height ?? 150;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Adjust image size based on screen width
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomCachedImage(
                  imageUrl: imageUrl,
                  height: cardHeight * 0.8, // Adjust image height proportionally
                ),
              ),
            ),
            // Adjust text and other content based on screen width
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Title: Adjust font size dynamically
                  Text(
                    title,
                    style: context.txtTheme.labelLarge?.copyWith(
                      fontSize: screenWidth * 0.05, // Adjust based on screen size
                    ),
                  ),
                  // Subtitle
                  Text(subtitle),
                  // Location with icon: Adjust font size dynamically
                  Row(
                    children: <Widget>[
                      // const Icon(
                      //   Icons.location_on_outlined,
                      //   color: AppColors.primaryColor,
                      // ),
                      Expanded(
                        child: Text(
                          description,
                          overflow: TextOverflow.ellipsis,
                          // Truncate the text with an ellipsis when it overflows
                          style: context.txtTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.03, // Adjust based on screen size
                          ),
                          maxLines:
                              2, // Optional: Limit the number of lines to 2 if the text is too long
                        ),
                      ),
                    ],
                  ),
                  // Rating with icon
                  /*Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star,
                        color: AppColors.primaryColor,
                      ),
                      Text(rating),
                    ],
                  ),*/
                ],
              ),
            ),
            // Action button column: Adjust size based on screen width
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  // Delete button: Adjust icon size dynamically
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (BuildContext context) {
                          return AppDeleteModal(
                            onTap: () {
                              Get.back();
                              if (onDelete != null) {
                                onDelete!();
                              }
                            },
                          );
                        },
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.delete,
                      color: Colors.red,
                      size: screenWidth * 0.07, // Adjust icon size dynamically
                    ),
                  ),
                  if (showStatus) const Spacer(),
                  if (showStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: status == "Requested"
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : status == "Processing"
                            ? AppColors.greyColor
                            : AppColors.successColor,
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          // Adjust text size dynamically
                          fontWeight: FontWeight.w700,
                          color: status == "Requested"
                              ? AppColors.primaryColor
                              : AppColors.whiteColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
