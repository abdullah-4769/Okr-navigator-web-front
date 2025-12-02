import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/choose_industry_controller.dart';
import '../../../controllers/key_results_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/common_image.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../roles/role_selection_screen.dart';

class ChooseIndustryScreen extends StatelessWidget {
  final Map<String, dynamic>? selectedRole;
  final ChooseIndustryController controller = Get.put(ChooseIndustryController());

  ChooseIndustryScreen({super.key, this.selectedRole});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      double screenHeight = constraints.maxHeight;

      bool isMobile = screenWidth < 768;
      bool isTablet = screenWidth >= 768 && screenWidth < 1024;
      bool isDesktop = screenWidth >= 1024;

      // Responsive font helpers
      double headerFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;
      double bodyFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;
      double buttonFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;

      double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;
      double containerWidth() => isMobile
          ? screenWidth * 0.9
          : isTablet
          ? screenWidth * 0.7
          : 600;

      if (isMobile) {
        return _buildMobileLayout(context, headerFont, bodyFont, buttonFont);
      } else {
        return _buildDesktopWebLayout(
          context,
          headerFont,
          bodyFont,
          buttonFont,
          containerPadding(),
          containerWidth(),
        );
      }
     }
       );
  }

  // ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(
      BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Get.lazyPut(() => KeyResultsController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomBackground(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.d20.h),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        CustomHeader(
                          title: trKey('Choose'),
                          highlightedText: trKey('Your Industry'),
                          onBackTap: () =>
                              Get.offAllNamed(AppRoutes.roleSelection),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // 👇 Search Field
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                          ),
                          child: TextField(
                            onChanged: controller.filterIndustries,
                            decoration: InputDecoration(
                              hintText: 'search_industry'.tr,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 10.w,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // 👇 Scrollable List inside Container
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: screenWidth * 0.04,
                          ),
                          child: Container(
                            height: screenHeight * 0.45,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: AppColors.accentRed,width: 2),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Obx(() {
                              final filteredList =
                                  controller.filteredIndustries;
                              return Scrollbar(
                                radius: const Radius.circular(8),
                                child: ListView.builder(
                                  padding: EdgeInsets.all(12.w),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final industry =
                                    filteredList[index];
                                    final titleKey =
                                    industry['titleKey']?.toString();
                                    final descriptionKey = industry[
                                    'descriptionKey']
                                        ?.toString();

                                    final title = titleKey != null
                                        ? titleKey.tr
                                        : 'Choosed Industry ';
                                    final description =
                                    descriptionKey != null
                                        ? descriptionKey.tr
                                        : 'Lets Play and gets about the selected Industry';

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 8.h,
                                      ),
                                      child: Obx(() => CustomIndustryContainer(
                                        title: title,
                                        description: description,
                                        icon: industry['icon']
                                        as IconData? ??
                                            Icons.business,
                                        isSelected: controller
                                            .selectedIndex
                                            .value ==
                                            index,
                                        onTap: () =>
                                            controller.selectIndustry(
                                                index),
                                      )),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // 👇 Continue Button
                        Padding(
                          padding: EdgeInsets.symmetric(
                            // horizontal: screenWidth * 0.06,
                          ),
                          child: Column(
                            children: [
                              CustomButton2(
                                text: 'select_continue'.tr,
                                onPressed: () => controller.continueWithSelection(selectedRole),
                                width:  200.w,
                                // height: 45, ← remove or increase
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'first_time_playing'.tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: GestureDetector(
                                      onTap: controller.openTutorial,
                                      child: Text(
                                        'watch_tutorial_video'.tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          color: AppColors.primaryRed,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),                              ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 👇 Floating Home Button
              Positioned(
                right: screenWidth * -0.07,
                top: screenHeight * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
// ----------------- Desktop/Web Layout -----------------
  Widget _buildDesktopWebLayout(
      BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      double padding,
      double containerWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    Get.lazyPut(() => KeyResultsController());

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with opacity
          Positioned.fill(
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/web_background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight, title: 'choose_industry'.tr, subtitle: '',
            ),
          ),


          // Scrollable white container
          Center(
            child: Container(
              width: containerWidth,
              height: screenHeight * 0.75,
              margin: const EdgeInsets.only(top: 120),
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'welcome_role'.trParams({'role': selectedRole?['title'] ?? 'Navigator'}),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodyFont(14, 16, 18),
                        color: AppColors.primaryRed,
                        fontFamily: "GothamUltra",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() => Column(
                      children: List.generate(
                        controller.industries.length,
                            (index) {
                          final industry = controller.industries[index];
                          final title = (industry['titleKey']?.toString() ?? 'Unknown').tr;
                          final description =
                              (industry['descriptionKey']?.toString() ?? 'No description').tr;
                          return CustomIndustryContainer(
                            title: title,
                            description: description,
                            icon: industry['icon'] as IconData? ?? Icons.business,
                            isSelected: controller.selectedIndex.value == index,
                            onTap: () => controller.selectIndustry(index),
                          );
                        },
                      ),
                    )),
                    const SizedBox(height: 25),
                    CustomButton2(
                      text: 'select_continue'.tr,
                      onPressed: () => controller.continueWithSelection(selectedRole),
                      width: containerWidth * 0.4,
                      height: 45,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tutorial section - floating outside white container on left side
          Positioned(
            top: screenHeight * 0.9,
            left: 20,
            child: GestureDetector(
              onTap: controller.openTutorial,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'watch_tutorial_video'.tr,
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: bodyFont(12, 14, 16),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          /// Home Navbar
          Positioned(
            bottom: 20,
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(), // 👈 goes back to previous screen
              child: CustomSvg(
                assetPath: 'assets/images/left.svg',
                semanticsLabel: '',
              ),
            ),
          ),
          // Home Navbar at bottom middle
          Positioned(
            bottom: 20,
            left: 0,
            right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

}
