import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/generated/assets.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:game_app/presentation/widgets/bubble_button.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../widgets/custom_svg.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController c = Get.put(HomeController());

  bool get isMobile => Get.width < 600;
  bool get isDesktop => Get.width >= 1024;


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return OrientationBuilder(
      builder: (context, orientation) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: isDesktop
              ? BoxDecoration(
            image: DecorationImage(
              image:
              const AssetImage("assets/images/web_background.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.15),
                BlendMode.dstATop,
              ),
            ),
          )
              : const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundBottom,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.d8.w),
              child: Column(
                children: [
                  SizedBox(height: AppDimensions.d26.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomSvg(
                        assetPath: 'assets/images/okrnev.svg',
                        semanticsLabel: 'OKR',
                        height: isDesktop ? 60 : 40.h,
                      ),
                      Row(
                        children: [
                          // certificate svg
                          CustomSvg(
                            assetPath: 'assets/images/certificate.svg',
                            height: isDesktop ? 20.sp : 20.sp, // same as avatar
                            width: isDesktop ? 20.sp : 20.sp,
                            semanticsLabel: '',
                          ),
                          SizedBox(width: 12.w),
                          // person dashboard png
                          _profileAvatar(
                            image: 'assets/images/global_persondashboard.png',
                            isLocal: true,

                          ),
                        ],
                      ),
                    ],
                  ),


                  SizedBox(height: AppDimensions.d12.h),

                  Center(
                    child: CustomBubbleButton(
                      text: 'Certificate',
                      width: isDesktop ? 120 : 90,
                      height: isDesktop ? 40 : 30,
                      onTap: () {},
                    ),
                  ),

                  SizedBox(height: AppDimensions.d18.h),

                  // ===== Cards =====
                  Expanded(
                    child: isDesktop
                        ? _desktopCardView(screenWidth, screenHeight)
                        : _mobileCardView(screenWidth, screenHeight),
                  ),

                  _dashboardButton(context),
                  SizedBox(height: AppDimensions.d16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== MOBILE (vertical stacked cards) =====
  Widget _mobileCardView(double screenWidth, double screenHeight) => Align(
    alignment: Alignment.centerRight,
    child: SizedBox(
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _verticalDots(),
          SizedBox(width: 30.w),
          SizedBox(
            width: screenWidth * 0.8,
            height: screenHeight * 0.5,
            child: PageView.builder(
              controller: c.pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: c.cards.length,
              itemBuilder: (context, index) => AnimatedBuilder(
                animation: c.pageController,
                builder: (context, child) {
                  final double page = c.pageController.hasClients
                      ? (c.pageController.page ?? 0.0)
                      : 0.0;
                  final delta = (index - page);
                  final translateX = delta * -40.w;
                  final rotate = delta * -0.09;
                  final scale = (1 - (delta.abs() * 0.1)).clamp(0.9, 1.0);

                  return Transform.translate(
                    offset: Offset(translateX, 0),
                    child: Transform.rotate(
                      angle: rotate,
                      child: Transform.scale(
                        scale: scale,
                        child: _card(index, context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ===== DESKTOP (carousel with side peek) =====
  Widget _desktopCardView(double screenWidth, double screenHeight) {
    final cardHeight = screenHeight * 0.45;
    final cardWidth = screenWidth * 0.55; // main card width

    return
           Center(
        child: SizedBox(
          width: screenWidth * 0.8,
          height: cardHeight,
          child: PageView.builder(
            controller: c.pageController,
            itemCount: c.cards.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => c.selectedCardIndex.value = i,
            itemBuilder: (context, index) {
              final currentPage =
              c.pageController.hasClients ? c.pageController.page ?? 0.0 : 0.0;
              final delta = index - currentPage;

              // scale + position
              final scale = (1 - (delta.abs() * 0.15)).clamp(0.8, 1.0);
              final translateY = delta.abs() * 20.0; // side cards slightly down
              final opacity = (1 - delta.abs() * 0.3).clamp(0.0, 1.0);

              return GestureDetector(
                onTap: () {
                  c.pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: SizedBox(
                          width: cardWidth,
                          child: _card(index, context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  }


  // ===== Profile Avatar =====
  Widget _profileAvatar({required String image, bool isLocal = false}) {
    return Container(
      height: 20.sp,
      width: 20.sp,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryRed),
        color: AppColors.softRed.withValues(alpha: 0.4),
      ),
      child: ClipOval(
        child: isLocal
            ? Image.asset(image, fit: BoxFit.cover)
            : Image.network(image, fit: BoxFit.cover),
      ),
    );
  }

  // ===== Vertical Dots (mobile only) =====
  Widget _verticalDots() => Obx(
        () => SizedBox(
      width: 12.w,
      height: 140.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(c.cards.length * 2 - 1, (i) {
          if (i.isOdd) return SizedBox(height: 6.h);
          final dotIndex = i ~/ 2;
          final active = c.selectedCardIndex.value == dotIndex;
          return Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFC34028) : Colors.black26,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    ),
  );

  // ===== Card =====
  Widget _card(int index, BuildContext context) {
    final m = c.cards[index];
    final bg = Color(m['bg'] as int);
    final bg2 = Color(m['bg2'] as int);

    return GestureDetector(
      onTap: c.onTapCTA,
      child: Container(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg, bg2],
          ),
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _cardBody(m, context),
      ),
    );
  }

  Widget _cardBody(Map<String, dynamic> m, BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${(m['titleTop'] ?? '').toString().tr}\n',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isDesktop ? 28 : 32.sp,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: (m['titleBottom'] ?? '').toString().tr,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: isDesktop ? 24 : 28.sp,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 10.h),
      Text(
        (m['subtitle'] ?? '').toString().tr,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: isDesktop ? 14 : 13.sp,
          height: 1.35,
          color: Colors.white,
        ),
      ),
      const Spacer(),
      Text(
        (m['cta'] ?? '').toString().tr,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: isDesktop ? 15 : 14.sp,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          color: Colors.white,
        ),
      ),
    ],
  );

  // ===== Dashboard Button =====
  Widget _dashboardButton(BuildContext context) => GestureDetector(
    onTap: () => Get.toNamed(AppRoutes.personalDashboardScreen),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'go_to'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isDesktop ? 16 : 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'dashboard'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isDesktop ? 16 : 15.sp,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}
