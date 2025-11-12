import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:game_app/generated/assets.dart';

import '../../../controllers/language_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    final bool isMobile = screenWidth < 768;
    // Constrain max content width on larger screens
    final maxContentWidth =
    isDesktop ? 600.0 : (isTablet ? screenWidth * 0.8 : double.infinity);

    // Typography
    final titleStyle = (theme.textTheme.headlineLarge ??
        const TextStyle(fontSize: 22, fontWeight: FontWeight.w600))
        .copyWith(
      fontSize: _getResponsiveTitleSize(screenWidth, isLandscape),
      fontWeight: FontWeight.w600,
    );

    final tileTitleStyle =
    (theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
      fontSize: _getResponsiveTileSize(screenWidth),
    );

    final tileSubtitleStyle =
    (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
      fontSize: _getResponsiveSubtitleSize(screenWidth),
    );

    return  Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: isMobile
                ? Container(
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundTop,
                    AppColors.backgroundBottom
                  ],
                ),
              ),
            )
                : Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ✅ Main Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsivePadding(screenWidth),
                    vertical: screenHeight * 0.02,
                  ),
                  children: [
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),

                    /// Title
                    _buildTitleSection(
                      screenHeight,
                      screenWidth,
                      titleStyle,
                      isLandscape,
                    ),

                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),

                    /// Language List
                    ...controller.supportedLanguages.map(
                          (lang) => _buildLanguageTile(
                        lang['nativeName']!,
                        lang['name']!,
                        lang['flag']!,
                        lang['code']!,
                        controller,
                        tileTitleStyle,
                        tileSubtitleStyle,
                        screenWidth,
                      ),
                    ),

                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),

                    /// Continue Button
                    _buildContinueButton(screenWidth, isTablet),

                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),

                    /// Bottom Logo
                    _buildBottomLogo(screenWidth),

                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  /// 🔹 Title section
  Widget _buildTitleSection(
      double screenHeight,
      double screenWidth,
      TextStyle titleStyle,
      bool isLandscape,
      ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.imagesLanguageImage,
            height: _getResponsiveImageHeight(
                screenHeight, screenWidth, isLandscape),
            fit: BoxFit.contain,
          ),
          SizedBox(width: _getResponsiveSpacing(screenWidth, 0.013)),
          Flexible(
            child: Text(
              'select_language'.tr,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

  Widget _buildLanguageList(
      LanguageController controller,
      TextStyle tileTitleStyle,
      TextStyle tileSubtitleStyle,
      double screenWidth,
      bool isTablet,
      ) {
    final languages = controller.supportedLanguages;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // disable inner scroll
      shrinkWrap: true, // let parent scroll
      padding: EdgeInsets.only(top: AppDimensions.d6),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final lang = languages[index];
        return _buildLanguageTile(
          lang['nativeName']!,
          lang['name']!,
          lang['flag']!,
          lang['code']!,
          controller,
          tileTitleStyle,
          tileSubtitleStyle,
          screenWidth,
        );
      },
    );
  }

  /// 🔹 Continue button
  Widget _buildContinueButton(double screenWidth, bool isTablet) => SizedBox(
    height: 70.h,
    //width: isTablet ? 300 : double.infinity,
    child: CustomButton(
      text: 'continue'.tr,
      onPressed: () => Get.offAllNamed(AppRoutes.register),
      backgroundColor: AppColors.primaryRed,
    ),
  );

  /// 🔹 Bottom logo
  Widget _buildBottomLogo(double screenWidth) => Center(
    child: CustomSvg(
      assetPath: 'assets/images/logo.svg',
      width: _getResponsiveLogoSize(screenWidth),
      height: _getResponsiveLogoSize(screenWidth),
      semanticsLabel: 'App Logo',
    ),
  );

  /// 🔹 Language tile
  Widget _buildLanguageTile(
      String title,
      String subtitle,
      String flag,
      String languageCode,
      LanguageController controller,
      TextStyle tileTitleBase,
      TextStyle tileSubtitleBase,
      double screenWidth,
      ) =>
      Obx(() {
        final isSelected = controller.selectedLanguage.value == languageCode;

        return Container(
          margin: EdgeInsets.symmetric(vertical: AppDimensions.d6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.d8),
            border: Border.all(
              color: isSelected ? AppColors.primaryRed : AppColors.borderGrey,
              width: AppDimensions.d2,
            ),
            color: isSelected ? AppColors.selectedBg : AppColors.white,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: _getResponsiveTilePadding(screenWidth),
              vertical: AppDimensions.d4,
            ),
            leading: Text(
              flag,
              style: tileTitleBase.copyWith(
                fontSize: _getResponsiveFlagSize(screenWidth),
              ),
            ),
            title: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: tileTitleBase.copyWith(
                color: isSelected
                    ? AppColors.primaryRed
                    : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: tileSubtitleBase.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(Icons.check_circle,
                  color: AppColors.primaryRed, key: ValueKey('selected'))
                  : const SizedBox.shrink(key: ValueKey('unselected')),
            ),
            onTap: () => controller.changeLanguage(languageCode),
          ),
        );
      });

  // 🔹 Responsive Helpers
  double _getResponsiveTitleSize(double screenWidth, bool isLandscape) {
    if (screenWidth > 900) return 32;
    if (screenWidth > 600) return 28;
    if (isLandscape && screenWidth > 500) return 24;
    return 22;
  }

  double _getResponsiveTileSize(double screenWidth) {
    if (screenWidth > 900) return 18;
    if (screenWidth > 600) return 17;
    return 16;
  }

  double _getResponsiveSubtitleSize(double screenWidth) {
    if (screenWidth > 900) return 16;
    if (screenWidth > 600) return 15;
    return 14;
  }

  double _getResponsiveFlagSize(double screenWidth) {
    if (screenWidth > 900) return 24;
    if (screenWidth > 600) return 22;
    return 20;
  }

  double _getResponsivePadding(double screenWidth) {
    if (screenWidth > 900) return 48;
    if (screenWidth > 600) return 32;
    return screenWidth * 0.04;
  }

  double _getResponsiveTilePadding(double screenWidth) {
    if (screenWidth > 600) return 20;
    return 16;
  }

  double _getResponsiveSpacing(double dimension, double factor) {
    return dimension * factor;
  }

  double _getResponsiveImageHeight(
      double screenHeight, double screenWidth, bool isLandscape) {
    if (isLandscape) return screenHeight * 0.08;
    if (screenWidth > 900) return screenHeight * 0.07;
    if (screenWidth > 600) return screenHeight * 0.065;
    return screenHeight * 0.06;
  }

  double _getResponsiveLogoSize(double screenWidth) {
    if (screenWidth > 900) return screenWidth * 0.03;
    if (screenWidth > 600) return screenWidth * 0.04;
    return screenWidth * 0.10;
  }
}