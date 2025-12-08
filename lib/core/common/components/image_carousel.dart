/**
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
  final double borderRadius;
  final double indicatorHeight;
  final Color activeIndicatorColor;
  final Color inactiveIndicatorColor;
  final bool isBorder;
  final bool isInfiniteSlide;

  const ImageSlider({
    super.key,
    required this.imgList,
    this.height = 300.0,
    this.indicatorWidth = 20.0,
    this.indicatorHeight = 10.0,
    this.isBorder = false,
    this.isInfiniteSlide = true,
    this.borderRadius = 12,
    this.activeIndicatorColor = AppColors.primaryColor,
    this.inactiveIndicatorColor = AppColors.greyColor,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final ImageSliderController _controller = Get.put(ImageSliderController());
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.isInfiniteSlide) {
      _startInfiniteSlide();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startInfiniteSlide() {
    Future<dynamic>.delayed(const Duration(seconds: 3), _nextPage);
  }

  void _nextPage() {
    if (_controller.currentIndex.value == widget.imgList.length - 1) {
      Future<dynamic>.delayed(const Duration(milliseconds: 500), () {
        _controller.updateIndex = 0;
        _pageController.jumpToPage(0);
      });
    } else {
      _controller.updateIndex = _controller.currentIndex.value + 1;
    }

    _pageController.animateToPage(
      _controller.currentIndex.value,
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
    );

    if (widget.isInfiniteSlide) {
      Future<dynamic>.delayed(const Duration(seconds: 3), _nextPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imgList.length,
            onPageChanged: (int index) {
              _controller.updateIndex = index;
            },
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: <Widget>[
                  // Solution: Use Padding instead of Container with margin
                  // This allows the border radius to show completely
                  Padding(
                    padding: const EdgeInsets.only(right: 16), // Space only on right
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: SizedBox(
                        width: double.infinity,
                        height: widget.height,
                        child: Image.asset(
                          widget.imgList[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),

                  // Keep your original indicator position and styling
                  Positioned(
                    left: 50,
                    bottom: 50,
                    child: Obx(() {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<AnimatedContainer>.generate(widget.imgList.length, (
                                int dotIndex,
                                ) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: _controller.currentIndex.value == dotIndex
                                    ? widget.indicatorWidth * 1.5
                                    : widget.indicatorWidth * 0.6,
                                height: widget.indicatorHeight,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: _controller.currentIndex.value == dotIndex
                                      ? widget.activeIndicatorColor
                                      : widget.inactiveIndicatorColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: widget.isBorder ? Border.all(color: Colors.black) : null,
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

*/





///
///
///
///
/// todo:: updating the frontend
///
///
///
///





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
  final double borderRadius;
  final double indicatorHeight;
  final Color activeIndicatorColor;
  final Color inactiveIndicatorColor;
  final bool isBorder;
  final bool isInfiniteSlide;
  final Function(int index)? onImageTap;

  const ImageSlider({
    super.key,
    required this.imgList,
    this.height = 300.0,
    this.indicatorWidth = 20.0,
    this.indicatorHeight = 10.0,
    this.isBorder = false,
    this.isInfiniteSlide = true,
    this.borderRadius = 12,
    this.activeIndicatorColor = AppColors.primaryColor,
    this.inactiveIndicatorColor = AppColors.greyColor,
    this.onImageTap,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final ImageSliderController _controller = Get.put(ImageSliderController());
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.isInfiniteSlide) {
      _startInfiniteSlide();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startInfiniteSlide() {
    Future<dynamic>.delayed(const Duration(seconds: 3), _nextPage);
  }

  void _nextPage() {
    if (_controller.currentIndex.value == widget.imgList.length - 1) {
      Future<dynamic>.delayed(const Duration(milliseconds: 500), () {
        _controller.updateIndex = 0;
        _pageController.jumpToPage(0);
      });
    } else {
      _controller.updateIndex = _controller.currentIndex.value + 1;
    }

    _pageController.animateToPage(
      _controller.currentIndex.value,
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
    );

    if (widget.isInfiniteSlide) {
      Future<dynamic>.delayed(const Duration(seconds: 3), _nextPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imgList.length,
            onPageChanged: (int index) {
              _controller.updateIndex = index;
            },
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // Call the callback when image is tapped
                  widget.onImageTap?.call(index);
                },
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        child: SizedBox(
                          width: double.infinity,
                          height: widget.height,
                          child: Image.asset(
                            widget.imgList[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),

                    // Add a semi-transparent overlay to indicate tappable area
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 50,
                      bottom: 50,
                      child: Obx(() {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<AnimatedContainer>.generate(
                                widget.imgList.length,
                                    (int dotIndex) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: _controller.currentIndex.value == dotIndex
                                        ? widget.indicatorWidth * 1.5
                                        : widget.indicatorWidth * 0.6,
                                    height: widget.indicatorHeight,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: _controller.currentIndex.value == dotIndex
                                          ? widget.activeIndicatorColor
                                          : widget.inactiveIndicatorColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: widget.isBorder
                                          ? Border.all(color: Colors.black)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}




