// custom_curved_arrow.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCurvedArrow extends StatelessWidget {
  final bool isLeft; // true → left.svg, false → right.svg
  final VoidCallback onTap;
  final double width;  // Base width from design mockup
  final double height; // Base height from design mockup

  const CustomCurvedArrow({
    super.key,
    required this.isLeft,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Base design size (e.g., iPhone 11 reference)
    const designWidth = 375.0;
    const designHeight = 812.0;

    // Scale based on current screen
    final scaleW = size.width / designWidth;
    final scaleH = size.height / designHeight;

    // Pick smaller to avoid stretching
    double scaleFactor = scaleW < scaleH ? scaleW : scaleH;

    // Prevent arrows from being too huge on large monitors
    if (scaleFactor > 2.0) scaleFactor = 2.0; // cap at 2x

    final responsiveWidth = (width * scaleFactor).clamp(30.0, 200.0);
    final responsiveHeight = (height * scaleFactor).clamp(30.0, 200.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: responsiveWidth,
        height: responsiveHeight,
        child: SvgPicture.asset(
          isLeft ? 'assets/images/left.svg' : 'assets/images/right.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}