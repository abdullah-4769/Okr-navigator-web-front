import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCircularAvatar extends StatelessWidget {
  final String imagePath;
  final List<Color> innerColors; // must be 3
  final List<Color>? borderGradient;
  final double size;
  final double imageScale;
  final Offset imageOffset;
  final double borderWidth;
  final double innermostFactor;

  const CustomCircularAvatar({
    super.key,
    required this.imagePath,
    required this.innerColors,
    this.borderGradient,
    this.size = 100,
    this.imageScale = 0.6,
    this.imageOffset = Offset.zero,
    this.borderWidth = 3,
    this.innermostFactor = 0.6,
  }) : assert(innerColors.length == 3, 'innerColors must have exactly 3 colors');

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;

    // ✅ On desktop use raw logical pixels (size IS the size).
    // On mobile keep the original .w ScreenUtil scaling.
    final double px = isDesktop ? size : size.w;

    final double innerPx      = isDesktop ? (size - 2 * borderWidth)      : (size - 2 * borderWidth).w;
    final double midPx        = isDesktop ? (size * 0.75)                 : (size * 0.75).w;
    final double innerMostPx  = isDesktop ? (size * innermostFactor)      : (size * innermostFactor).w;
    final double imagePx      = isDesktop ? (size * imageScale)           : (size * imageScale).w;

    return SizedBox(
      width: px,
      height: px,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer gradient border
          Container(
            width: px,
            height: px,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: borderGradient != null
                  ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: borderGradient!,
              )
                  : null,
              color: borderGradient == null ? innerColors[0] : null,
            ),
          ),

          // Inner circle layers
          Container(
            width: innerPx,
            height: innerPx,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerColors[0],
            ),
            child: Center(
              child: Container(
                width: midPx,
                height: midPx,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: innerColors[1],
                ),
                child: Center(
                  child: Container(
                    width: innerMostPx,
                    height: innerMostPx,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: innerColors[2],
                    ),
                    child: Center(
                      child: Transform.translate(
                        offset: imageOffset,
                        child: _buildImage(imagePx),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double px) {
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');
    if (isSvg) {
      // Keep using whatever SVG widget you have (flutter_svg / custom_svg)
      return Image.asset(imagePath, width: px, height: px, fit: BoxFit.contain);
    }
    return Image.asset(imagePath, width: px, height: px, fit: BoxFit.contain);
  }
}