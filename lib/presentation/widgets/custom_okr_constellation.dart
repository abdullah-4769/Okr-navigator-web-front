// widgets/custom_okr_constellation.dart
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/okr_constellation_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomOKRConstellation extends StatelessWidget {
  const CustomOKRConstellation({super.key});

  // ✅ Platform detection
  bool get _isWeb => kIsWeb;
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ✅ Responsive breakpoints
  bool _isLargeScreen(double width) => width > 1200;
  bool _isMediumScreen(double width) => width > 800 && width <= 1200;
  bool _isSmallScreen(double width) => width <= 800;

  // ✅ Helpers
  double _getContainerPadding() =>
      (_isWeb || _isDesktop) ? 20.0 : AppDimensions.d12.w;

  double _getBorderRadius() =>
      (_isWeb || _isDesktop) ? 18.0 : AppDimensions.d18.r;

  double _getRocketSize(double width) =>
      (_isLargeScreen(width)) ? 100.0 : (_isMediumScreen(width) ? 80.0 : 70.w);

  double _getIconCircleSize(double width) =>
      (_isLargeScreen(width)) ? 80.0 : (_isMediumScreen(width) ? 70.0 : 60.w);

  double _getIconSize(double width) =>
      (_isLargeScreen(width)) ? 40.0 : (_isMediumScreen(width) ? 34.0 : 28.sp);

  double _getTextFontSize(double width) =>
      (_isLargeScreen(width)) ? 22.0 : (_isMediumScreen(width) ? 18.0 : 16.sp);

  double _getPlusCircleSize(double width) =>
      (_isLargeScreen(width)) ? 80.0 : (_isMediumScreen(width) ? 70.0 : 60.w);

  double _getPlusIconSize(double width) =>
      (_isLargeScreen(width)) ? 36.0 : (_isMediumScreen(width) ? 32.0 : 30.sp);

  List<BoxShadow> _getShadow() => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OKRConstellationController>();
    final width = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          constraints: (_isWeb || _isDesktop)
              ? BoxConstraints(maxWidth: min(600, width * 0.8))
              : null,
          margin: EdgeInsets.symmetric(horizontal: AppDimensions.d10.w),
          padding: EdgeInsets.all(_getContainerPadding()),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            boxShadow: _getShadow(),
          ),
          child: SizedBox(
            height: _isLargeScreen(width)
                ? 300
                : _isMediumScreen(width)
                ? 250
                : 200.h,
            child: Obx(() {
              final icons = controller.selectedIcons;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  /// 🚀 Rocket
                  Container(
                    width: _getRocketSize(width),
                    height: _getRocketSize(width),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                      size: _getIconSize(width),
                    ),
                  ),

                  /// Text below rocket
                  Positioned(
                    bottom: _isLargeScreen(width)
                        ? 60
                        : _isMediumScreen(width)
                        ? 50
                        : 40.h,
                    child: Text(
                      'launch_product'.tr,
                      style: TextStyle(
                        fontSize: _getTextFontSize(width),
                        fontFamily: 'Gotham-Bold',
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),

                  /// 🔵 Icon 1 (top-left)
                  if (icons.isNotEmpty)
                    Positioned(
                      top: 15.h,
                      left: 30.w,
                      child: _buildIconCircle(icons[0], width),
                    ),

                  /// 🔵 Icon 2 (top-right)
                  if (icons.length > 1)
                    Positioned(
                      top: 15.h,
                      right: 30.w,
                      child: _buildIconCircle(icons[1], width),
                    ),

                  /// 🔵 Icon 3 (bottom-left)
                  if (icons.length > 2)
                    Positioned(
                      bottom: 30.h,
                      left: 30.w,
                      child: _buildIconCircle(icons[2], width),
                    ),

                  /// ➕ Plus button
                  if (controller.showPlusButton)
                    Positioned(
                      bottom: -(_getPlusCircleSize(width) / 2),
                      child: Container(
                        width: _getPlusCircleSize(width),
                        height: _getPlusCircleSize(width),
                        decoration: BoxDecoration(
                          color: AppColors.softRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryRed,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.primaryRed,
                          size: _getPlusIconSize(width),
                          weight: 550,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// 🔵 Reusable icon circle
  Widget _buildIconCircle(IconData icon, double width) => Container(
    width: _getIconCircleSize(width),
    height: _getIconCircleSize(width),
    decoration: const BoxDecoration(
      color: AppColors.primaryBlue,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white, size: _getIconSize(width)),
  );
}
