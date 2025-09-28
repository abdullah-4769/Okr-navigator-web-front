import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../common_image.dart';
import '../custom_curved_arrow.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? highlightedText;
  final VoidCallback? onBackTap;
  final bool showDashboardIcon;
  final bool showCurvedArrow; // Control curved arrow visibility
  final bool showLogo; // Control logo visibility
  final bool showTitle; // Control title visibility
  final bool showHighlightedText; // Control highlighted text visibility
  final bool showSubtitle; // Control subtitle visibility
  final bool showBackButton; // Control back button visibility (for web/desktop)
  final String logoAssetPath; // Custom logo path
  final VoidCallback? onLogoTap; // Logo tap callback
  final VoidCallback? onDashboardTap; // Dashboard icon tap callback

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.highlightedText,
    this.onBackTap,
    this.showDashboardIcon = true,
    this.showCurvedArrow = true,
    this.showLogo = false,
    this.showTitle = true,
    this.showHighlightedText = true,
    this.showSubtitle = true,
    this.showBackButton = true,
    this.logoAssetPath = 'assets/images/okrnav_logo.png',
    this.onLogoTap,
    this.onDashboardTap,
  });

  bool get isWebOrDesktop => kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final isTablet = size.shortestSide >= 600 && !isWebOrDesktop;
    final isDesktop = size.width >= 1024;
    final isMobile = !isWebOrDesktop && !isTablet;

    final scaleFactor = _getScaleFactor(size);
    final headerHeight = _getHeaderHeight(isDesktop, isTablet, isMobile);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Left side - Logo, Back button, or Curved Arrow
              _buildLeftSection(size, isDesktop, isTablet, isMobile, scaleFactor),

              /// Center Title + Highlight
              _buildCenterSection(theme, isDesktop, isTablet, isMobile),

              /// Right side - Dashboard icon
              _buildRightSection(size, isDesktop, isTablet, isMobile, scaleFactor),
            ],
          ),

          /// Subtitle below
          if (showSubtitle && subtitle != null && subtitle!.isNotEmpty)
            _buildSubtitle(size, theme, isDesktop, isTablet, isMobile),
        ],
      ),
    );
  }

  double _getHeaderHeight(bool isDesktop, bool isTablet, bool isMobile) {
    if (isWebOrDesktop) {
      return isDesktop ? 110.0 : 100.0;
    } else {
      return isTablet ? 120.h : 130.h;
    }
  }

  Widget _buildLeftSection(Size size, bool isDesktop, bool isTablet, bool isMobile, double scaleFactor) {
    return SizedBox(
      width: size.width * 0.18,
      child: Align(
        alignment: Alignment.centerLeft,
        child: _getLeftWidget(size, isDesktop, isTablet, isMobile, scaleFactor),
      ),
    );
  }

  Widget _getLeftWidget(Size size, bool isDesktop, bool isTablet, bool isMobile, double scaleFactor) {
    // For mobile - show curved arrow if enabled
    if (isMobile && showCurvedArrow && onBackTap != null) {
      return CustomCurvedArrow(
        isLeft: true,
        onTap: onBackTap!,
        width: size.width * 0.15,
        height: size.height * 0.18,
      );
    }

    // For web/desktop - show logo or SVG back image
    if (isWebOrDesktop) {
      if (showLogo) {
        return GestureDetector(
          onTap: onLogoTap,
          child: CommonImage(
            assetPath: logoAssetPath,
            height: isDesktop ? 55.0 : 45.0,
            width: isDesktop ? 160.0 : 140.0,
          ),
        );
      } else if (showBackButton && onBackTap != null) {
        return _buildWebSvgBackButton();
      }
    }

    // For tablet - show logo or back button based on preferences
    if (isTablet) {
      if (showLogo) {
        return GestureDetector(
          onTap: onLogoTap,
          child: CommonImage(
            assetPath: logoAssetPath,
            height: 50.h,
            width: 150.w,
          ),
        );
      } else if (showBackButton && onBackTap != null) {
        return _buildTabletBackButton();
      }
    }

    return const SizedBox.shrink();
  }

  /// Web/desktop back button as SVG image
  Widget _buildWebSvgBackButton() {
    return GestureDetector(
      onTap: onBackTap,
      child: SvgPicture.asset(
        'assets/images/left.svg',
        width: 100.0,
        height: 104.0,
      ),
    );
  }

  Widget _buildTabletBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withAlpha(50),
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomCurvedArrow(
        isLeft: true,
        onTap: onBackTap ?? () {},
        width: 20.w,
        height: 15.h,
      ),
    );
  }

  Widget _buildCenterSection(ThemeData theme, bool isDesktop, bool isTablet, bool isMobile) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Main Title
          if (showTitle)
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                color: AppColors.primaryRed,
                fontSize: _getTitleFontSize(isDesktop, isTablet, isMobile),
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),

          /// Highlighted Text
          if (showHighlightedText && highlightedText != null && highlightedText!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: _getHighlightPadding(isMobile)),
              child: Text(
                highlightedText!,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: _getHighlightFontSize(isDesktop, isTablet, isMobile),
                  height: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightSection(Size size, bool isDesktop, bool isTablet, bool isMobile, double scaleFactor) {
    return SizedBox(
      width: size.width * 0.18,
      child: Align(
        alignment: Alignment.centerRight,
        child: showDashboardIcon
            ? GestureDetector(
          onTap: onDashboardTap,
          child: CircleAvatar(
            radius: _getDashboardRadius(isDesktop, isTablet, isMobile, scaleFactor),
            backgroundColor: AppColors.white,
            child: Padding(
              padding: EdgeInsets.all(_getDashboardPadding(isMobile, scaleFactor)),
              child: CommonImage(
                assetPath: 'assets/images/global_persondashboard.png',
                semanticsLabel: 'profile'.tr,
                height: _getDashboardSize(isDesktop, isTablet, isMobile, scaleFactor),
                width: _getDashboardSize(isDesktop, isTablet, isMobile, scaleFactor),
              ),
            ),
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSubtitle(Size size, ThemeData theme, bool isDesktop, bool isTablet, bool isMobile) {
    return Positioned(
      bottom: isMobile ? 6.h : 6.0,
      left: size.width * 0.1,
      right: size.width * 0.1,
      child: Text(
        subtitle!,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textBlack,
          fontSize: _getSubtitleFontSize(isDesktop, isTablet, isMobile),
          height: 1.3,
        ),
      ),
    );
  }

  // Font size helpers
  double _getTitleFontSize(bool isDesktop, bool isTablet, bool isMobile) {
    if (isWebOrDesktop) return isDesktop ? 42.0 : 36.0;
    return isTablet ? 36.sp : 30.sp;
  }

  double _getHighlightFontSize(bool isDesktop, bool isTablet, bool isMobile) {
    if (isWebOrDesktop) return isDesktop ? 26.0 : 22.0;
    return isTablet ? 22.sp : 18.sp;
  }

  double _getSubtitleFontSize(bool isDesktop, bool isTablet, bool isMobile) {
    if (isWebOrDesktop) return isDesktop ? 18.0 : 16.0;
    return isTablet ? 16.sp : 14.sp;
  }

  double _getHighlightPadding(bool isMobile) => isMobile ? 4.h : 4.0;

  double _getDashboardRadius(bool isDesktop, bool isTablet, bool isMobile, double scaleFactor) {
    if (isWebOrDesktop) return (isDesktop ? 32.0 : 28.0) * scaleFactor;
    return (isTablet ? 28.r : 24.r) * scaleFactor;
  }

  double _getDashboardPadding(bool isMobile, double scaleFactor) => (isMobile ? 4.r : 4.0) * scaleFactor;

  double _getDashboardSize(bool isDesktop, bool isTablet, bool isMobile, double scaleFactor) {
    if (isWebOrDesktop) return (isDesktop ? 42.0 : 36.0) * scaleFactor;
    return (isTablet ? 38.r : 36.r) * scaleFactor;
  }

  double _getScaleFactor(Size size) {
    if (isWebOrDesktop) {
      if (size.width >= 1400) return 1.3;
      if (size.width >= 1024) return 1.15;
      return 1.0;
    } else {
      if (size.width >= 1400) return 1.3;
      if (size.width >= 1024) return 1.15;
      if (size.shortestSide >= 600) return 1.05;
      return 1.0;
    }
  }
}
