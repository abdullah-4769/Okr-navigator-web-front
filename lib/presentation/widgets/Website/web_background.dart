import 'package:flutter/material.dart';

class WebBackground extends StatelessWidget {
  final String imagePath; // Background image path
  final double opacity; // Overlay opacity
  final Widget? child; // Content to display on top

  const WebBackground({
    Key? key,
    required this.imagePath,
    this.opacity = 0.5,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Full screen background image
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),

        /// Semi-transparent overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(opacity),
          ),
        ),

        /// Child content on top of background
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}
