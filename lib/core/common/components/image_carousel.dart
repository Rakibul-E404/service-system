import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';


class ImageSliderController extends GetxController {
  RxInt currentIndex = 0.obs;

  set updateIndex(int index) {
    currentIndex.value = index;
  }
}

class ImageSlider extends StatefulWidget {
  final List<String> imgList;
  final double height;
  final double indicatorWidth;
  final double indicatorHeight;
  final double borderRadius;
  final double indicatorSpacing;
  final Color activeIndicatorColor;
  final Color inactiveIndicatorColor;
  final bool isBorder;
  final bool isInfiniteSlide;
  final Function(int index)? onImageTap;

  ImageSlider({
    super.key,
    required this.imgList,
    this.height = 200.0,
    this.indicatorWidth = 20.0,
    this.indicatorHeight = 10.0,
    this.borderRadius = 12,
    this.indicatorSpacing = 12,
    this.activeIndicatorColor = AppColors.primaryColor,
    Color? inactiveIndicatorColor,
    this.isBorder = false,
    this.isInfiniteSlide = true,
    this.onImageTap,
  }) : inactiveIndicatorColor =
      inactiveIndicatorColor ?? AppColors.greyColor.withValues(alpha: 0.3);

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  // Use Get.find or Put to avoid duplicate controllers if multiple sliders exist
  late final ImageSliderController _controller;
  final PageController _pageController = PageController();
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ImageSliderController(), tag: widget.hashCode.toString());
    if (widget.isInfiniteSlide) {
      _isAutoPlaying = true;
      _startInfiniteSlide();
    }
  }

  @override
  void dispose() {
    _isAutoPlaying = false;
    _pageController.dispose();
    super.dispose();
  }

  void _startInfiniteSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _isAutoPlaying) {
        _nextPage();
      }
    });
  }

  void _nextPage() {
    if (!mounted || !_isAutoPlaying) return;

    if (_controller.currentIndex.value >= widget.imgList.length - 1) {
      _controller.updateIndex = 0;
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.updateIndex = _controller.currentIndex.value + 1;
      _pageController.animateToPage(
        _controller.currentIndex.value,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
    _startInfiniteSlide();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imgList.isEmpty) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        // Image Container
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imgList.length,
            onPageChanged: (int index) {
              _controller.updateIndex = index;
            },
            itemBuilder: (BuildContext context, int index) {
              final String imagePath = widget.imgList[index];
              final bool isNetworkImage = imagePath.startsWith('http');

              return GestureDetector(
                onTap: () => widget.onImageTap?.call(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Background color while loading
                      ),
                      child: isNetworkImage
                          ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      )
                          : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Space between image and indicators
        SizedBox(height: widget.indicatorSpacing),

        // Indicators
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imgList.length, (dotIndex) {
              bool isSelected = _controller.currentIndex.value == dotIndex;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    dotIndex,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? widget.indicatorWidth * 1.5 : widget.indicatorWidth * 0.8,
                  height: widget.indicatorHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.activeIndicatorColor : widget.inactiveIndicatorColor,
                    borderRadius: BorderRadius.circular(12),
                    border: widget.isBorder ? Border.all(color: Colors.black) : null,
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
