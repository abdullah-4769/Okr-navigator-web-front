import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../generated/models/responses/campaign/certification_info_mode.dart';
import '../../../view_model/campaign_mode/certification_info_model.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class CertificationScreen extends StatefulWidget {
  const CertificationScreen({super.key});

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  late final CertificationInfoViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = Get.find<CertificationInfoViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.fetchCertificationInfo());
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    return sw < 768
        ? _buildMobileLayout(context, sw)
        : _buildDesktopLayout(context, sw);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Obx(() => _buildBody(isDesktop: false)),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top: sh * 0.5,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 860.0 : sw * 0.78;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw, screenHeight: sh,
              title: 'your'.tr, subtitle: 'certification'.tr,
            ),
          ),
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1),
                        blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8)),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: Obx(() => _buildBody(isDesktop: true)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── SHARED BODY ────────────────────────────────────────────────────────────

  Widget _buildBody({required bool isDesktop}) {
    if (_vm.isLoading.value) return _buildLoadingState(isDesktop: isDesktop);
    if (_vm.errorMessage.value.isNotEmpty) return _buildErrorState(isDesktop: isDesktop);
    if (_vm.certificationInfo != null) return _buildContent(isDesktop: isDesktop);
    return _buildEmptyState(isDesktop: isDesktop);
  }

  // ── STATE WIDGETS ──────────────────────────────────────────────────────────

  Widget _buildLoadingState({required bool isDesktop}) {
    return Column(children: [
      if (!isDesktop) CustomHeader(
          title: 'your'.tr, highlightedText: 'achievements'.tr, onBackTap: () => Get.back()),
      SizedBox(height: isDesktop ? 40 : 50.h),
      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryRed)),
      SizedBox(height: isDesktop ? 14 : 16.h),
      Text('loading_certifications'.tr,
          style: TextStyle(fontSize: isDesktop ? 15 : 16.sp, color: AppColors.primaryRed)),
    ]);
  }

  Widget _buildErrorState({required bool isDesktop}) {
    return Column(children: [
      if (!isDesktop) CustomHeader(
          title: 'your'.tr, highlightedText: 'certification'.tr, onBackTap: () => Get.back()),
      SizedBox(height: isDesktop ? 40 : 50.h),
      Icon(Icons.error_outline, size: 64, color: AppColors.primaryRed),
      SizedBox(height: isDesktop ? 14 : 16.h),
      Text('failed_load_certifications'.tr,
          style: TextStyle(fontSize: isDesktop ? 17 : 18.sp,
              fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
      SizedBox(height: isDesktop ? 10 : 12.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 32.w),
        child: Text(_vm.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isDesktop ? 13 : 14.sp)),
      ),
      SizedBox(height: isDesktop ? 16 : 18.h),
      ElevatedButton(
        onPressed: _vm.fetchCertificationInfo,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
        child: Text('try_again'.tr),
      ),
    ]);
  }

  Widget _buildEmptyState({required bool isDesktop}) {
    return Column(children: [
      if (!isDesktop) CustomHeader(
          title: 'your'.tr, highlightedText: 'certification'.tr, onBackTap: () => Get.back()),
      SizedBox(height: isDesktop ? 40 : 50.h),
      Text('no_certification_data'.tr,
          style: TextStyle(fontSize: isDesktop ? 15 : 16.sp)),
    ]);
  }

  // ── CONTENT ────────────────────────────────────────────────────────────────

  Widget _buildContent({required bool isDesktop}) {
    final progress = _vm.certificationInfo!.progress;
    final certifications = _vm.certificationInfo!.certifications;
    final gap = isDesktop ? 28.0 : 18.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop)
          CustomHeader(title: 'your'.tr, highlightedText: 'certification'.tr,
              onBackTap: () => Get.back()),
        SizedBox(height: gap),
        _buildStatsRow(progress, isDesktop: isDesktop),
        SizedBox(height: gap),
        if (certifications.isNotEmpty) ...[
          _buildEarnedSection(certifications, isDesktop: isDesktop),
          SizedBox(height: gap),
        ],
        _buildAvailableSection(isDesktop: isDesktop),
      ],
    );
  }

  Widget _buildStatsRow(ProgressInfo progress, {required bool isDesktop}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(progress.earned.toString(), 'earned'.tr, isDesktop: isDesktop),
        _buildStatCard(progress.inProgress.toString(), 'in_progress'.tr, isDesktop: isDesktop),
        _buildStatCard(progress.total.toString(), 'available'.tr, isDesktop: isDesktop),
      ],
    );
  }

  Widget _buildStatCard(String number, String label, {required bool isDesktop}) {
    final double pad  = isDesktop ? 16 : 16.w;
    final double numF = isDesktop ? 28 : 24.sp;
    final double lblF = isDesktop ? 13 : 12.sp;

    return Container(
      padding: EdgeInsets.symmetric(vertical: pad, horizontal: pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Text(number, style: TextStyle(fontSize: numF, fontWeight: FontWeight.bold,
            color: const Color(0xff00233B))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: lblF, color: const Color(0xff00233B))),
      ]),
    );
  }

  Widget _buildEarnedSection(List<Certification> certs, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD32F2F)),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
          ),
          SizedBox(width: isDesktop ? 10 : 12),
          Text('earned_certifications'.tr,
              style: TextStyle(fontSize: isDesktop ? 18 : 18.sp,
                  fontWeight: FontWeight.bold, color: const Color(0xff00233B))),
        ]),
        SizedBox(height: isDesktop ? 20 : 30),
        // On desktop, show 2 per row
        if (isDesktop)
          Wrap(
            spacing: 16, runSpacing: 16,
            children: certs.map((c) => SizedBox(
              width: (860 - 72 - 16) / 2,
              child: _buildCertCard(c, isDesktop: true),
            )).toList(),
          )
        else
          ...certs.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCertCard(c, isDesktop: false),
          )),
      ],
    );
  }

  Widget _buildCertCard(Certification cert, {required bool isDesktop}) {
    final double fTitle = isDesktop ? 15 : 16.sp;
    final double fSub   = isDesktop ? 12 : 12.sp;
    final double fDate  = isDesktop ? 10 : 10.sp;
    final double fScore = isDesktop ? 15 : 16.sp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40, width: 40,
            child: Image.asset('assets/images/badge.png', fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD32F2F)),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(cert.title,
                      style: TextStyle(fontSize: fTitle, fontWeight: FontWeight.bold,
                          color: const Color(0xff00233B)),
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(cert.strengths, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fSub, color: const Color(0xff00233B))),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(width: 6, height: 6,
                        decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(cert.formattedDate,
                        style: TextStyle(fontSize: fDate, color: const Color(0xFFD32F2F))),
                  ]),
                  Row(children: [
                    SizedBox(height: 20, width: 20,
                      child: Image.asset('assets/images/badge.png', fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.star, color: Colors.amber, size: 16)),
                    ),
                    const SizedBox(width: 4),
                    Text(cert.formattedScore,
                        style: TextStyle(fontSize: fScore, fontWeight: FontWeight.bold,
                            color: const Color(0xff00233B))),
                  ]),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSection({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40, height: 40,
          child: Image.asset('assets/images/badge.png', fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.emoji_events, size: 40, color: Color(0xFFD32F2F))),
        ),
        SizedBox(height: isDesktop ? 14 : 16),
        Text('available_to_start'.tr,
            style: TextStyle(fontSize: isDesktop ? 18 : 18.sp,
                fontWeight: FontWeight.bold, color: const Color(0xff00233B))),
        SizedBox(height: isDesktop ? 20 : 24),
        if (isDesktop)
          Wrap(
            spacing: 16, runSpacing: 16,
            children: _vm.availableCertifications.map((c) => SizedBox(
              width: (860 - 72 - 16) / 2,
              child: _buildAvailableCard(c, isDesktop: true),
            )).toList(),
          )
        else
          ..._vm.availableCertifications.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAvailableCard(c, isDesktop: false),
          )),
      ],
    );
  }

  Widget _buildAvailableCard(Map<String, dynamic> cert, {required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffD7D7D7)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
            child: Icon(cert['icon'] as IconData, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert['title'],
                    style: TextStyle(fontSize: isDesktop ? 15 : 16.sp,
                        fontWeight: FontWeight.bold, color: const Color(0xff00233B))),
                const SizedBox(height: 4),
                Text(cert['description'], maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isDesktop ? 12 : 12.sp,
                        color: const Color(0xff00233B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import '../../../core/app_colors.dart';
// import '../../../generated/models/responses/campaign/certification_info_mode.dart';
// import '../../../view_model/campaign_mode/certification_info_model.dart';
//
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
//
// class CertificationScreen extends StatelessWidget {
//   const CertificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final CertificationInfoViewModel viewModel = Get.find<CertificationInfoViewModel>();
//
//     return Scaffold(
//         body: LayoutBuilder(
//           builder: (context, constraints) => OrientationBuilder(
//             builder: (context, orientation) {
//               return _ResponsiveCertificationScreen(
//                 constraints: constraints,
//                 orientation: orientation,
//                 viewModel: viewModel,
//               );
//             },
//           ),
//         ),
//     );
//   }
// }
// // 'your': 'Your',
// // 'certification': 'Certification',
// // 'loading_certifications': 'Loading your certifications...',
// // 'failed_load_certifications': 'Failed to load certifications',
// // 'try_again': 'Try Again',
// // 'no_certification_data': 'No certification data available',
// // 'earned_certifications': 'Earned Certifications',
// // 'earned': 'Earned',
// // 'in_progress': 'In Progress',
// // 'available': 'Available',
// // 'available_to_start': 'Available to Start',
// // 'start': 'Start',
// class _ResponsiveCertificationScreen extends StatefulWidget {
//   final BoxConstraints constraints;
//   final Orientation orientation;
//   final CertificationInfoViewModel viewModel;
//
//   const _ResponsiveCertificationScreen({
//     required this.constraints,
//     required this.orientation,
//     required this.viewModel,
//   });
//
//   @override
//   State<_ResponsiveCertificationScreen> createState() => _ResponsiveCertificationScreenState();
// }
//
// class _ResponsiveCertificationScreenState extends State<_ResponsiveCertificationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch certification data when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       widget.viewModel.fetchCertificationInfo();
//     });
//   }
//
//   // Device detection
//   double get screenWidth => widget.constraints.maxWidth;
//   double get screenHeight => widget.constraints.maxHeight;
//
//   DeviceType get deviceType {
//     if (screenWidth < 600) return DeviceType.mobile;
//     if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
//     if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
//     if (screenWidth >= 1200 && screenWidth < 1920) return DeviceType.largeDesktop;
//     return DeviceType.ultraWide;
//   }
//
//   bool get isPortrait => widget.orientation == Orientation.portrait;
//   bool get isMobile => deviceType == DeviceType.mobile;
//   bool get isWeb => deviceType == DeviceType.largeDesktop || deviceType == DeviceType.ultraWide;
//
//   // Responsive helpers
//   double getResponsiveFont({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile:
//         return mobile.sp;
//       case DeviceType.tablet:
//         return tablet.sp;
//       case DeviceType.desktop:
//         return desktop.sp;
//       case DeviceType.largeDesktop:
//         return largeDesktop.sp;
//       case DeviceType.ultraWide:
//         return ultraWide.sp;
//     }
//   }
//
//   double getResponsiveSpacing({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile:
//         return mobile.h;
//       case DeviceType.tablet:
//         return tablet.h;
//       case DeviceType.desktop:
//         return desktop;
//       case DeviceType.largeDesktop:
//         return largeDesktop;
//       case DeviceType.ultraWide:
//         return ultraWide;
//     }
//   }
//
//   double getResponsiveWidth({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile:
//         return mobile.w;
//       case DeviceType.tablet:
//         return tablet.w;
//       case DeviceType.desktop:
//         return desktop;
//       case DeviceType.largeDesktop:
//         return largeDesktop;
//       case DeviceType.ultraWide:
//         return ultraWide;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => SafeArea(
//     child: SingleChildScrollView(
//       child: Center(
//         child: Container(
//           constraints: BoxConstraints(maxWidth: isWeb ? 500 : double.infinity),
//           padding: EdgeInsets.symmetric(
//             vertical: getResponsiveSpacing(
//               mobile: 18,
//               tablet: 20,
//               desktop: 24,
//               largeDesktop: 28,
//               ultraWide: 32,
//             ),
//           ),
//           child: Obx(() {
//             if (widget.viewModel.isLoading.value) {
//               return _buildLoadingState();
//             } else if (widget.viewModel.errorMessage.value.isNotEmpty) {
//               return _buildErrorState();
//             } else if (widget.viewModel.certificationInfo != null) {
//               return _buildContent();
//             } else {
//               return _buildEmptyState();
//             }
//           }),
//         ),
//       ),
//     ),
//   );
//
//   Widget _buildLoadingState() {
//     return Column(
//       children: [
//         CustomHeader(
//           title: 'your'.tr,
//           highlightedText: 'achievements'.tr,
//           onBackTap: () => Get.back(),
//         ),
//         SizedBox(height: 50.h),
//         CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
//         ),
//         SizedBox(height: 16.h),
//         Text(
//           'loading_certifications'.tr,
//           style: TextStyle(
//             fontSize: 16.sp,
//             color: AppColors.primaryRed,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildErrorState() {
//     return Column(
//       children: [
//         CustomHeader(
//           title: 'your'.tr,
//           highlightedText: 'certification'.tr,
//           onBackTap: () => Get.back(),
//         ),
//         SizedBox(height: 50.h),
//         Icon(
//           Icons.error_outline,
//           size: 64,
//           color: AppColors.primaryRed,
//         ),
//         SizedBox(height: 16.h),
//         Text(
//           'failed_load_certifications'.tr,
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: AppColors.primaryRed,
//           ),
//         ),
//         SizedBox(height: 12.h),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 32.w),
//           child: Text(
//             widget.viewModel.errorMessage.value,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14.sp),
//           ),
//         ),
//         SizedBox(height: 18.h),
//         ElevatedButton(
//           onPressed: () => widget.viewModel.fetchCertificationInfo(),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryRed,
//             foregroundColor: Colors.white,
//           ),
//           child: Text('try_again'.tr),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Column(
//       children: [
//         CustomHeader(
//           title: 'your'.tr,
//           highlightedText: 'certification'.tr,
//           onBackTap: () => Get.back(),
//         ),
//         SizedBox(height: 50.h),
//         Text(
//           'no_certification_data'.tr,
//           style: TextStyle(fontSize: 16.sp),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildContent() {
//     final progress = widget.viewModel.certificationInfo!.progress;
//     final certifications = widget.viewModel.certificationInfo!.certifications;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CustomHeader(
//           title: 'your'.tr,
//           highlightedText: 'certification'.tr,
//           onBackTap: () => Get.back(),
//         ),
//
//         SizedBox(height: getResponsiveSpacing(mobile: 20, tablet: 35, desktop: 40, largeDesktop: 45, ultraWide: 50)),
//
//         // Stats Row
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18.0),
//           child: _buildStatsRow(progress),
//         ),
//
//         SizedBox(height: getResponsiveSpacing(mobile: 18, tablet: 35, desktop: 40, largeDesktop: 45, ultraWide: 50)),
//
//         // Earned Certifications Section
//         if (certifications.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: _buildEarnedCertificationsSection(certifications),
//           ),
//
//         if (certifications.isNotEmpty)
//           SizedBox(height: getResponsiveSpacing(mobile: 18, tablet: 35, desktop: 40, largeDesktop: 45, ultraWide: 50)),
//
//         // Available to Start Section
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18.0),
//           child: _buildAvailableToStartSection(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatsRow(ProgressInfo progress) => Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       _buildStatCard(progress.earned.toString(), 'earned'.tr, Color(0xff00233B)),
//       _buildStatCard(progress.inProgress.toString(), 'in_progress'.tr, Color(0xff00233B)),
//       _buildStatCard(progress.total.toString(), 'available'.tr, Color(0xff00233B)),
//     ],
//   );
//
//   Widget _buildStatCard(String number, String label, Color textColor) => Container(
//     padding: EdgeInsets.symmetric(
//       vertical: getResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24, largeDesktop: 28, ultraWide: 32),
//       horizontal: getResponsiveWidth(mobile: 16, tablet: 20, desktop: 24, largeDesktop: 28, ultraWide: 32),
//     ),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
//     ),
//     child: Column(
//       children: [
//         Text(
//           number,
//           style: TextStyle(
//             fontSize: getResponsiveFont(mobile: 24, tablet: 28, desktop: 32, largeDesktop: 36, ultraWide: 40),
//             fontWeight: FontWeight.bold,
//             color: textColor,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: getResponsiveFont(mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20),
//             color: Color(0xff00233B),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildEarnedCertificationsSection(List<Certification> certifications) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD32F2F)),
//             child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
//           ),
//           SizedBox(width: 12),
//           Text(
//             'earned_certifications'.tr,
//             style: TextStyle(
//               fontSize: getResponsiveFont(mobile: 18, tablet: 20, desktop: 22, largeDesktop: 24, ultraWide: 26),
//               fontWeight: FontWeight.bold,
//               color: Color(0xff00233B),
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height:30),
//       // Certification Cards
//       ...certifications.map((cert) => Column(
//         children: [
//           _buildCertificationCard(cert),
//           SizedBox(height: 16),
//         ],
//       )).toList(),
//     ],
//   );
//
//   Widget _buildCertificationCard(Certification cert) => Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Color(0xFFD32F2F).withOpacity(0.3), width: 1),
//       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
//     ),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Badge icon - Made smaller
//         Container(
//           height: 40,
//           width: 40,
//           child: Image.asset(
//             "assets/images/badge.png",
//             fit: BoxFit.contain,
//             errorBuilder: (context, error, stackTrace) => Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD32F2F)),
//               child: Icon(Icons.emoji_events, color: Colors.white, size: 20),
//             ),
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       cert.title,
//                       style: TextStyle(
//                         fontSize: getResponsiveFont(mobile: 16, tablet: 18, desktop: 20, largeDesktop: 22, ultraWide: 24),
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff00233B),
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
//                     child: Icon(Icons.check, color: Colors.white, size: 16),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 4),
//               Text(
//                 cert.strengths,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: getResponsiveFont(mobile: 12, tablet: 13, desktop: 14, largeDesktop: 15, ultraWide: 16),
//                   color: Color(0xff00233B),
//                 ),
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(width: 6, height: 6, decoration: BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle)),
//                       SizedBox(width: 6),
//                       Text(
//                         cert.formattedDate,
//                         style: TextStyle(
//                           fontSize: getResponsiveFont(mobile: 10, tablet: 11, desktop: 12, largeDesktop: 13, ultraWide: 14),
//                           color: Color(0xFFD32F2F),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         height: 20,
//                         width: 20,
//                         child: Image.asset(
//                           "assets/images/badge.png",
//                           fit: BoxFit.contain,
//                           errorBuilder: (context, error, stackTrace) => Icon(Icons.star, color: Colors.amber, size: 16),
//                         ),
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         cert.formattedScore,
//                         style: TextStyle(
//                           fontSize: getResponsiveFont(mobile: 16, tablet: 18, desktop: 20, largeDesktop: 22, ultraWide: 24),
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff00233B),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildAvailableToStartSection() => Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       // Made badge image smaller
//       Container(
//         width: 40, // Reduced from 60
//         height: 40, // Reduced from 60
//         child: Image.asset(
//           "assets/images/badge.png",
//           fit: BoxFit.contain,
//           errorBuilder: (context, error, stackTrace) => Icon(Icons.emoji_events, size: 40, color: Color(0xFFD32F2F)),
//         ),
//       ),
//       SizedBox(height: 16),
//       Text(
//         'available_to_start'.tr,
//         style: TextStyle(
//           fontSize: getResponsiveFont(mobile: 18, tablet: 20, desktop: 22, largeDesktop: 24, ultraWide: 26),
//           fontWeight: FontWeight.bold,
//           color: Color(0xff00233B),
//         ),
//       ),
//       SizedBox(height: 24),
//       ...widget.viewModel.availableCertifications.map((cert) => Column(
//         children: [
//           _buildAvailableCertificationCard(cert),
//           SizedBox(height: 16),
//         ],
//       )).toList(),
//     ],
//   );
//
//   Widget _buildAvailableCertificationCard(Map<String, dynamic> cert) => Container(
//     padding: EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       border: Border.all(color: Color(0xffD7D7D7)),
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
//     ),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle),
//           child: Icon(cert['icon'] as IconData, color: Colors.white, size: 20),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       cert['title'],
//                       style: TextStyle(
//                         fontSize: getResponsiveFont(mobile: 16, tablet: 18, desktop: 20, largeDesktop: 22, ultraWide: 24),
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff00233B),
//                       ),
//                     ),
//                   ),
//                   // Container(
//                   //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   //   decoration: BoxDecoration(color: Color(0xff24387F), borderRadius: BorderRadius.circular(20)),
//                   //   child: Text(
//                   //     'start'.tr,
//                   //     style: TextStyle(
//                   //       color: Colors.white,
//                   //       fontSize: getResponsiveFont(mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20),
//                   //       fontWeight: FontWeight.bold,
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//               SizedBox(height: 4),
//               Text(
//                 cert['description'],
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: getResponsiveFont(mobile: 12, tablet: 13, desktop: 14, largeDesktop: 15, ultraWide: 16),
//                   color: Color(0xff00233B),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// enum DeviceType { mobile, tablet, desktop, largeDesktop, ultraWide }
//
//
//
//
