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
    this.height = 500.0,
    this.indicatorWidth = 20.0,
    this.indicatorHeight = 10.0,
    this.borderRadius = 12,
    this.indicatorSpacing = 12,
    this.activeIndicatorColor = AppColors.primaryColor,
    Color? inactiveIndicatorColor, // runtime default
    this.isBorder = false,
    this.isInfiniteSlide = true,
    this.onImageTap,
  }) : inactiveIndicatorColor =
      inactiveIndicatorColor ?? AppColors.greyColor.withOpacity(0.3);

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
    Future.delayed(const Duration(seconds: 3), _nextPage);
  }

  void _nextPage() {
    if (_controller.currentIndex.value == widget.imgList.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
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
      Future.delayed(const Duration(seconds: 3), _nextPage);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              return GestureDetector(
                onTap: () {
                  widget.onImageTap?.call(index);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: SizedBox(
                      height: widget.height,
                      width: double.infinity,
                      child: Image.asset(
                        widget.imgList[index],
                        fit: BoxFit.cover,
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
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    dotIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _controller.currentIndex.value == dotIndex
                      ? widget.indicatorWidth * 1.5
                      : widget.indicatorWidth * 0.8,
                  height: widget.indicatorHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _controller.currentIndex.value == dotIndex
                        ? widget.activeIndicatorColor
                        : widget.inactiveIndicatorColor,
                    borderRadius: BorderRadius.circular(12),
                    border: widget.isBorder
                        ? Border.all(color: Colors.black)
                        : null,
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
