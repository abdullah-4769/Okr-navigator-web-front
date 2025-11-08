import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/app_colors.dart';

class SwipeToStart extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  const SwipeToStart({super.key, required this.onSwipeComplete});

  @override
  State<SwipeToStart> createState() => _SwipeToStartState();
}

class _SwipeToStartState extends State<SwipeToStart> {
  double _dragPosition = 0.0;

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    // Sizes per
    final bool isMobile = _isMobile(context);
    final bool isTablet = _isTablet(context);
    final bool isDesktop = _isDesktop(context);

    final double height = isMobile
        ? 45.h
        : isTablet
        ? 55
        : 60;

    final double arrowSize = isMobile
        ? 40.w
        : isTablet
        ? 50
        : 55;

    final double textSize = isMobile
        ? 14.sp
        : isTablet
        ? 18
        : 20;

    final double containerWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.8
        : isTablet
        ? 400
        : 450;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.delta.dx;
          if (_dragPosition < 0) _dragPosition = 0;
          if (_dragPosition > containerWidth - arrowSize) {
            _dragPosition = containerWidth - arrowSize;
          }
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragPosition >= containerWidth - arrowSize - 5) {
          widget.onSwipeComplete();
        } else {
          setState(() => _dragPosition = 0);
        }
      },
      child: Center(
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background container
            Container(
              height: height,
              width: containerWidth,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),

            // Base Text (Black)
            Positioned.fill(
              child: Center(
                child: Text(
                  'swipe_to_start'.tr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: textSize,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Progress Fill
            Positioned(
              left: 0,
              child: Container(
                height: height,
                width: (_dragPosition + arrowSize).clamp(0, containerWidth),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),

            // Overlay Text (White)
            Positioned.fill(
              child: ClipRect(
                clipper: _TextClipper(
                  width: (_dragPosition + arrowSize).clamp(0, containerWidth),
                ),
                child: Center(
                  child: Text(
                    'swipe_to_start'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: textSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Circular Arrow
            Positioned(
              left: _dragPosition,
              child: Container(
                width: arrowSize,
                height: arrowSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryRed, width: 2),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Custom Clipper ----------------
class _TextClipper extends CustomClipper<Rect> {
  final double width;
  _TextClipper({required this.width});

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(_TextClipper oldClipper) => oldClipper.width != width;
}
