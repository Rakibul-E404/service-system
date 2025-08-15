import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget errorWidget;

  const CustomCachedImage({
    required this.imageUrl,
    this.width = 50.0, // Default width is 50.0
    this.height = 50.0, // Default height is 50.0
    this.fit = BoxFit.cover, // Default fit is BoxFit.cover
    this.errorWidget = const Icon(CupertinoIcons.photo, size: 48), // Default error widget
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder:
          (BuildContext context, String url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(width: width, height: height, color: Colors.white),
      ),
      errorWidget: (BuildContext context, String url, Object error) => errorWidget,
    );
  }
}
