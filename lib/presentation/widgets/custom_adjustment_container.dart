import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomAdjustmentContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;

  /// 🔹 Optional action button
  final String? actionText;
  final Color? actionColor;
  final VoidCallback? onActionTap;

  /// 🔹 Optional children rows
  final List<Widget>? children;

  /// 🔹 Card border + highlight
  final Color borderColor;
  final bool showShadow;

  const CustomAdjustmentContainer({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    this.actionText,
    this.actionColor,
    this.onActionTap,
    this.children,
    this.borderColor = const Color(0xFFE0E0E0),
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return _ResponsiveAdjustmentContainer(
              icon: icon,
              iconColor: iconColor,
              title: title,
              description: description,
              actionText: actionText,
              actionColor: actionColor,
              onActionTap: onActionTap,
              children: children,
              borderColor: borderColor,
              showShadow: showShadow,
              constraints: constraints,
              orientation: orientation,
            );
          },
        );
      },
    );
  }
}

class _ResponsiveAdjustmentContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final String? actionText;
  final Color? actionColor;
  final VoidCallback? onActionTap;
  final List<Widget>? children;
  final Color borderColor;
  final bool showShadow;
  final BoxConstraints constraints;
  final Orientation orientation;

  const _ResponsiveAdjustmentContainer({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    this.actionText,
    this.actionColor,
    this.onActionTap,
    this.children,
    required this.borderColor,
    required this.showShadow,
    required this.constraints,
    required this.orientation,
  });

  // --- ENHANCED DEVICE DETECTION ---
  double get screenWidth => constraints.maxWidth;
  double get screenHeight => constraints.maxHeight;

  DeviceType get deviceType {
    if (screenWidth < 600) return DeviceType.mobile;
    if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
    if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
    if (screenWidth >= 1200 && screenWidth < 1920) return DeviceType.largeDesktop;
    return DeviceType.ultraWide;
  }

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop ||
      deviceType == DeviceType.largeDesktop ||
      deviceType == DeviceType.ultraWide;
  bool get isWeb => screenWidth >= 1200;

  // --- RESPONSIVE HELPERS ---

  /// Font size helper with orientation consideration
  double getResponsiveFont({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseFontSize;

    switch (deviceType) {
      case DeviceType.mobile:
        baseFontSize = mobile;
        break;
      case DeviceType.tablet:
        baseFontSize = tablet;
        break;
      case DeviceType.desktop:
        baseFontSize = desktop;
        break;
      case DeviceType.largeDesktop:
        baseFontSize = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseFontSize = ultraWide;
        break;
    }

    // Adjust for landscape if needed
    if (isLandscape && landscapeAdjustment != null) {
      baseFontSize *= landscapeAdjustment;
    }

    return baseFontSize.sp;
  }

  /// Icon size helper with orientation consideration
  double getResponsiveIcon({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseIconSize;

    switch (deviceType) {
      case DeviceType.mobile:
        baseIconSize = mobile;
        break;
      case DeviceType.tablet:
        baseIconSize = tablet;
        break;
      case DeviceType.desktop:
        baseIconSize = desktop;
        break;
      case DeviceType.largeDesktop:
        baseIconSize = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseIconSize = ultraWide;
        break;
    }

    // Adjust for landscape orientation
    if (isLandscape && landscapeAdjustment != null) {
      baseIconSize *= landscapeAdjustment;
    }

    return baseIconSize.w;
  }

  /// Spacing helper with orientation consideration
  double getResponsiveSpacing({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseSpacing;

    switch (deviceType) {
      case DeviceType.mobile:
        baseSpacing = mobile;
        break;
      case DeviceType.tablet:
        baseSpacing = tablet;
        break;
      case DeviceType.desktop:
        baseSpacing = desktop;
        break;
      case DeviceType.largeDesktop:
        baseSpacing = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseSpacing = ultraWide;
        break;
    }

    // Adjust for landscape if specified
    if (isLandscape && landscapeAdjustment != null) {
      baseSpacing *= landscapeAdjustment;
    }

    return baseSpacing.h;
  }

  /// Width helper with orientation support
  double getResponsiveWidth({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseWidth;

    switch (deviceType) {
      case DeviceType.mobile:
        baseWidth = mobile;
        break;
      case DeviceType.tablet:
        baseWidth = tablet;
        break;
      case DeviceType.desktop:
        baseWidth = desktop;
        break;
      case DeviceType.largeDesktop:
        baseWidth = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseWidth = ultraWide;
        break;
    }

    // Adjust for landscape if needed
    if (isLandscape && landscapeAdjustment != null) {
      baseWidth *= landscapeAdjustment;
    }

    return baseWidth.w;
  }

  /// Border radius helper
  double getResponsiveBorderRadius({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile.r;
      case DeviceType.tablet:
        return tablet.r;
      case DeviceType.desktop:
        return desktop.r;
      case DeviceType.largeDesktop:
        return largeDesktop.r;
      case DeviceType.ultraWide:
        return ultraWide.r;
    }
  }

  /// Border width helper
  double getResponsiveBorderWidth({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop;
      case DeviceType.ultraWide:
        return ultraWide;
    }
  }

  /// Padding helper with orientation support
  EdgeInsets getResponsivePadding({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    final spacing = getResponsiveSpacing(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      ultraWide: ultraWide,
      landscapeAdjustment: landscapeAdjustment,
    );
    return EdgeInsets.all(spacing);
  }

  /// Margin helper with orientation support
  EdgeInsets getResponsiveMargin({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    final spacing = getResponsiveSpacing(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      ultraWide: ultraWide,
      landscapeAdjustment: landscapeAdjustment,
    );
    return EdgeInsets.only(bottom: spacing);
  }

  /// Container max width for better web/desktop experience
  double? get maxContainerWidth {
    if (isMobile) return null;
    if (isTablet) return 700;
    if (deviceType == DeviceType.desktop) return 900;
    if (deviceType == DeviceType.largeDesktop) return 1100;
    return 1300; // ultraWide
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxContainerWidth ?? double.infinity,
        ),
        margin: getResponsiveMargin(
          mobile: 16,
          tablet: 20,
          desktop: 24,
          largeDesktop: 28,
          ultraWide: 32,
          landscapeAdjustment: 0.8,
        ),
        padding: getResponsivePadding(
          mobile: 16,
          tablet: 20,
          desktop: 24,
          largeDesktop: 28,
          ultraWide: 32,
          landscapeAdjustment: 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            getResponsiveBorderRadius(
              mobile: 16,
              tablet: 18,
              desktop: 20,
              largeDesktop: 22,
              ultraWide: 24,
            ),
          ),
          border: Border.all(
            color: borderColor,
            width: getResponsiveBorderWidth(
              mobile: 1.5,
              tablet: 1.8,
              desktop: 2.0,
              largeDesktop: 2.2,
              ultraWide: 2.5,
            ),
          ),
          boxShadow: showShadow
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(isDesktop ? 0.08 : 0.05),
              blurRadius: isDesktop ? 12 : 6,
              offset: Offset(0, isDesktop ? 6 : 3),
              spreadRadius: isDesktop ? 1 : 0,
            )
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Header Row: Icon + Title + Action Button
            _buildHeaderRow(context),

            /// 🔹 Children Section (e.g. Key Results / Initiatives list)
            if (children != null && children!.isNotEmpty) ...[
              SizedBox(
                height: getResponsiveSpacing(
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                  largeDesktop: 22,
                  ultraWide: 24,
                  landscapeAdjustment: 0.8,
                ),
              ),
              Column(children: children!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Icon Circle
        _buildIconCircle(),

        SizedBox(
          width: getResponsiveWidth(
            mobile: 12,
            tablet: 16,
            desktop: 20,
            largeDesktop: 22,
            ultraWide: 24,
            landscapeAdjustment: 0.8,
          ),
        ),

        // Title + Description
        _buildTitleSection(context),

        // Right Action Button
        if (actionText != null && actionColor != null && onActionTap != null)
          _buildActionButton(),
      ],
    );
  }

  Widget _buildIconCircle() {
    return Container(
      padding: EdgeInsets.all(
        getResponsiveWidth(
          mobile: 10,
          tablet: 12,
          desktop: 14,
          largeDesktop: 16,
          ultraWide: 18,
          landscapeAdjustment: 0.9,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        shape: BoxShape.circle,
        boxShadow: isDesktop ? [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Icon(
        icon,
        color: AppColors.white,
        size: getResponsiveIcon(
          mobile: 20,
          tablet: 24,
          desktop: 28,
          largeDesktop: 32,
          ultraWide: 36,
          landscapeAdjustment: 0.9,
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
              fontSize: getResponsiveFont(
                mobile: 18,
                tablet: 20,
                desktop: 22,
                largeDesktop: 24,
                ultraWide: 26,
                landscapeAdjustment: 0.9,
              ),
              letterSpacing: isDesktop ? 0.3 : 0,
              height: 1.3,
            ),
          ),
          if (description != null) ...[
            SizedBox(
              height: getResponsiveSpacing(
                mobile: 4,
                tablet: 6,
                desktop: 8,
                largeDesktop: 10,
                ultraWide: 12,
                landscapeAdjustment: 0.8,
              ),
            ),
            Text(
              description!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w400,
                fontSize: getResponsiveFont(
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                  largeDesktop: 19,
                  ultraWide: 20,
                  landscapeAdjustment: 0.9,
                ),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: onActionTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: getResponsiveWidth(
            mobile: 12,
            tablet: 16,
            desktop: 18,
            largeDesktop: 20,
            ultraWide: 22,
            landscapeAdjustment: 0.8,
          ),
          vertical: getResponsiveSpacing(
            mobile: 6,
            tablet: 8,
            desktop: 10,
            largeDesktop: 12,
            ultraWide: 14,
            landscapeAdjustment: 0.8,
          ),
        ),
        decoration: BoxDecoration(
          color: actionColor,
          borderRadius: BorderRadius.circular(
            getResponsiveBorderRadius(
              mobile: 20,
              tablet: 22,
              desktop: 24,
              largeDesktop: 26,
              ultraWide: 28,
            ),
          ),
          boxShadow: isDesktop ? [
            BoxShadow(
              color: actionColor!.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: getResponsiveIcon(
                mobile: 14,
                tablet: 16,
                desktop: 18,
                largeDesktop: 20,
                ultraWide: 22,
                landscapeAdjustment: 0.9,
              ),
              color: Colors.white,
            ),
            SizedBox(
              width: getResponsiveWidth(
                mobile: 4,
                tablet: 6,
                desktop: 8,
                largeDesktop: 9,
                ultraWide: 10,
                landscapeAdjustment: 0.8,
              ),
            ),
            Text(
              actionText!,
              style: TextStyle(
                fontSize: getResponsiveFont(
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                  largeDesktop: 17,
                  ultraWide: 18,
                  landscapeAdjustment: 0.9,
                ),
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: isDesktop ? 0.2 : 0,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced device type enumeration
enum DeviceType {
  mobile,      // < 600px
  tablet,      // 600-899px
  desktop,     // 900-1199px
  largeDesktop, // 1200-1919px
  ultraWide,   // >= 1920px
}