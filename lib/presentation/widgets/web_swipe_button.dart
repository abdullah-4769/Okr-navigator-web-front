// presentation/widgets/website/web_swipe_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';

class WebSwipeButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  const WebSwipeButton({super.key, required this.onSwipeComplete});

  @override
  State<WebSwipeButton> createState() => _WebSwipeButtonState();
}

class _WebSwipeButtonState extends State<WebSwipeButton> {
  double _dragPosition = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final double containerWidth = 400.w;
    final double buttonSize = 60.w;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onHorizontalDragStart: (_) {
          setState(() => _isDragging = true);
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragPosition += details.delta.dx;
            _dragPosition = _dragPosition.clamp(0, containerWidth - buttonSize);
          });
        },
        onHorizontalDragEnd: (details) {
          setState(() => _isDragging = false);

          if (_dragPosition >= containerWidth - buttonSize - 10) {
            widget.onSwipeComplete();
          } else {
            setState(() => _dragPosition = 0);
          }
        },
        child: Container(
          width: containerWidth,
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(35.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Progress Fill
              Positioned(
                left: 0,
                child: Container(
                  height: 70.h,
                  width: _dragPosition + buttonSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(35.r),
                  ),
                ),
              ),

              // Text
              Center(
                child: Text(
                  'swipe_to_start'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: _dragPosition > 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),

              // Draggable Button
              Positioned(
                left: _dragPosition,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  margin: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}