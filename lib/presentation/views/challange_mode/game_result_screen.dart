import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../core/app_colors.dart';
import '../../../generated/models/requests/challange_mode/challenge_mode_request_model.dart';
import '../../../view_model/challange_view_models/challenge_mode_view_score_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_share_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

enum ViewStatus { idle, loading, completed, error }

class GameResultScreen extends StatefulWidget {
  const GameResultScreen({super.key});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}





class _GameResultScreenState extends State<GameResultScreen> {
  final GlobalKey _shareKey = GlobalKey();

  Future<void> _shareResults() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _shareKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final png = bytes!.buffer.asUint8List();
      final dir  = await getTemporaryDirectory();
      final file = await File(
          '${dir.path}/game_results_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(png);
      if (Get.isDialogOpen ?? false) Get.back();
      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out my OKR Challenge results! 🎯',
          subject: 'OKR Challenge Game Results');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Share Failed', 'Could not share results. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final vm = Get.put(GameResultViewModel());
    return sw < 768
        ? _buildMobileLayout(context, sw, vm)
        : _buildDesktopLayout(context, sw, vm);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw, GameResultViewModel vm) {
    final double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() => SingleChildScrollView(
                  child: _buildBody(sw, sh, vm, isDesktop: false),
                )),
              ),
              Positioned(
                right: sw * -0.07, top: sh * 0.4,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, double sw, GameResultViewModel vm) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 760.0 : sw * 0.72;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(opacity: 0.1,
                child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover)),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw, screenHeight: sh,
              title: 'Challenge', subtitle: 'Game Results',
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                      blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8))],
                ),
                child: Obx(() => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: _buildBody(sw, sh, vm, isDesktop: true),
                )),
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

  Widget _buildBody(double sw, double sh, GameResultViewModel vm,
      {required bool isDesktop}) {
    if (vm.status.value == ViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.status.value == ViewStatus.error || !vm.isValidChallenge.value) {
      return _buildErrorState(vm, isDesktop: isDesktop);
    }
    final model = vm.model.value;
    if (model == null || model.results.isEmpty) {
      return _buildNoResultsState(vm, isDesktop: isDesktop);
    }
    if (!vm.isUserInChallenge) {
      return _buildNotInChallengeState(vm, isDesktop: isDesktop);
    }
    if (!vm.hasValidPlayerCount) {
      return _buildInvalidPlayerCountState(vm, model.results.length, isDesktop: isDesktop);
    }
    return _buildResultsUI(vm, model, isDesktop: isDesktop);
  }

  // ── STATE SCREENS ──────────────────────────────────────────────────────────

  Widget _buildErrorState(GameResultViewModel vm, {required bool isDesktop}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: isDesktop ? 44 : 48.sp, color: Colors.red),
          SizedBox(height: isDesktop ? 14 : 16.h),
          Text('Unable to Load Results',
              style: TextStyle(fontSize: isDesktop ? 17 : 18.sp,
                  color: Colors.red, fontWeight: FontWeight.bold)),
          SizedBox(height: isDesktop ? 6 : 8.h),
          Text(vm.message.value, textAlign: TextAlign.center,
              style: TextStyle(fontSize: isDesktop ? 13 : 14.sp,
                  color: Colors.grey.shade600)),
          SizedBox(height: isDesktop ? 14 : 16.h),
          ElevatedButton(onPressed: vm.fetchResult,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
              child: const Text('Retry')),
          SizedBox(height: isDesktop ? 6 : 8.h),
          TextButton(onPressed: () => Get.offAllNamed(AppRoutes.home),
              child: const Text('Go to Home')),
        ]),
      ),
    );
  }

  Widget _buildNoResultsState(GameResultViewModel vm, {required bool isDesktop}) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox, size: isDesktop ? 44 : 48.sp, color: Colors.grey),
        SizedBox(height: isDesktop ? 14 : 16.h),
        Text('No Results Available',
            style: TextStyle(fontSize: isDesktop ? 17 : 18.sp,
                color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('No challenge results found.'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: vm.fetchResult, child: const Text('Retry')),
      ]),
    );
  }

  Widget _buildNotInChallengeState(GameResultViewModel vm, {required bool isDesktop}) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_off, size: isDesktop ? 44 : 48.sp, color: Colors.orange),
        SizedBox(height: isDesktop ? 14 : 16.h),
        Text('Not Participating',
            style: TextStyle(fontSize: isDesktop ? 17 : 18.sp,
                color: Colors.orange, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('You are not in this challenge.', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(onPressed: () => Get.offAllNamed(AppRoutes.home),
            child: const Text('Browse Challenges')),
      ]),
    );
  }

  Widget _buildInvalidPlayerCountState(GameResultViewModel vm, int count,
      {required bool isDesktop}) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.group_off, size: isDesktop ? 44 : 48.sp, color: Colors.orange),
        SizedBox(height: isDesktop ? 14 : 16.h),
        Text('Invalid Challenge',
            style: TextStyle(fontSize: isDesktop ? 17 : 18.sp,
                color: Colors.orange, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('This challenge has $count players. Only 1–2 supported.',
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(onPressed: () => Get.offAllNamed(AppRoutes.home),
            child: const Text('Find Another Challenge')),
      ]),
    );
  }

  // ── RESULTS UI ─────────────────────────────────────────────────────────────

  Widget _buildResultsUI(GameResultViewModel vm, ChallengeModeScoreModel model,
      {required bool isDesktop}) {
    final primary  = vm.primaryPlayer!;
    final opponent = vm.opponents.isNotEmpty ? vm.opponents.first : null;
    final gap = isDesktop ? 16.0 : 14.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isDesktop)
          CustomHeader(title: 'Challenge', highlightedText: 'Game Results',
              onBackTap: () => Get.back()),
        SizedBox(height: gap),
        _buildCelebration(isDesktop: isDesktop),
        SizedBox(height: gap),
        _buildTitle(isDesktop: isDesktop),
        SizedBox(height: gap),

        // Shareable card
        RepaintBoundary(
          key: _shareKey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                  blurRadius: 10, offset: const Offset(0, 4))],
            ),
            margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildScoreSection(primary, opponent, isDesktop: isDesktop),
              SizedBox(height: isDesktop ? 24 : 20.h),
              _buildDetailsSection(primary, opponent, isDesktop: isDesktop),
            ]),
          ),
        ),

        SizedBox(height: isDesktop ? 20 : 20.h),
        Center(child: CustomShareButton(onPressed: _shareResults)),
        SizedBox(height: isDesktop ? 14 : 16.h),
        Center(
          child: isDesktop
              ? SizedBox(width: 280,
              child: CustomButton(text: 'Back To Home',
                  onPressed: () => Get.toNamed(AppRoutes.home)))
              : CustomButton(text: 'Back To Home',
              onPressed: () => Get.toNamed(AppRoutes.home)),
        ),
        SizedBox(height: isDesktop ? 16 : 40.h),
      ],
    );
  }

  Widget _buildCelebration({required bool isDesktop}) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 14 : 16.h),
      decoration: const BoxDecoration(color: Color(0xffFFEEEA), shape: BoxShape.circle),
      child: Text('🎉',
          style: TextStyle(fontSize: isDesktop ? 40 : 36.sp)),
    );
  }

  Widget _buildTitle({required bool isDesktop}) {
    return Column(children: [
      Text('Victory!', style: TextStyle(fontSize: isDesktop ? 24 : 20.sp,
          fontWeight: FontWeight.bold)),
      SizedBox(height: isDesktop ? 5 : 6.h),
      Text('Challenge results', style: TextStyle(color: Colors.grey.shade600)),
    ]);
  }

  Widget _buildScoreSection(ChallengeModeScoreResult primary,
      ChallengeModeScoreResult? opponent, {required bool isDesktop}) {
    return Column(children: [
      Text('Final Scores', style: TextStyle(fontSize: isDesktop ? 17 : 18.sp,
          fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
      SizedBox(height: isDesktop ? 14 : 16.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _playerScoreCard(primary,
              isWinner: primary.score >= (opponent?.score ?? 0), isDesktop: isDesktop),
          _playerScoreCard(opponent,
              isWinner: opponent != null && opponent.score > primary.score,
              isDesktop: isDesktop),
        ],
      ),
    ]);
  }

  Widget _playerScoreCard(ChallengeModeScoreResult? player,
      {required bool isWinner, required bool isDesktop}) {
    if (player == null) {
      return Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('No player', style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 12 : 12.sp), textAlign: TextAlign.center),
        SizedBox(height: isDesktop ? 6 : 8.h),
        Text('-', style: TextStyle(fontSize: isDesktop ? 13 : 14.sp)),
      ]));
    }
    final double avatarR = isDesktop ? 28 : 30.h;
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: isWinner ? const Color(0xffFFC107) : Colors.grey.shade400, width: 3),
          ),
          child: CircleAvatar(
            radius: avatarR,
            backgroundImage: const AssetImage('assets/images/solo_image.png'),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        SizedBox(height: isDesktop ? 6 : 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 10 : 8.h,
              vertical: isDesktop ? 5 : 6.h),
          constraints: BoxConstraints(minWidth: isDesktop ? 50 : 40.h),
          decoration: BoxDecoration(
            color: isWinner ? const Color(0xffFFC107) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(player.score.toString(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 16 : 14.sp),
              textAlign: TextAlign.center),
        ),
        SizedBox(height: isDesktop ? 6 : 8.h),
        Text(player.name,
            style: TextStyle(fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: isDesktop ? 12 : 12.sp),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: isDesktop ? 3 : 4.h),
        Text(player.position,
            style: TextStyle(color: Colors.grey.shade600, fontSize: isDesktop ? 10 : 10.sp),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildDetailsSection(ChallengeModeScoreResult? primary,
      ChallengeModeScoreResult? opponent, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 15 : 16.sp, color: AppColors.primaryBlue)),
        const SizedBox(height: 16),
        if (primary != null) ...[
          _perfRow('Alignment Strategy', primary.alignmentStrategy, isDesktop: isDesktop),
          _perfRow('Objective Clarity', primary.objectiveClarity, isDesktop: isDesktop),
          _perfRow('Key Result Quality', primary.keyResultQuality, isDesktop: isDesktop),
          _perfRow('Initiative Relevance', primary.initiativeRelevance, isDesktop: isDesktop),
          _perfRow('Challenge Adoption', primary.challengeAdoption, isDesktop: isDesktop),
          if ((primary.keyResultQualityLog ?? '').isNotEmpty)
            _perfNotes(primary.keyResultQualityLog!, isDesktop: isDesktop),
        ],
        const SizedBox(height: 16),
        if (opponent != null) ...[
          Divider(color: Colors.grey.shade300),
          Text('Opponent Performance',
              style: TextStyle(fontWeight: FontWeight.w600,
                  fontSize: isDesktop ? 13 : 14.sp, color: Colors.grey.shade700)),
          SizedBox(height: isDesktop ? 6 : 8.h),
          Text('Score: ${opponent.score}'),
          Text('Position: ${opponent.position}'),
        ],
      ],
    );
  }

  Widget _perfRow(String label, double? value, {required bool isDesktop}) {
    final double fs = isDesktop ? 12 : 12.sp;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 3 : 4.h),
      child: Row(children: [
        Expanded(flex: 2, child: Text('$label:',
            style: TextStyle(fontSize: fs, color: Colors.grey.shade700))),
        Expanded(flex: 1, child: Text(value?.toStringAsFixed(1) ?? '-',
            style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600,
                color: _scoreColor(value)),
            textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _perfNotes(String notes, {required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Key Result Notes:',
            style: TextStyle(fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 12 : 12.sp, color: Colors.grey.shade700)),
        SizedBox(height: isDesktop ? 3 : 4.h),
        Text(notes, style: TextStyle(fontSize: isDesktop ? 11 : 11.sp,
            color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Color _scoreColor(double? s) {
    if (s == null) return Colors.grey;
    if (s >= 8.0) return Colors.green;
    if (s >= 6.0) return Colors.orange;
    return Colors.red;
  }
}








// // lib/presentation/views/challange_mode/game_result_screen.dart
// import 'dart:typed_data'; // ✅ CORRECT: Use this instead of the internal library
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'dart:ui' as ui;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'dart:io';
//
// import '../../../core/app_colors.dart';
// import '../../../generated/models/requests/challange_mode/challenge_mode_request_model.dart';
// import '../../../view_model/challange_view_models/challenge_mode_view_score_model.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/custom_share_button.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
//
// // Add ViewStatus enum here since it's missing
// enum ViewStatus { idle, loading, completed, error }
//
// class GameResultScreen extends StatelessWidget {
//   const GameResultScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     body: CustomBackground(
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return OrientationBuilder(
//             builder: (context, orientation) {
//               return _ResponsiveGameResult(
//                 constraints: constraints,
//                 orientation: orientation,
//               );
//             },
//           );
//         },
//       ),
//     ),
//   );
// }
//
// class _ResponsiveGameResult extends StatelessWidget {
//   final BoxConstraints constraints;
//   final Orientation orientation;
//   final GlobalKey _shareableContentKey = GlobalKey();
//   // ✅ ADD THIS SHARE METHOD
//   Future<void> _shareResults() async {
//     try {
//       // Show loading indicator
//       Get.dialog(
//         const Center(
//           child: CircularProgressIndicator(),
//         ),
//         barrierDismissible: false,
//       );
//
//       // Wait for the next frame to ensure widget is rendered
//       await Future.delayed(const Duration(milliseconds: 100));
//
//       // Capture the widget as an image
//       final RenderRepaintBoundary boundary = _shareableContentKey.currentContext!
//           .findRenderObject() as RenderRepaintBoundary;
//       final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       final Uint8List pngBytes = byteData!.buffer.asUint8List();
//
//       // Save to temporary file
//       final tempDir = await getTemporaryDirectory();
//       final file = await File('${tempDir.path}/game_results_${DateTime.now().millisecondsSinceEpoch}.png').create();
//       await file.writeAsBytes(pngBytes);
//
//       // Close loading dialog
//       Get.back();
//
//       // Share the image
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'Check out my OKR Challenge results! 🎯',
//         subject: 'OKR Challenge Game Results',
//       );
//
//     } catch (e) {
//       // Close loading dialog if still open
//       if (Get.isDialogOpen ?? false) Get.back();
//
//       Get.snackbar(
//         'Share Failed',
//         'Could not share results. Please try again.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       print('Error sharing results: $e');
//     }
//   }
//    _ResponsiveGameResult({
//     required this.constraints,
//     required this.orientation,
//   });
//
//   double get screenWidth => constraints.maxWidth;
//   double get screenHeight => constraints.maxHeight;
//
//   DeviceType get deviceType {
//     if (screenWidth < 600) return DeviceType.mobile;
//     if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
//     if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
//     if (screenWidth >= 1200 && screenWidth < 1920) return DeviceType.largeDesktop;
//     return DeviceType.ultraWide;
//   }
//
//      bool get isDesktop =>
//       deviceType == DeviceType.desktop ||
//           deviceType == DeviceType.largeDesktop ||
//           deviceType == DeviceType.ultraWide;
//
//      double getResponsiveFont({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//       }) {
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
//
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
//   //
//   // // ✅ ADD: Global key for capturing the shareable content
//   // final GlobalKey _shareableContentKey = GlobalKey();
//   //
//   // // ✅ ADD: Method to capture and share the results
//   // Future<void> _shareResults() async {
//   //   try {
//   //     // Show loading indicator
//   //     Get.dialog(
//   //       const Center(
//   //         child: CircularProgressIndicator(),
//   //       ),
//   //       barrierDismissible: false,
//   //     );
//   //
//   //     // Wait for the next frame to ensure widget is rendered
//   //     await Future.delayed(const Duration(milliseconds: 100));
//   //
//   //     // Capture the widget as an image
//   //     final RenderRepaintBoundary boundary = _shareableContentKey.currentContext!
//   //         .findRenderObject() as RenderRepaintBoundary;
//   //     final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//   //     final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//   //     final Uint8List pngBytes = byteData!.buffer.asUint8List();
//   //
//   //     // Save to temporary file
//   //     final tempDir = await getTemporaryDirectory();
//   //     final file = await File('${tempDir.path}/game_results_${DateTime.now().millisecondsSinceEpoch}.png').create();
//   //     await file.writeAsBytes(pngBytes);
//   //
//   //     // Close loading dialog
//   //     Get.back();
//   //
//   //     // Share the image
//   //     await Share.shareXFiles(
//   //       [XFile(file.path)],
//   //       text: 'Check out my OKR Challenge results! 🎯\n\nI scored high in strategic alignment and objective clarity!',
//   //       subject: 'OKR Challenge Game Results',
//   //     );
//   //
//   //   } catch (e) {
//   //     // Close loading dialog if still open
//   //     if (Get.isDialogOpen ?? false) Get.back();
//   //
//   //     Get.snackbar(
//   //       'Share Failed',
//   //       'Could not share results. Please try again.',
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //     );
//   //     print('Error sharing results: $e');
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = Get.put(GameResultViewModel());
//
//     return SafeArea(
//       child: Obx(() {
//         // Handle loading state
//         if (vm.status.value == ViewStatus.loading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         // Handle error state
//         if (vm.status.value == ViewStatus.error || !vm.isValidChallenge.value) {
//           return _buildErrorState(vm);
//         }
//
//         // Handle completed state with validation
//         final model = vm.model.value;
//         if (model == null || model.results.isEmpty) {
//           return _buildNoResultsState(vm);
//         }
//
//         // Validate user participation
//         if (!vm.isUserInChallenge) {
//           return _buildNotInChallengeState(vm);
//         }
//
//         // Validate player count
//         if (!vm.hasValidPlayerCount) {
//           return _buildInvalidPlayerCountState(vm, model.results.length);
//         }
//
//         // Show results_buildResultsUI
//         return _buildResultsUI(vm, model);
//       }),
//     );
//   }
//
//   Widget _buildErrorState(GameResultViewModel vm) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
//             SizedBox(height: 16.h),
//             Text(
//                 'Unable to Load Results',
//                 style: TextStyle(fontSize: 18.sp, color: Colors.red, fontWeight: FontWeight.bold)
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               vm.message.value,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16.h),
//             ElevatedButton(
//               onPressed: vm.fetchResult,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryRed,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Retry'),
//             ),
//             SizedBox(height: 8.h),
//             TextButton(
//               onPressed: () => Get.offAllNamed(AppRoutes.home),
//               child: const Text('Go to Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNotInChallengeState(GameResultViewModel vm) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.person_off, size: 48.sp, color: Colors.orange),
//             SizedBox(height: 16.h),
//             Text(
//                 'Not Participating',
//                 style: TextStyle(fontSize: 18.sp, color: Colors.orange, fontWeight: FontWeight.bold)
//             ),
//             SizedBox(height: 8.h),
//             const Text(
//               'You are not participating in this challenge or the challenge has ended.',
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16.h),
//             TextButton(
//               onPressed: () => Get.offAllNamed(AppRoutes.home),
//               child: const Text('Browse Challenges'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInvalidPlayerCountState(GameResultViewModel vm, int playerCount) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.group_off, size: 48.sp, color: Colors.orange),
//             SizedBox(height: 16.h),
//             Text(
//                 'Invalid Challenge',
//                 style: TextStyle(fontSize: 18.sp, color: Colors.orange, fontWeight: FontWeight.bold)
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'This challenge has $playerCount players. Only challenges with 1-2 players are supported.',
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16.h),
//             TextButton(
//               onPressed: () => Get.offAllNamed(AppRoutes.home),
//               child: const Text('Find Another Challenge'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoResultsState(GameResultViewModel vm) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.inbox, size: 48.sp, color: Colors.grey),
//             SizedBox(height: 16.h),
//             Text(
//                 'No Results Available',
//                 style: TextStyle(fontSize: 18.sp, color: Colors.grey, fontWeight: FontWeight.bold)
//             ),
//             SizedBox(height: 8.h),
//             const Text('No challenge results found for this user.'),
//             SizedBox(height: 16.h),
//             ElevatedButton(
//               onPressed: vm.fetchResult,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildResultsUI(GameResultViewModel vm, ChallengeModeScoreModel model) {
//     final primary = vm.primaryPlayer!;
//     final opponent = vm.opponents.isNotEmpty ? vm.opponents.first : null;
//
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Center(
//             child: Container(
//               constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
//               padding: EdgeInsets.symmetric(
//                 vertical: getResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28, largeDesktop: 32, ultraWide: 36),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CustomHeader(
//                     title: 'Challenge',
//                     highlightedText: 'Game Results',
//                     onBackTap: () { Get.back(); },
//                   ),
//                   SizedBox(height: getResponsiveSpacing(mobile: 12, tablet: 14, desktop: 18, largeDesktop: 20, ultraWide: 24)),
//                   _buildCelebrationSection(),
//                   SizedBox(height: getResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20)),
//                   _buildTitleSection(),
//                   SizedBox(height: getResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20)),
//
//                   // ✅ ADD REPAINT BOUNDARY HERE - Wrap the content you want to share
//                   RepaintBoundary(
//                     key: _shareableContentKey,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       margin: const EdgeInsets.symmetric(horizontal: 16),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           // This is the content that will be captured for sharing
//                           _buildScoreSection(primary, opponent),
//                           SizedBox(height: getResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28, largeDesktop: 32, ultraWide: 36)),
//                           _buildDetailsSection(primary, opponent),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: getResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28, largeDesktop: 32, ultraWide: 36)),
//
//                   // Share button
//                   Center(
//                     child: CustomShareButton(
//                       onPressed: _shareResults,
//                     ),
//                   ),
//
//                   SizedBox(height: getResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20, largeDesktop: 22, ultraWide: 24)),
//
//                   Center(
//                     child: CustomButton(
//                       text: 'Back To Home',
//                       onPressed: () {
//                         Get.toNamed(AppRoutes.home);
//                       },
//                     ),
//                   ),
//
//                   SizedBox(height: getResponsiveSpacing(mobile: 40, tablet: 50, desktop: 60, largeDesktop: 70, ultraWide: 80)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         // Home NavBar
//         Positioned(
//           right: screenWidth * -0.07,
//           top: screenHeight * 0.4,
//           child: const CustomHomeNavBar(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCelebrationSection() {
//     return Container(
//       padding: EdgeInsets.all(getResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20, largeDesktop: 24, ultraWide: 28)),
//       decoration: const BoxDecoration(color: Color(0xffFFEEEA), shape: BoxShape.circle),
//       child: Text(
//           '🎉',
//           style: TextStyle(fontSize: getResponsiveFont(
//               mobile: 36, tablet: 40, desktop: 48, largeDesktop: 56, ultraWide: 64
//           ))
//       ),
//     );
//   }
//
//   Widget _buildTitleSection() {
//     return Column(
//       children: [
//         Text(
//           'Victory!',
//           style: TextStyle(
//               fontSize: getResponsiveFont(mobile: 20, tablet: 22, desktop: 26, largeDesktop: 30, ultraWide: 34),
//               fontWeight: FontWeight.bold
//           ),
//         ),
//         SizedBox(height: getResponsiveSpacing(mobile: 6, tablet: 8, desktop: 10, largeDesktop: 12, ultraWide: 14)),
//         Text(
//           'Challenge results',
//           style: TextStyle(color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildScoreSection(ChallengeModeScoreResult primary, ChallengeModeScoreResult? opponent) {
//     return Column(
//       children: [
//         Text(
//           'Final Scores',
//           style: TextStyle(
//             fontSize: getResponsiveFont(mobile: 18, tablet: 20, desktop: 22, largeDesktop: 24, ultraWide: 26),
//             fontWeight: FontWeight.bold,
//             color: AppColors.primaryRed,
//           ),
//         ),
//         SizedBox(height: getResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20, largeDesktop: 22, ultraWide: 24)),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _playerScoreCard(primary, isWinner: primary.score >= (opponent?.score ?? 0)),
//             _playerScoreCard(opponent, isWinner: opponent != null && (opponent.score > primary.score)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _playerScoreCard(ChallengeModeScoreResult? player, {required bool isWinner}) {
//     if (player == null) {
//       return Expanded(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'No player',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: getResponsiveFont(
//                     mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20
//                 ),
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               '-',
//               style: TextStyle(
//                 fontSize: getResponsiveFont(
//                     mobile: 14, tablet: 16, desktop: 18, largeDesktop: 20, ultraWide: 22
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Expanded(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: isWinner ? const Color(0xffFFC107) : Colors.grey.shade400,
//                 width: 3,
//               ),
//             ),
//             child: CircleAvatar(
//               radius: getResponsiveSpacing(
//                   mobile: 30, tablet: 35, desktop: 40, largeDesktop: 45, ultraWide: 50
//               ),
//               backgroundImage: const AssetImage('assets/images/solo_image.png'),
//               backgroundColor: Colors.grey.shade200,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: getResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12, largeDesktop: 14, ultraWide: 16),
//               vertical: getResponsiveSpacing(mobile: 6, tablet: 7, desktop: 8, largeDesktop: 9, ultraWide: 10),
//             ),
//             constraints: BoxConstraints(
//               minWidth: getResponsiveSpacing(mobile: 40, tablet: 50, desktop: 60, largeDesktop: 70, ultraWide: 80),
//             ),
//             decoration: BoxDecoration(
//               color: isWinner ? const Color(0xffFFC107) : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Text(
//               player.score.toString(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: getResponsiveFont(
//                     mobile: 14, tablet: 16, desktop: 18, largeDesktop: 20, ultraWide: 22
//                 ),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             player.name,
//             style: TextStyle(
//               fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
//               fontSize: getResponsiveFont(
//                   mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20
//               ),
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             player.position,
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: getResponsiveFont(
//                   mobile: 10, tablet: 12, desktop: 14, largeDesktop: 16, ultraWide: 18
//               ),
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailsSection(ChallengeModeScoreResult? primary, ChallengeModeScoreResult? opponent) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Performance Breakdown',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: getResponsiveFont(
//                 mobile: 16, tablet: 18, desktop: 20, largeDesktop: 22, ultraWide: 24
//             ),
//             color: AppColors.primaryBlue,
//           ),
//         ),
//         const SizedBox(height: 16),
//         if (primary != null) ...[
//           _buildPerformanceRow('Alignment Strategy', primary.alignmentStrategy),
//           _buildPerformanceRow('Objective Clarity', primary.objectiveClarity),
//           _buildPerformanceRow('Key Result Quality', primary.keyResultQuality),
//           _buildPerformanceRow('Initiative Relevance', primary.initiativeRelevance),
//           _buildPerformanceRow('Challenge Adoption', primary.challengeAdoption),
//           if ((primary.keyResultQualityLog ?? '').isNotEmpty)
//             _buildPerformanceNotes(primary.keyResultQualityLog!),
//         ],
//         const SizedBox(height: 16),
//         if (opponent != null) ...[
//           Divider(color: Colors.grey.shade300),
//           Text(
//             'Opponent Performance',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: getResponsiveFont(
//                   mobile: 14, tablet: 16, desktop: 18, largeDesktop: 20, ultraWide: 22
//               ),
//               color: Colors.grey.shade700,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text('Score: ${opponent.score}'),
//           Text('Position: ${opponent.position}'),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildPerformanceRow(String label, double? value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontSize: getResponsiveFont(
//                     mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20
//                 ),
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Text(
//               value?.toStringAsFixed(1) ?? '-',
//               style: TextStyle(
//                 fontSize: getResponsiveFont(
//                     mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20
//                 ),
//                 fontWeight: FontWeight.w600,
//                 color: _getScoreColor(value),
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPerformanceNotes(String notes) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Key Result Notes:',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: getResponsiveFont(
//                   mobile: 12, tablet: 14, desktop: 16, largeDesktop: 18, ultraWide: 20
//               ),
//               color: Colors.grey.shade700,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             notes,
//             style: TextStyle(
//               fontSize: getResponsiveFont(
//                   mobile: 11, tablet: 13, desktop: 15, largeDesktop: 17, ultraWide: 19
//               ),
//               color: Colors.grey.shade600,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getScoreColor(double? score) {
//     if (score == null) return Colors.grey;
//     if (score >= 8.0) return Colors.green;
//     if (score >= 6.0) return Colors.orange;
//     return Colors.red;
//   }
// }
//
// enum DeviceType { mobile, tablet, desktop, largeDesktop, ultraWide }
