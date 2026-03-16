import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/strategy_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/response/status.dart';
import '../../../services/shared_preference.dart';
import '../../../view_model/challange_view_models/show_challengers_vs_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/global_widgets/arrow_bubble_button.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  const ChallengeDetailsScreen({super.key});

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  final StorageRepository _storageRepo = Get.find<StorageRepository>();
  String? _currentUserId;
  int? _challengeId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ShowChallengersVsViewModel>()) {
      Get.delete<ShowChallengersVsViewModel>();
    }
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      _currentUserId = _storageRepo.getUserId();
      final prefs = await SharedPreferences.getInstance();
      String? idStr = prefs.getString('challengeId');
      if (idStr == null || idStr.isEmpty) idStr = prefs.getString('acceptInviteChallengeId');
      if (idStr == null || idStr.isEmpty) idStr = prefs.getString('joinChallengeId');
      if (idStr != null) _challengeId = int.tryParse(idStr);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing challenge data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    // ✅ Put controller once here, not inside build of inner widget
    final vsController = Get.put(ShowChallengersVsViewModel());
    return sw < 768
        ? _buildMobileLayout(context, sw, vsController)
        : _buildDesktopLayout(context, sw, vsController);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw,
      ShowChallengersVsViewModel vsController) {
    final double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: _buildContent(sw, sh, vsController, isDesktop: false),
                    ),
                  ),
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

  Widget _buildDesktopLayout(BuildContext context, double sw,
      ShowChallengersVsViewModel vsController) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 820.0 : sw * 0.76;

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
              title: 'start'.tr, subtitle: 'challenge'.tr,
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
                  child: _buildContent(sw, sh, vsController, isDesktop: true),
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

  // ── SHARED CONTENT ─────────────────────────────────────────────────────────

  Widget _buildContent(double sw, double sh,
      ShowChallengersVsViewModel vsController, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isDesktop)
          CustomHeader(title: 'start'.tr, highlightedText: 'challenge'.tr,
              onBackTap: () => Get.back()),
        SizedBox(height: isDesktop ? 20 : 20.h),
        _buildVSSection(vsController, isDesktop: isDesktop),
        SizedBox(height: isDesktop ? 28 : 30.h),
        // Strategy card — on desktop constrain width
        isDesktop
            ? SizedBox(
          width: 500,
          child: _buildStrategyCard(isDesktop: true),
        )
            : _buildStrategyCard(isDesktop: false),
        SizedBox(height: isDesktop ? 24 : 25.h),
        _buildStartGameButton(vsController, isDesktop: isDesktop),
      ],
    );
  }

  // ── VS SECTION ─────────────────────────────────────────────────────────────

  Widget _buildVSSection(ShowChallengersVsViewModel vsController,
      {required bool isDesktop}) {
    return Obx(() {
      final response = vsController.challengers.value;
      if (response.status == Status.loading) return _buildLoadingState(isDesktop: isDesktop);
      if (response.status == Status.error) return _buildErrorState(vsController, isDesktop: isDesktop);
      if (response.status == Status.completed) {
        final players = response.data as List<dynamic>;
        if (players.length > 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Challenge Full', 'This challenge already has 2 players',
                backgroundColor: Colors.orange, colorText: Colors.white);
            Future.delayed(const Duration(seconds: 2), () => Get.back());
          });
          return _buildFullMessage(isDesktop: isDesktop);
        }
        return _buildPlayersDisplay(players, vsController, isDesktop: isDesktop);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildLoadingState({required bool isDesktop}) {
    return Center(
      child: Column(children: [
        const CircularProgressIndicator(color: Color(0xff24387F)),
        SizedBox(height: isDesktop ? 8 : 10.h),
        Text('Loading players...',
            style: TextStyle(fontSize: isDesktop ? 13 : 14.sp, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildErrorState(ShowChallengersVsViewModel c, {required bool isDesktop}) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, color: Colors.red, size: isDesktop ? 44 : 48),
        const SizedBox(height: 8),
        Text('Error loading players',
            style: TextStyle(color: Colors.red, fontSize: isDesktop ? 13 : 14)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () { if (c.challengeId != null) c.fetchChallengePlayers(c.challengeId!); },
          child: const Text('Retry'),
        ),
      ]),
    );
  }

  Widget _buildFullMessage({required bool isDesktop}) {
    return Center(
      child: Column(children: [
        Icon(Icons.block, size: isDesktop ? 44 : 48, color: Colors.orange),
        SizedBox(height: isDesktop ? 14 : 16.h),
        Text('Challenge Full',
            style: TextStyle(fontSize: isDesktop ? 18 : 20.sp,
                fontWeight: FontWeight.bold, color: Colors.orange)),
        SizedBox(height: isDesktop ? 6 : 8.h),
        Text('This challenge already has 2 players.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isDesktop ? 13 : 14.sp, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildPlayersDisplay(List<dynamic> players,
      ShowChallengersVsViewModel vsController, {required bool isDesktop}) {
    final actual = players.where((p) => (p as Map)['isPlaceholder'] != true).toList();
    Map<String, dynamic>? host   = actual.isNotEmpty ? actual[0] as Map<String, dynamic> : null;
    Map<String, dynamic>? joined = actual.length >= 2 ? actual[1] as Map<String, dynamic> : null;

    final hostName   = host   != null ? _getPlayerName(host,   0) : 'Host';
    final joinedName = joined != null ? _getPlayerName(joined, 1) : 'Waiting...';

    final double cardW  = isDesktop ? 140 : 150.w;
    final double cardH  = isDesktop ? 160 : 180.h;
    final double vsFont = isDesktop ? 32 : 28.sp;

    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlayerCard(
              avatarUrl: host != null ? _getPlayerAvatar(host) : null,
              playerName: hostName, isHost: true,
              cardW: cardW, cardH: cardH, isDesktop: isDesktop,
            ),
            Text('Vs', style: TextStyle(fontSize: vsFont, fontWeight: FontWeight.bold,
                color: const Color(0xff24387F))),
            _buildPlayerCard(
              avatarUrl: joined != null ? _getPlayerAvatar(joined) : null,
              playerName: joinedName, isHost: false,
              cardW: cardW, cardH: cardH, isDesktop: isDesktop,
            ),
          ],
        ),
      ),
      SizedBox(height: isDesktop ? 8 : 10.h),
      Container(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 12 : 12.w, vertical: isDesktop ? 5 : 6.h),
        decoration: BoxDecoration(
          color: actual.length >= 2
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: actual.length >= 2 ? Colors.green : Colors.orange, width: 2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(actual.length >= 2 ? Icons.check_circle : Icons.hourglass_empty,
              size: isDesktop ? 14 : 16.sp,
              color: actual.length >= 2 ? Colors.green : Colors.orange),
          SizedBox(width: isDesktop ? 5 : 6.w),
          Text('Players: ${actual.length}/2',
              style: TextStyle(
                  fontSize: isDesktop ? 12 : 13.sp,
                  color: actual.length >= 2
                      ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    ]);
  }

  Widget _buildPlayerCard({
    String? avatarUrl,
    required String playerName,
    required bool isHost,
    required double cardW,
    required double cardH,
    required bool isDesktop,
  }) {
    final double avatarSz = isDesktop ? 70 : 80.sp;
    return Flexible(
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: avatarUrl != null
                  ? Image.network(avatarUrl, width: avatarSz, height: avatarSz,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(playerName, avatarSz))
                  : _buildDefaultAvatar(playerName, avatarSz),
            ),
            SizedBox(height: isDesktop ? 10 : 12.h),
            ArrowBubbleButton(level: playerName),
            if (isHost) ...[
              SizedBox(height: isDesktop ? 5 : 6.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 7 : 8.w, vertical: isDesktop ? 2 : 3.h),
                decoration: BoxDecoration(
                    color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text('Host',
                    style: TextStyle(fontSize: isDesktop ? 9 : 9.sp,
                        fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, double size) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    final color = colors[name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0];
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: Text(initials,
          style: TextStyle(color: Colors.white, fontSize: size * 0.38,
              fontWeight: FontWeight.bold))),
    );
  }

  // ── STRATEGY CARD ──────────────────────────────────────────────────────────

  Widget _buildStrategyCard({required bool isDesktop}) {
    final controller = Get.find<StrategySelectionController>();
    const double br = 20.0;
    const double sw = 4.0;

    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 24.w),
      child: CustomPaint(
        painter: _GradientBorderPainter(
          borderRadius: br, strokeWidth: sw,
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.primaryRed, AppColors.primaryRed.withOpacity(0.15)],
          ),
        ),
        child: Container(
          height: isDesktop ? 340 : 400.h,
          width: double.infinity,
          padding: const EdgeInsets.all(sw + 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(br)),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(br - sw - 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                  blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Image.asset(
                controller.selectedCardIndex.value == -1
                    ? 'assets/images/backcard_img.png'
                    : controller.strategyCardAssets[controller.selectedCardIndex.value],
                key: ValueKey<int>(controller.selectedCardIndex.value),
                height: isDesktop ? 290 : 350.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  // ── START BUTTON ───────────────────────────────────────────────────────────

  Widget _buildStartGameButton(ShowChallengersVsViewModel vsController,
      {required bool isDesktop}) {
    return Obx(() {
      final response = vsController.challengers.value;
      final players  = response.status == Status.completed
          ? (response.data as List<dynamic>) : [];
      final actual   = players.where((p) => (p as Map)['isPlaceholder'] != true).toList();
      final canStart = actual.length == 2;

      return Container(
        width: isDesktop ? 400 : double.infinity,
        margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(vertical: isDesktop ? 14 : 16.h),
        decoration: BoxDecoration(
          color: canStart ? const Color(0xffC43917) : Colors.grey,
          borderRadius: BorderRadius.circular(25),
          boxShadow: canStart
              ? [BoxShadow(color: Colors.red.withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: InkWell(
          onTap: canStart ? () => _startChallengeGame(vsController) : null,
          child: Text(
            canStart ? 'Start Game' : 'Waiting for 2nd Player... (${actual.length}/2)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 16 : 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  String _getPlayerName(Map<String, dynamic> p, int i) {
    for (final key in ['name', 'userName', 'displayName']) {
      final v = p[key]?.toString();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    return 'Player ${i + 1}';
  }

  String? _getPlayerAvatar(Map<String, dynamic> p) {
    final id = p['avatarPicId']?.toString();
    if (id == null || id.isEmpty || id == 'null') return null;
    if (id.startsWith('http')) return id;
    return 'https://okr-navigator-backend.onrender.com/uploads/$id';
  }

  void _startChallengeGame(ShowChallengersVsViewModel vsController) async {
    try {
      await SharedPrefs.saveGameMode('challenge');
      if (_challengeId != null) await SharedPrefs.saveChallengeId(_challengeId.toString());
      Future.delayed(Duration.zero, () => Get.offAllNamed(AppRoutes.roleSelection));
    } catch (e) {
      Get.snackbar('Error', 'Failed to start challenge: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;
  final Gradient gradient;

  const _GradientBorderPainter(
      {required this.borderRadius, required this.strokeWidth, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect  = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, Paint()
      ..shader = gradient.createShader(rect)
      ..style  = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}





// // challange_detail_screen.dart - SIMPLIFIED VERSION
// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../controllers/strategy_selection_controller.dart';
// import '../../../core/api_constants.dart';
// import '../../../core/app_colors.dart';
// import '../../../data/repositories/storage_repository.dart';
// import '../../../data/response/status.dart';
// import '../../../services/shared_preference.dart';
// import '../../../view_model/challange_view_models/show_challengers_vs_viewmodel.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/global_widgets/arrow_bubble_button.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
//
// class ChallengeDetailsScreen extends StatefulWidget {
//   const ChallengeDetailsScreen({super.key});
//
//   @override
//   State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
// }
//
// class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
//   final StorageRepository _storageRepo = Get.find<StorageRepository>();
//   String? _currentUserId;
//   int? _challengeId;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }
//
//   @override
//   void dispose() {
//     if (Get.isRegistered<ShowChallengersVsViewModel>()) {
//       Get.delete<ShowChallengersVsViewModel>();
//     }
//     super.dispose();
//   }
//
//   Future<void> _initializeData() async {
//     try {
//       _currentUserId = _storageRepo.getUserId();
//
//       final prefs = await SharedPreferences.getInstance();
//
//       // Get challenge ID from multiple sources
//       String? challengeIdStr = prefs.getString('challengeId');
//       if (challengeIdStr == null || challengeIdStr.isEmpty) {
//         challengeIdStr = prefs.getString('acceptInviteChallengeId');
//       }
//       if (challengeIdStr == null || challengeIdStr.isEmpty) {
//         challengeIdStr = prefs.getString('joinChallengeId');
//       }
//
//       if (challengeIdStr != null) {
//         _challengeId = int.tryParse(challengeIdStr);
//         print('✅ Loaded challenge ID: $_challengeId');
//       }
//
//       if (mounted) setState(() {});
//     } catch (e) {
//       print('❌ Error initializing challenge data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return OrientationBuilder(
//             builder: (context, orientation) {
//               return _ResponsiveChallengeDetails(
//                 constraints: constraints,
//                 orientation: orientation,
//                 currentUserId: _currentUserId,
//                 challengeId: _challengeId,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _ResponsiveChallengeDetails extends StatelessWidget {
//   final BoxConstraints constraints;
//   final Orientation orientation;
//   final String? currentUserId;
//   final int? challengeId;
//
//   const _ResponsiveChallengeDetails({
//     required this.constraints,
//     required this.orientation,
//     required this.currentUserId,
//     required this.challengeId,
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
//   bool get isWeb => deviceType == DeviceType.largeDesktop || deviceType == DeviceType.ultraWide;
//
//   double getResponsiveFont({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile: return mobile.sp;
//       case DeviceType.tablet: return tablet.sp;
//       case DeviceType.desktop: return desktop.sp;
//       case DeviceType.largeDesktop: return largeDesktop.sp;
//       case DeviceType.ultraWide: return ultraWide.sp;
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
//       case DeviceType.mobile: return mobile.h;
//       case DeviceType.tablet: return tablet.h;
//       case DeviceType.desktop: return desktop;
//       case DeviceType.largeDesktop: return largeDesktop;
//       case DeviceType.ultraWide: return ultraWide;
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
//       case DeviceType.mobile: return mobile.w;
//       case DeviceType.tablet: return tablet.w;
//       case DeviceType.desktop: return desktop;
//       case DeviceType.largeDesktop: return largeDesktop;
//       case DeviceType.ultraWide: return ultraWide;
//     }
//   }
//
//   double getResponsiveHeight({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//     double landscapeAdjustment = 1.0,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile: return mobile.h * landscapeAdjustment;
//       case DeviceType.tablet: return tablet.h * landscapeAdjustment;
//       case DeviceType.desktop: return desktop.h * landscapeAdjustment;
//       case DeviceType.largeDesktop: return largeDesktop.h * landscapeAdjustment;
//       case DeviceType.ultraWide: return ultraWide.h * landscapeAdjustment;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vsController = Get.put(ShowChallengersVsViewModel());
//
//     return Obx(() {
//       return Scaffold(
//         body: CustomBackground(
//           child: SafeArea(
//             child: SingleChildScrollView(
//               child: Center(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: isWeb ? 500 : double.infinity,
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     vertical: getResponsiveSpacing(
//                       mobile: 20,
//                       tablet: 24,
//                       desktop: 28,
//                       largeDesktop: 32,
//                       ultraWide: 36,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       CustomHeader(
//                         title: 'start'.tr,
//                         highlightedText: 'challenge'.tr,
//                         onBackTap: () => Get.back(),
//                       ),
//                       SizedBox(
//                         height: getResponsiveSpacing(
//                           mobile: 20,
//                           tablet: 25,
//                           desktop: 30,
//                           largeDesktop: 35,
//                           ultraWide: 40,
//                         ),
//                       ),
//                       _buildVSSection(),
//                       SizedBox(
//                         height: getResponsiveSpacing(
//                           mobile: 30,
//                           tablet: 35,
//                           desktop: 40,
//                           largeDesktop: 45,
//                           ultraWide: 50,
//                         ),
//                       ),
//                       Stack(
//                         children: [
//                           _buildStrategyCard(),
//                           Positioned(
//                             top: 100,
//                             left: 0,
//                             right: -18,
//                             child: CustomHomeNavBar(),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: getResponsiveSpacing(
//                           mobile: 25,
//                           tablet: 30,
//                           desktop: 35,
//                           largeDesktop: 40,
//                           ultraWide: 45,
//                         ),
//                       ),
//                       _buildStartGameButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildVSSection() {
//     final vsController = Get.find<ShowChallengersVsViewModel>();
//
//     return Obx(() {
//       final response = vsController.challengers.value;
//
//       if (response.status == Status.loading) {
//         return _buildLoadingState();
//       }
//
//       if (response.status == Status.error) {
//         return _buildErrorState(vsController);
//       }
//
//       if (response.status == Status.completed) {
//         final players = response.data as List<dynamic>;
//
//         // Check for exactly 2 players max
//         if (players.length > 2) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Get.snackbar(
//               'Challenge Full',
//               'This challenge already has 2 players',
//               backgroundColor: Colors.orange,
//               colorText: Colors.white,
//             );
//             Future.delayed(Duration(seconds: 2), () => Get.back());
//           });
//           return _buildFullChallengeMessage();
//         }
//
//         return _buildPlayersDisplay(players);
//       }
//
//       return const SizedBox.shrink();
//     });
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         children: [
//           CircularProgressIndicator(color: const Color(0xff24387F)),
//           SizedBox(height: 10.h),
//           Text(
//             'Loading players...',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorState(ShowChallengersVsViewModel vsController) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red, size: 48),
//             SizedBox(height: 8),
//             Text(
//               "Error loading players",
//               style: TextStyle(color: Colors.red, fontSize: 14),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 if (vsController.challengeId != null) {
//                   vsController.fetchChallengePlayers(vsController.challengeId!);
//                 }
//               },
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFullChallengeMessage() {
//     return Center(
//       child: Column(
//         children: [
//           Icon(Icons.block, size: 48, color: Colors.orange),
//           SizedBox(height: 16.h),
//           Text(
//             "Challenge Full",
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.orange,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 32.w),
//             child: Text(
//               "This challenge already has 2 players. Please create a new challenge or join a different one.",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPlayersDisplay(List<dynamic> players) {
//     if (players.isEmpty) {
//       return _buildWaitingForPlayers();
//     }
//
//     // Filter out placeholders to get actual player count
//     final actualPlayers = players.where((p) {
//       final player = p as Map<String, dynamic>;
//       return player['isPlaceholder'] != true;
//     }).toList();
//
//     if (kDebugMode) {
//       print('🎮 Player Display Debug:');
//       print('   Total items: ${players.length}');
//       print('   Actual players: ${actualPlayers.length}');
//     }
//
//     // Get host player (first in list)
//     Map<String, dynamic>? hostPlayer;
//     Map<String, dynamic>? joinedPlayer;
//
//     if (actualPlayers.isNotEmpty) {
//       hostPlayer = actualPlayers[0] as Map<String, dynamic>;
//     }
//     if (actualPlayers.length >= 2) {
//       joinedPlayer = actualPlayers[1] as Map<String, dynamic>;
//     }
//
//     final hostName = hostPlayer != null ? _getPlayerName(hostPlayer, 0) : 'Host';
//     final hostAvatar = hostPlayer != null ? _getPlayerAvatar(hostPlayer) : null;
//
//     final joinedName = joinedPlayer != null ? _getPlayerName(joinedPlayer, 1) : 'Waiting...';
//     final joinedAvatar = joinedPlayer != null ? _getPlayerAvatar(joinedPlayer) : null;
//
//     if (kDebugMode) {
//       print('🎮 Player Display:');
//       print('   Host: $hostName');
//       print('   Joined: $joinedName');
//     }
//
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: getResponsiveWidth(
//           mobile: 16,
//           tablet: 20,
//           desktop: 24,
//           largeDesktop: 28,
//           ultraWide: 32,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildPlayerCard(
//                 avatarUrl: hostAvatar,
//                 playerName: hostName,
//                 isHost: true,
//               ),
//               Text(
//                 'Vs',
//                 style: TextStyle(
//                   fontSize: getResponsiveFont(
//                     mobile: 28,
//                     tablet: 32,
//                     desktop: 36,
//                     largeDesktop: 40,
//                     ultraWide: 44,
//                   ),
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xff24387F),
//                   fontFamily: 'Gotham-Bold',
//                 ),
//               ),
//               _buildPlayerCard(
//                 avatarUrl: joinedAvatar,
//                 playerName: joinedName,
//                 isHost: false,
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: actualPlayers.length >= 2
//                       ? Colors.green.withOpacity(0.1)
//                       : Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: actualPlayers.length >= 2
//                         ? Colors.green
//                         : Colors.orange,
//                     width: 2,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       actualPlayers.length >= 2
//                           ? Icons.check_circle
//                           : Icons.hourglass_empty,
//                       size: 16.sp,
//                       color: actualPlayers.length >= 2
//                           ? Colors.green
//                           : Colors.orange,
//                     ),
//                     SizedBox(width: 6.w),
//                     Text(
//                       'Players: ${actualPlayers.length}/2',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: actualPlayers.length >= 2
//                             ? Colors.green.shade700
//                             : Colors.orange.shade700,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (actualPlayers.length < 2) ...[
//                 SizedBox(width: 8.w),
//                 Flexible(
//                   child: Text(
//                     'Waiting for 2nd player...',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: Colors.grey.shade600,
//                       fontStyle: FontStyle.italic,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStartGameButton() {
//     final vsController = Get.find<ShowChallengersVsViewModel>();
//     final strategyController = Get.find<StrategySelectionController>();
//
//     return Obx(() {
//       final response = vsController.challengers.value;
//       final players = response.status == Status.completed
//           ? (response.data as List<dynamic>)
//           : [];
//
//       // Count only actual players (not placeholders)
//       final actualPlayers = players.where((p) {
//         final player = p as Map<String, dynamic>;
//         return player['isPlaceholder'] != true;
//       }).toList();
//
//       final int actualPlayerCount = actualPlayers.length;
//
//       // ✅ SIMPLIFIED: Any player can start when there are 2 real players
//       final bool canStart = actualPlayerCount == 2;
//
//       String buttonText;
//       if (actualPlayerCount < 2) {
//         buttonText = 'Waiting for 2nd Player... ($actualPlayerCount/2)';
//       } else {
//         buttonText = 'Start Game';
//       }
//
//       if (kDebugMode) {
//         print('🎮 Start Button State:');
//         print('   Can Start: $canStart');
//         print('   Actual Players: $actualPlayerCount');
//       }
//
//       return Container(
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         padding: EdgeInsets.symmetric(
//           vertical: getResponsiveSpacing(
//             mobile: 16,
//             tablet: 18,
//             desktop: 20,
//             largeDesktop: 22,
//             ultraWide: 24,
//           ),
//         ),
//         decoration: BoxDecoration(
//           color: canStart ? Color(0xffC43917) : Colors.grey,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: canStart
//               ? [
//             BoxShadow(
//               color: Colors.red.withOpacity(0.3),
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ]
//               : [],
//         ),
//         child: InkWell(
//           onTap: canStart ? () => _startChallengeGame(vsController) : null,
//           child: Text(
//             buttonText,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: getResponsiveFont(
//                 mobile: 14,
//                 tablet: 16,
//                 desktop: 18,
//                 largeDesktop: 20,
//                 ultraWide: 22,
//               ),
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Gotham-Bold',
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildWaitingForPlayers() {
//     return Center(
//       child: Column(
//         children: [
//           Icon(Icons.group_off, size: 48, color: Colors.grey),
//           SizedBox(height: 8),
//           Text(
//             "Waiting for players...",
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getPlayerName(Map<String, dynamic> player, int index) {
//     final name = player['name']?.toString();
//     if (name != null && name.isNotEmpty && name != 'null') return name;
//
//     final userName = player['userName']?.toString();
//     if (userName != null && userName.isNotEmpty && userName != 'null') return userName;
//
//     final displayName = player['displayName']?.toString();
//     if (displayName != null && displayName.isNotEmpty && displayName != 'null') return displayName;
//
//     return 'Player ${index + 1}';
//   }
//
//   String? _getPlayerAvatar(Map<String, dynamic> player) {
//     final avatarPicId = player['avatarPicId']?.toString();
//
//     if (avatarPicId == null || avatarPicId.isEmpty || avatarPicId == 'null') {
//       return null;
//     }
//
//     // If it's already a full URL (Google avatar)
//     if (avatarPicId.startsWith('http')) {
//       return avatarPicId;
//     }
//
//     // Otherwise, build the URL for uploaded avatar
//     return '${ApiConstants.baseUrl}/uploads/$avatarPicId';
//   }
//
//   Widget _buildPlayerCard({
//     String? avatarUrl,
//     required String playerName,
//     bool isHost = false,
//   }) {
//     return Flexible(
//       flex: 1,
//       child: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           Container(
//             width: 150.w,
//             height: 180.h,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Avatar Image
//                 ClipOval(
//                   child: avatarUrl != null
//                       ? Image.network(
//                     avatarUrl,
//                     width: 80.sp,
//                     height: 80.sp,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => _buildDefaultAvatar(playerName),
//                   )
//                       : _buildDefaultAvatar(playerName),
//                 ),
//                 SizedBox(height: 12.h),
//                 // Player Name Badge
//                 ArrowBubbleButton(level: playerName),
//                 if (isHost) ...[
//                   SizedBox(height: 6.h),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Host',
//                       style: TextStyle(
//                         fontSize: 9.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDefaultAvatar(String playerName) {
//     final initials = playerName.isNotEmpty ? playerName[0].toUpperCase() : '?';
//     final color = _getAvatarColor(playerName);
//
//     return Container(
//       width: 80.sp,
//       height: 80.sp,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Text(
//           initials,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 32.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Color _getAvatarColor(String name) {
//     final colors = [
//       Colors.blue,
//       Colors.red,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.teal,
//       Colors.indigo,
//     ];
//     final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
//     return colors[index];
//   }
//
//   Widget _buildStrategyCard() {
//     final controller = Get.find<StrategySelectionController>();
//     const double containerBorderRadius = 20.0;
//     const double strokeWidth = 4.0;
//
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: getResponsiveWidth(
//           mobile: 24,
//           tablet: 32,
//           desktop: 40,
//           largeDesktop: 48,
//           ultraWide: 56,
//         ),
//       ),
//       child: CustomPaint(
//         painter: _GradientBorderPainter(
//           borderRadius: containerBorderRadius,
//           strokeWidth: strokeWidth,
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.primaryRed,
//               AppColors.primaryRed.withValues(alpha: 0.15),
//             ],
//           ),
//         ),
//         child: Container(
//           height: getResponsiveHeight(
//             mobile: 400,
//             tablet: 480,
//             desktop: 560,
//             largeDesktop: 620,
//             ultraWide: 680,
//             landscapeAdjustment: 0.75,
//           ),
//           width: double.infinity,
//           padding: EdgeInsets.all(strokeWidth + 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(containerBorderRadius),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(
//               getResponsiveWidth(
//                 mobile: 16,
//                 tablet: 20,
//                 desktop: 24,
//                 largeDesktop: 28,
//                 ultraWide: 32,
//               ),
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.primaryRed.withValues(alpha: 0.08),
//               borderRadius: BorderRadius.circular(
//                 containerBorderRadius - (strokeWidth + 2),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.08),
//                   blurRadius: 8,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Image.asset(
//                 controller.selectedCardIndex.value == -1
//                     ? 'assets/images/backcard_img.png'
//                     : controller.strategyCardAssets[controller.selectedCardIndex.value],
//                 key: ValueKey<int>(controller.selectedCardIndex.value),
//                 height: getResponsiveHeight(
//                   mobile: 350,
//                   tablet: 420,
//                   desktop: 480,
//                   largeDesktop: 540,
//                   ultraWide: 600,
//                   landscapeAdjustment: 0.7,
//                 ),
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _startChallengeGame(ShowChallengersVsViewModel vsController) async {
//     print('🎯 Starting challenge game flow');
//
//     try {
//       await SharedPrefs.saveGameMode('challenge');
//       print('✅ Saved game mode: challenge');
//
//       if (challengeId != null) {
//         await SharedPrefs.saveChallengeId(challengeId.toString());
//         print('✅ Challenge ID confirmed: $challengeId');
//       }
//
//       Future.delayed(Duration.zero, () {
//         Get.offAllNamed(AppRoutes.roleSelection);
//       });
//     } catch (e, st) {
//       print('❌ Error starting challenge: $e');
//       print(st);
//       Get.snackbar(
//         'Error',
//         'Failed to start challenge: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }
//
// enum DeviceType { mobile, tablet, desktop, largeDesktop, ultraWide }
//
// class _GradientBorderPainter extends CustomPainter {
//   final double borderRadius;
//   final double strokeWidth;
//   final Gradient gradient;
//
//   _GradientBorderPainter({
//     required this.borderRadius,
//     required this.strokeWidth,
//     required this.gradient,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
//
//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth;
//
//     canvas.drawRRect(rrect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }