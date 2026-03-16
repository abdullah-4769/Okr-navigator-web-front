import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:game_app/presentation/widgets/bubble_button.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/api_constants.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../services/shared_preference.dart';
import '../../../view_model/bonus_controller/bonus_controller.dart';
import '../../widgets/custom_svg.dart';
import '../authentication/profile_screen.dart';
import '../notification/notification_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Breakpoints
// ─────────────────────────────────────────────────────────────────────────────
bool _isMobile(double sw)  => sw < 768;
bool _isTablet(double sw)  => sw >= 768 && sw < 1024;
bool _isDesktop(double sw) => sw >= 1024;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  late final HomeController c;

  final RxBool   _isBonusLoading = false.obs;
  final RxString _userAvatarUrl  = ''.obs;

  // Dedicated horizontal PageController for desktop — never recreated
  late final PageController _desktopPageCtrl;

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _topBarCtrl;
  late AnimationController _certCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _dashCtrl;
  late AnimationController _robotCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _notifBlinkCtrl;

  late Animation<Offset> _topBarSlide;
  late Animation<double> _topBarFade;
  late Animation<double> _certScale;
  late Animation<double> _certFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _cardsFade;
  late Animation<Offset> _dashSlide;
  late Animation<double> _dashFade;
  late Animation<double> _robotBounce;
  late Animation<double> _blink;
  late Animation<double> _notifBlink;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(), permanent: true);

    // Desktop controller — viewportFraction shows adjacent cards
    _desktopPageCtrl = PageController(viewportFraction: 0.72, initialPage: 0);

    _clearGameData();
    _loadUserAvatar();
    _listenAvatarChanges();
    _initAnims();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnims());
  }

  @override
  void dispose() {
    _topBarCtrl.dispose();
    _certCtrl.dispose();
    _cardsCtrl.dispose();
    _dashCtrl.dispose();
    _robotCtrl.dispose();
    _blinkCtrl.dispose();
    _notifBlinkCtrl.dispose();
    _desktopPageCtrl.dispose();
    super.dispose();
  }

  // ── Animations ─────────────────────────────────────────────────────────────
  void _initAnims() {
    _topBarCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _certCtrl       = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _cardsCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _dashCtrl       = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _robotCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _blinkCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _notifBlinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _topBarSlide  = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeOutCubic));
    _topBarFade   = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeIn));
    _certScale    = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _certCtrl, curve: Curves.elasticOut));
    _certFade     = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _certCtrl, curve: Curves.easeIn));
    _cardsSlide   = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOutCubic));
    _cardsFade    = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeIn));
    _dashSlide    = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _dashCtrl, curve: Curves.easeOutCubic));
    _dashFade     = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _dashCtrl, curve: Curves.easeIn));
    _robotBounce  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _robotCtrl, curve: Curves.bounceOut));
    _blink        = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut));
    _notifBlink   = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _notifBlinkCtrl, curve: Curves.easeInOut));
  }

  void _startAnims() {
    _topBarCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _certCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) { _cardsCtrl.forward(); _robotCtrl.forward(); }
    });
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _dashCtrl.forward(); });
  }

  // ── Data helpers ───────────────────────────────────────────────────────────
  Future<void> _clearGameData() async {
    try { await SharedPrefs.clearGameSessionData(); } catch (_) {}
  }

  void _listenAvatarChanges() {
    GetStorage().listenKey('user-data', (_) => _loadUserAvatar());
  }

  void _loadUserAvatar() {
    try {
      final raw = GetStorage().read('user-data');
      if (raw == null) return;
      final Map<String, dynamic> data = raw is String
          ? jsonDecode(raw)
          : Map<String, dynamic>.from(raw as Map);
      final avatarId = data['avatarPicId']?.toString() ?? '';
      if (avatarId.isEmpty) return;
      if (avatarId.startsWith('http') ||
          avatarId.startsWith('assets/') ||
          avatarId.startsWith('lib/')) {
        _userAvatarUrl.value = avatarId;
      } else {
        _userAvatarUrl.value = '${ApiConstants.baseUrl}/uploads/$avatarId';
      }
    } catch (_) {}
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('assets/') || path.startsWith('lib/')) return AssetImage(path);
    if (path.startsWith('http')) return NetworkImage(path);
    return NetworkImage('${ApiConstants.baseUrl}/uploads/$path');
  }

  Color _badgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'gold':   return Colors.amber;
      case 'silver': return Colors.grey.shade400;
      case 'bronze': return Colors.brown;
      default:       return Colors.blueGrey;
    }
  }

  // ── Bonus ──────────────────────────────────────────────────────────────────
  Future<void> _onBonusTap() async {
    _isBonusLoading.value = true;
    try {
      final controller = Get.isRegistered<BonusModeController>()
          ? Get.find<BonusModeController>()
          : Get.put(BonusModeController());

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
        barrierDismissible: false,
      );
      await controller.checkPlayedToday();
      Get.back();

      if (controller.hasPlayedToday.value) {
        _showAlreadyPlayedDialog(controller);
        return;
      }
      await SharedPrefs.saveGameMode('bonus');
      await SharedPrefs.clearGameSessionData();
      Get.toNamed(AppRoutes.roleSelection, arguments: {'fromBonus': true});
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('error'.tr, '${'failed_start_bonus'.tr}$e');
    } finally {
      _isBonusLoading.value = false;
    }
  }

  void _showAlreadyPlayedDialog(BonusModeController ctrl) {
    final sw = Get.width;
    final double dialogW = _isDesktop(sw) ? 400.0 : _isTablet(sw) ? 360.0 : sw * 0.88;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: dialogW,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('daily_bonus_complete'.tr,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ]),
              const SizedBox(height: 14),
              Text('already_played_today'.tr,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Text('your_score_today'.tr,
                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Obx(() => Text('${ctrl.evaluationScore.value}',
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(height: 6),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: _badgeColor(ctrl.badgeName.value),
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(ctrl.badgeName.value.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              Text('come_back_tomorrow'.tr,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('ok'.tr,
                      style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return OrientationBuilder(
      builder: (context, _) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _isDesktop(sw)
              ? BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/web_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.15), BlendMode.dstATop),
            ),
          )
              : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            ),
          ),
          child: SafeArea(
            child: _isDesktop(sw)
                ? _buildDesktopLayout(sw, sh)
                : _buildMobileTabletLayout(sw, sh),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT — two-column: left sidebar + right content
  // ==========================================================================
  Widget _buildDesktopLayout(double sw, double sh) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // ── Top bar ──
          SlideTransition(
            position: _topBarSlide,
            child: FadeTransition(opacity: _topBarFade, child: _topBar(sw)),
          ),
          const SizedBox(height: 16),

          // ── Main content ──
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── LEFT: Robot + Bonus + Certificate ──
                SizedBox(
                  width: sw * 0.18,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Certificate button
                      ScaleTransition(
                        scale: _certScale,
                        child: FadeTransition(
                          opacity: _certFade,
                          child: CustomBubbleButton(
                            text: 'certificate'.tr,
                            width: 130,
                            height: 38,
                            onTap: () => Get.toNamed(AppRoutes.certificationScreen),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Robot + Bonus
                      SlideTransition(
                        position: _cardsSlide,
                        child: FadeTransition(
                          opacity: _cardsFade,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_robotBounce, _blink]),
                            builder: (_, __) => Transform.translate(
                              offset: Offset(0, -8 * _robotBounce.value),
                              child: Opacity(
                                opacity: _blink.value,
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/robortarrow.png',
                                      height: sh * 0.18,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 12),
                                    _bonusButton(sw),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ── CENTER: Cards ──
                Expanded(
                  child: SlideTransition(
                    position: _cardsSlide,
                    child: FadeTransition(
                      opacity: _cardsFade,
                      child: _desktopCardArea(sw, sh),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ── RIGHT: Dashboard button ──
                SizedBox(
                  width: sw * 0.08,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _dashSlide,
                        child: FadeTransition(
                          opacity: _dashFade,
                          child: _dashboardButton(context, sw),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ==========================================================================
  // MOBILE / TABLET LAYOUT
  // ==========================================================================
  Widget _buildMobileTabletLayout(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.d8.w),
      child: Column(
        children: [
          SizedBox(height: AppDimensions.d26.h),

          // Top bar
          SlideTransition(
            position: _topBarSlide,
            child: FadeTransition(opacity: _topBarFade, child: _topBar(sw)),
          ),
          SizedBox(height: AppDimensions.d12.h),

          // Certificate button
          ScaleTransition(
            scale: _certScale,
            child: FadeTransition(
              opacity: _certFade,
              child: Center(
                child: CustomBubbleButton(
                  text: 'certificate'.tr,
                  width: _isTablet(sw) ? 120 : 90,
                  height: _isTablet(sw) ? 38 : 30,
                  onTap: () => Get.toNamed(AppRoutes.certificationScreen),
                ),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.d18.h),

          // Cards + robot
          Expanded(
            child: SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: _mobileCardView(sw, sh),
              ),
            ),
          ),

          // Dashboard button
          SlideTransition(
            position: _dashSlide,
            child: FadeTransition(
              opacity: _dashFade,
              child: _dashboardButton(context, sw),
            ),
          ),
          SizedBox(height: AppDimensions.d16.h),
        ],
      ),
    );
  }

  // ==========================================================================
  // TOP BAR
  // ==========================================================================
  Widget _topBar(double sw) {
    final iconSize   = _isDesktop(sw) ? 20.0 : 22.sp;
    final circleSize = _isDesktop(sw) ? 40.0 : 40.sp;
    final gap        = _isDesktop(sw) ? 10.0 : 12.w;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomSvg(
          assetPath: 'assets/images/okrnev.svg',
          semanticsLabel: 'OKR',
          height: _isDesktop(sw) ? 52 : 40.h,
        ),
        Row(
          children: [
            // Notification
            AnimatedBuilder(
              animation: _notifBlink,
              builder: (_, __) => Transform.scale(
                scale: _notifBlink.value,
                child: _circleIcon(
                  size: circleSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        onTap: () => Get.to(() => const NotificationScreen()),
                        child: Icon(Icons.notifications_outlined,
                            color: AppColors.primaryRed, size: iconSize),
                      ),
                      Positioned(
                        right: 4, top: 4,
                        child: FadeTransition(
                          opacity: _blink,
                          child: Container(
                            width:  _isDesktop(sw) ? 7.0 : 8.w,
                            height: _isDesktop(sw) ? 7.0 : 8.w,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: gap),

            // Language
            _circleIcon(
              size: circleSize,
              child: InkWell(
                onTap: () => Get.toNamed(
                    AppRoutes.language, parameters: {'from': Get.currentRoute}),
                child: Icon(Icons.language, color: AppColors.primaryBlue, size: iconSize),
              ),
            ),
            SizedBox(width: gap),

            // Certificate icon
            _circleIcon(
              size: circleSize,
              child: InkWell(
                onTap: () => Get.toNamed(AppRoutes.certificationScreen),
                child: CustomSvg(
                  assetPath: 'assets/images/certificate.svg',
                  height: _isDesktop(sw) ? 20 : 20.sp,
                  width:  _isDesktop(sw) ? 20 : 20.sp,
                  semanticsLabel: '',
                ),
              ),
            ),
            SizedBox(width: gap),

            // Profile avatar
            InkWell(
              onTap: () => Get.to(() => ProfileScreen()),
              child: Obx(() => _circleIcon(
                size: circleSize,
                child: ClipOval(child: _avatarWidget(_isDesktop(sw) ? 38.0 : 38.sp)),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleIcon({required double size, required Widget child}) => Container(
    height: size, width: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.primaryRed, width: 1.5),
      color: AppColors.imageBackgroundColor.withOpacity(0.4),
    ),
    child: Center(child: child),
  );

  Widget _avatarWidget(double size) {
    final url = _userAvatarUrl.value;
    if (url.isNotEmpty) {
      return Image(
        image: _imageProvider(url),
        fit: BoxFit.cover, width: size, height: size,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/solo_image.png', fit: BoxFit.cover),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed))),
      );
    }
    return Image.asset('assets/images/solo_image.png',
        fit: BoxFit.cover, width: size, height: size);
  }

  // ==========================================================================
  // MOBILE CARD VIEW
  // ==========================================================================
  Widget _mobileCardView(double sw, double sh) {
    // Responsive card height: never overflow, scales with screen
    final cardAreaH = _isTablet(sw) ? sh * 0.52 : sh * 0.48;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Robot + Bonus
        SizedBox(
          width: _isTablet(sw) ? sw * 0.18 : sw * 0.22,
          child: AnimatedBuilder(
            animation: Listenable.merge([_robotBounce, _blink]),
            builder: (_, __) => Transform.translate(
              offset: Offset(0, -10 * _robotBounce.value),
              child: Opacity(
                opacity: _blink.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/robortarrow.png',
                      height: _isTablet(sw) ? sh * 0.14 : sh * 0.12,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 8.h),
                    _bonusButton(sw),
                  ],
                ),
              ),
            ),
          ),
        ),

        // PageView cards
        Expanded(
          child: SizedBox(
            height: cardAreaH,
            child: PageView.builder(
              controller: c.pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: c.cards.length,
              onPageChanged: (i) => c.selectedCardIndex.value = i,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: c.pageController,
                  builder: (_, __) {
                    final page = c.pageController.hasClients
                        ? (c.pageController.page ?? 0.0)
                        : 0.0;
                    final delta = index - page;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: _isTablet(sw) ? 12.w : 6.w,
                      ),
                      child: Transform.translate(
                        offset: Offset(delta * -30.w, 0),
                        child: Transform.rotate(
                          angle: delta * -0.07,
                          child: Transform.scale(
                            scale: (1 - delta.abs() * 0.08).clamp(0.88, 1.0),
                            child: _card(index, context, sw),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Dots
        Padding(
          padding: EdgeInsets.only(right: 4.w, left: 4.w),
          child: _verticalDots(sw),
        ),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP CARD AREA — uses _desktopPageCtrl (never recreated)
  // ==========================================================================
  Widget _desktopCardArea(double sw, double sh) {
    final cardH = (sh * 0.54).clamp(270.0, 430.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: cardH,
          child: PageView.builder(
            controller: _desktopPageCtrl,
            itemCount: c.cards.length,
            physics: const PageScrollPhysics(),   // ← snaps cleanly
            onPageChanged: (i) => c.selectedCardIndex.value = i,
            itemBuilder: (context, index) {
              // AnimatedBuilder listens to _desktopPageCtrl — same controller
              return AnimatedBuilder(
                animation: _desktopPageCtrl,
                builder: (_, __) {
                  double page = 0;
                  if (_desktopPageCtrl.hasClients &&
                      _desktopPageCtrl.position.haveDimensions) {
                    page = _desktopPageCtrl.page ?? 0.0;
                  }
                  final delta   = (index - page);
                  final scale   = (1 - delta.abs() * 0.10).clamp(0.84, 1.0);
                  final offsetY = delta.abs() * 14.0;
                  final opacity = (1 - delta.abs() * 0.30).clamp(0.0, 1.0);

                  return GestureDetector(
                    onTap: () {
                      if (index == c.selectedCardIndex.value) {
                        c.onTapCTA();
                      } else {
                        _desktopPageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Transform.translate(
                        offset: Offset(0, offsetY),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: _card(index, context, sw),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ── Arrow nav + horizontal dots ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left arrow
            _navArrow(
              icon: Icons.chevron_left_rounded,
              onTap: () {
                final cur = _desktopPageCtrl.hasClients
                    ? (_desktopPageCtrl.page?.round() ?? 0)
                    : 0;
                if (cur > 0) {
                  _desktopPageCtrl.animateToPage(
                    cur - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),

            const SizedBox(width: 16),

            // Horizontal dots
            Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(c.cards.length * 2 - 1, (i) {
                if (i.isOdd) return const SizedBox(width: 6);
                final dotIdx = i ~/ 2;
                final active = c.selectedCardIndex.value == dotIdx;
                return GestureDetector(
                  onTap: () => _desktopPageCtrl.animateToPage(
                    dotIdx,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width:  active ? 22.0 : 9.0,
                    height: 9.0,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFC34028)
                          : Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              }),
            )),

            const SizedBox(width: 16),

            // Right arrow
            _navArrow(
              icon: Icons.chevron_right_rounded,
              onTap: () {
                final cur = _desktopPageCtrl.hasClients
                    ? (_desktopPageCtrl.page?.round() ?? 0)
                    : 0;
                if (cur < c.cards.length - 1) {
                  _desktopPageCtrl.animateToPage(
                    cur + 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _navArrow({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFC34028).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFC34028), size: 22),
        ),
      ),
    );
  }

  // ==========================================================================
  // CARD WIDGET — responsive sizing
  // ==========================================================================
  Widget _card(int index, BuildContext context, double sw) {
    final m   = c.cards[index];
    final bg  = Color(m['bg']  as int);
    final bg2 = Color(m['bg2'] as int);

    return Container(
      padding: EdgeInsets.fromLTRB(
        _isDesktop(sw) ? 28 : 18.w,
        _isDesktop(sw) ? 24 : 18.h,
        _isDesktop(sw) ? 28 : 18.w,
        _isDesktop(sw) ? 20 : 14.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, bg2],
        ),
        borderRadius: BorderRadius.circular(_isDesktop(sw) ? 28 : 24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: _isDesktop(sw) ? 20 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _cardBody(m, context, sw),
    );
  }

  Widget _cardBody(Map<String, dynamic> m, BuildContext context, double sw) {
    // Fully responsive font sizes
    final titleTopSize    = _isDesktop(sw) ? 30.0 : _isTablet(sw) ? 26.0 : 24.sp;
    final titleBottomSize = _isDesktop(sw) ? 26.0 : _isTablet(sw) ? 22.0 : 21.sp;
    final subtitleSize    = _isDesktop(sw) ? 14.0 : _isTablet(sw) ? 13.0 : 12.sp;
    final ctaSize         = _isDesktop(sw) ? 15.0 : _isTablet(sw) ? 13.0 : 13.sp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: '${(m['titleTop'] ?? '').toString().tr}\n',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: titleTopSize,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: (m['titleBottom'] ?? '').toString().tr,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: titleBottomSize,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ]),
        ),
        SizedBox(height: _isDesktop(sw) ? 12 : 8.h),
        Text(
          (m['subtitle'] ?? '').toString().tr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: subtitleSize,
            height: 1.4,
            color: Colors.white,
          ),
          maxLines: _isDesktop(sw) ? 4 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        GestureDetector(
          onTap: c.onTapCTA,
          child: Text(
            (m['cta'] ?? '').toString().tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: ctaSize,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // VERTICAL DOTS
  // ==========================================================================
  Widget _verticalDots(double sw) => Obx(
        () => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(c.cards.length * 2 - 1, (i) {
        if (i.isOdd) return SizedBox(height: _isDesktop(sw) ? 7.0 : 6.h);
        final dotIdx = i ~/ 2;
        final active = c.selectedCardIndex.value == dotIdx;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width:  active ? (_isDesktop(sw) ? 11.0 : 10.w) : (_isDesktop(sw) ? 8.0 : 8.w),
          height: active ? (_isDesktop(sw) ? 11.0 : 10.w) : (_isDesktop(sw) ? 8.0 : 8.w),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFC34028) : Colors.black26,
            shape: BoxShape.circle,
          ),
        );
      }),
    ),
  );

  // ==========================================================================
  // BONUS BUTTON
  // ==========================================================================
  Widget _bonusButton(double sw) => Obx(() => GestureDetector(
    onTap: _onBonusTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(sw) ? 14.0 : 10.w,
        vertical:   _isDesktop(sw) ?  7.0 :  6.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isBonusLoading.value
          ? SizedBox(
        width:  _isDesktop(sw) ? 20.0 : 18.w,
        height: _isDesktop(sw) ? 20.0 : 18.h,
        child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      )
          : Text(
        'bonus_mode'.tr,
        style: TextStyle(
          fontSize: _isDesktop(sw) ? 13.0 : _isTablet(sw) ? 12.0 : 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ));

  // ==========================================================================
  // DASHBOARD BUTTON
  // ==========================================================================
  Widget _dashboardButton(BuildContext context, double sw) => GestureDetector(
    onTap: () => Get.toNamed(AppRoutes.personalDashboardScreen),
    child: FadeTransition(
      opacity: _blink,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'go_to'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: _isDesktop(sw) ? 15.0 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              FadeTransition(
                opacity: _blink,
                child: Image.asset(
                  'assets/images/arrow.png',
                  height: _isDesktop(sw) ? 20.0 : 20.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          Text(
            'dashboard'.tr,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: _isDesktop(sw) ? 15.0 : 14.sp,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}







// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:game_app/presentation/routes/app_routes.dart';
// import 'package:game_app/presentation/widgets/bubble_button.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// import '../../../controllers/home_controller.dart';
// import '../../../core/api_constants.dart';
// import '../../../core/app_colors.dart';
// import '../../../core/app_dimensions.dart';
// import '../../../services/shared_preference.dart';
// import '../../../view_model/bonus_controller/bonus_controller.dart';
// import '../../widgets/custom_svg.dart';
// import '../authentication/profile_screen.dart';
// import '../notification/notification_screen.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Adaptive helpers — plain px on desktop/tablet, .sp on mobile
// // ─────────────────────────────────────────────────────────────────────────────
// double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
//   if (sw >= 1024) return desktop ?? tablet ?? mobile;
//   if (sw >= 768)  return tablet ?? mobile;
//   return mobile.sp;
// }
// double _d(double sw, double v)  => sw >= 768 ? v : v.w;
// double _dh(double sw, double v) => sw >= 768 ? v : v.h;
//
// // ─────────────────────────────────────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//
//   // ── GetX controller — safe registration ──────────────────────────────────
//   late final HomeController c;
//
//   // Reactive state
//   final RxBool   _isBonusLoading = false.obs;
//   final RxString _userAvatarUrl  = ''.obs;
//
//   bool get _isDesktop => Get.width >= 1024;
//
//   // ── Animation controllers (same as mobile HomeScreen) ─────────────────────
//   late AnimationController _topBarCtrl;
//   late AnimationController _certCtrl;
//   late AnimationController _cardsCtrl;
//   late AnimationController _dashCtrl;
//   late AnimationController _robotCtrl;
//   late AnimationController _blinkCtrl;
//   late AnimationController _notifBlinkCtrl;
//
//   late Animation<Offset> _topBarSlide;
//   late Animation<double> _topBarFade;
//   late Animation<double> _certScale;
//   late Animation<double> _certFade;
//   late Animation<Offset> _cardsSlide;
//   late Animation<double> _cardsFade;
//   late Animation<Offset> _dashSlide;
//   late Animation<double> _dashFade;
//   late Animation<double> _robotBounce;
//   late Animation<double> _blink;
//   late Animation<double> _notifBlink;
//
//   // ── Lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//
//     // ✅ Safe: find if already registered, put if not
//     c = Get.isRegistered<HomeController>()
//         ? Get.find<HomeController>()
//         : Get.put(HomeController(), permanent: true);
//
//     _clearGameData();
//     _loadUserAvatar();
//     _listenAvatarChanges();
//     _initAnims();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _startAnims());
//   }
//
//   @override
//   void dispose() {
//     _topBarCtrl.dispose();
//     _certCtrl.dispose();
//     _cardsCtrl.dispose();
//     _dashCtrl.dispose();
//     _robotCtrl.dispose();
//     _blinkCtrl.dispose();
//     _notifBlinkCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── Animations ─────────────────────────────────────────────────────────────
//   void _initAnims() {
//     _topBarCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
//     _certCtrl       = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
//     _cardsCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
//     _dashCtrl       = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
//     _robotCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
//     _blinkCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
//       ..repeat(reverse: true);
//     _notifBlinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
//       ..repeat(reverse: true);
//
//     _topBarSlide  = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeOutCubic));
//     _topBarFade   = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeIn));
//     _certScale    = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _certCtrl, curve: Curves.elasticOut));
//     _certFade     = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _certCtrl, curve: Curves.easeIn));
//     _cardsSlide   = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOutCubic));
//     _cardsFade    = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeIn));
//     _dashSlide    = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _dashCtrl, curve: Curves.easeOutCubic));
//     _dashFade     = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _dashCtrl, curve: Curves.easeIn));
//     _robotBounce  = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _robotCtrl, curve: Curves.bounceOut));
//     _blink        = Tween<double>(begin: 0.3, end: 1.0)
//         .animate(CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut));
//     _notifBlink   = Tween<double>(begin: 1.0, end: 1.15)
//         .animate(CurvedAnimation(parent: _notifBlinkCtrl, curve: Curves.easeInOut));
//   }
//
//   void _startAnims() {
//     _topBarCtrl.forward();
//     Future.delayed(const Duration(milliseconds: 200),
//             () { if (mounted) _certCtrl.forward(); });
//     Future.delayed(const Duration(milliseconds: 400), () {
//       if (mounted) { _cardsCtrl.forward(); _robotCtrl.forward(); }
//     });
//     Future.delayed(const Duration(milliseconds: 600),
//             () { if (mounted) _dashCtrl.forward(); });
//   }
//
//   // ── Data helpers ───────────────────────────────────────────────────────────
//   Future<void> _clearGameData() async {
//     try { await SharedPrefs.clearGameSessionData(); } catch (_) {}
//   }
//
//   void _listenAvatarChanges() {
//     GetStorage().listenKey('user-data', (_) => _loadUserAvatar());
//   }
//
//   void _loadUserAvatar() {
//     try {
//       final raw = GetStorage().read('user-data');
//       if (raw == null) return;
//       final Map<String, dynamic> data = raw is String
//           ? jsonDecode(raw)
//           : Map<String, dynamic>.from(raw as Map);
//       final avatarId = data['avatarPicId']?.toString() ?? '';
//       if (avatarId.isEmpty) return;
//       if (avatarId.startsWith('http') ||
//           avatarId.startsWith('assets/') ||
//           avatarId.startsWith('lib/')) {
//         _userAvatarUrl.value = avatarId;
//       } else {
//         _userAvatarUrl.value = '${ApiConstants.baseUrl}/uploads/$avatarId';
//       }
//     } catch (_) {}
//   }
//
//   ImageProvider _imageProvider(String path) {
//     if (path.startsWith('assets/') || path.startsWith('lib/')) return AssetImage(path);
//     if (path.startsWith('http')) return NetworkImage(path);
//     return NetworkImage('${ApiConstants.baseUrl}/uploads/$path');
//   }
//
//   Color _badgeColor(String badge) {
//     switch (badge.toLowerCase()) {
//       case 'gold':   return Colors.amber;
//       case 'silver': return Colors.grey.shade400;
//       case 'bronze': return Colors.brown;
//       default:       return Colors.blueGrey;
//     }
//   }
//
//   // ── Bonus mode (exact from mobile) ────────────────────────────────────────
//   Future<void> _onBonusTap() async {
//     _isBonusLoading.value = true;
//     try {
//       // ✅ Safe controller retrieval
//       final controller = Get.isRegistered<BonusModeController>()
//           ? Get.find<BonusModeController>()
//           : Get.put(BonusModeController());
//
//       Get.dialog(
//         const Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
//         barrierDismissible: false,
//       );
//       await controller.checkPlayedToday();
//       Get.back();
//
//       if (controller.hasPlayedToday.value) {
//         _showAlreadyPlayedDialog(controller);
//         return;
//       }
//       await SharedPrefs.saveGameMode('bonus');
//       await SharedPrefs.clearGameSessionData();
//       Get.toNamed(AppRoutes.roleSelection, arguments: {'fromBonus': true});
//     } catch (e) {
//       if (Get.isDialogOpen ?? false) Get.back();
//       Get.snackbar('error'.tr, '${'failed_start_bonus'.tr}$e');
//     } finally {
//       _isBonusLoading.value = false;
//     }
//   }
//
//   void _showAlreadyPlayedDialog(BonusModeController ctrl) {
//     final sw = Get.width;
//     final double dialogW = sw >= 1024 ? 400.0 : sw >= 768 ? 360.0 : sw * 0.88;
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Container(
//           width: dialogW,
//           padding: EdgeInsets.all(_d(sw, 24)),
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(24)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(children: [
//                 Icon(Icons.emoji_events, color: Colors.amber,
//                     size: _fs(sw, 28, desktop: 30)),
//                 SizedBox(width: _d(sw, 8)),
//                 Expanded(
//                   child: Text('daily_bonus_complete'.tr,
//                       style: TextStyle(
//                           fontSize: _fs(sw, 13, desktop: 14),
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87)),
//                 ),
//               ]),
//               SizedBox(height: _dh(sw, 14)),
//               Text('already_played_today'.tr,
//                   style: TextStyle(
//                       fontSize: _fs(sw, 15, desktop: 14), color: Colors.black87),
//                   textAlign: TextAlign.center),
//               SizedBox(height: _dh(sw, 14)),
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(_d(sw, 18)),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       colors: [Colors.green.shade400, Colors.green.shade600]),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(children: [
//                   Text('your_score_today'.tr,
//                       style: TextStyle(
//                           fontSize: _fs(sw, 14, desktop: 13),
//                           color: Colors.white70)),
//                   SizedBox(height: _dh(sw, 6)),
//                   Obx(() => Text('${ctrl.evaluationScore.value}',
//                       style: TextStyle(
//                           fontSize: _fs(sw, 44, desktop: 40),
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white))),
//                   SizedBox(height: _dh(sw, 6)),
//                   Obx(() => Container(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: _d(sw, 16), vertical: _dh(sw, 6)),
//                     decoration: BoxDecoration(
//                         color: _badgeColor(ctrl.badgeName.value),
//                         borderRadius: BorderRadius.circular(30)),
//                     child: Text(ctrl.badgeName.value.toUpperCase(),
//                         style: TextStyle(
//                             fontSize: _fs(sw, 16, desktop: 14),
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white)),
//                   )),
//                 ]),
//               ),
//               SizedBox(height: _dh(sw, 12)),
//               Text('come_back_tomorrow'.tr,
//                   style: TextStyle(
//                       fontSize: _fs(sw, 13, desktop: 13), color: Colors.black54),
//                   textAlign: TextAlign.center),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () => Get.back(),
//                   child: Text('ok'.tr,
//                       style: TextStyle(
//                           color: AppColors.primaryRed,
//                           fontWeight: FontWeight.bold,
//                           fontSize: _fs(sw, 14, desktop: 14))),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: true,
//     );
//   }
//
//   // ==========================================================================
//   // BUILD
//   // ==========================================================================
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;
//
//     return OrientationBuilder(
//       builder: (context, _) => Scaffold(
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: _isDesktop
//               ? BoxDecoration(
//             image: DecorationImage(
//               image: const AssetImage('assets/images/web_background.png'),
//               fit: BoxFit.cover,
//               colorFilter: ColorFilter.mode(
//                   Colors.black.withOpacity(0.15), BlendMode.dstATop),
//             ),
//           )
//               : BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: AppDimensions.d8.w),
//               child: Column(
//                 children: [
//                   SizedBox(height: AppDimensions.d26.h),
//
//                   // Top bar
//                   SlideTransition(
//                     position: _topBarSlide,
//                     child: FadeTransition(
//                         opacity: _topBarFade, child: _topBar(sw)),
//                   ),
//
//                   SizedBox(height: AppDimensions.d12.h),
//
//                   // Certificate button
//                   ScaleTransition(
//                     scale: _certScale,
//                     child: FadeTransition(
//                       opacity: _certFade,
//                       child: Center(
//                         child: CustomBubbleButton(
//                           text: 'certificate'.tr,
//                           width: _isDesktop ? 80 : 60,
//                           height: _isDesktop ? 25 : 15,
//                           onTap: () => Get.toNamed(AppRoutes.certificationScreen),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: AppDimensions.d18.h),
//
//                   // Cards
//                   Expanded(
//                     child: SlideTransition(
//                       position: _cardsSlide,
//                       child: FadeTransition(
//                         opacity: _cardsFade,
//                         child: _isDesktop
//                             ? _desktopCardView(sw, sh)
//                             : _mobileCardView(sw, sh),
//                       ),
//                     ),
//                   ),
//
//                   // Dashboard button
//                   SlideTransition(
//                     position: _dashSlide,
//                     child: FadeTransition(
//                       opacity: _dashFade,
//                       child: _dashboardButton(context),
//                     ),
//                   ),
//                   SizedBox(height: AppDimensions.d16.h),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================================
//   // TOP BAR
//   // ==========================================================================
//   Widget _topBar(double sw) => Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       // Logo
//       CustomSvg(
//         assetPath: 'assets/images/okrnev.svg',
//         semanticsLabel: 'OKR',
//         height: _isDesktop ? 60 : 40.h,
//       ),
//
//       Row(
//         children: [
//           // Notification with pulse blink
//           AnimatedBuilder(
//             animation: _notifBlink,
//             builder: (_, __) => Transform.scale(
//               scale: _notifBlink.value,
//               child: _circleIcon(
//                 size: _isDesktop ? 40.0 : 40.sp,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     InkWell(
//                       onTap: () => Get.to(() => const NotificationScreen()),
//
//                       child: Icon(Icons.notifications_outlined,
//                           color: AppColors.primaryRed,
//                           size: _isDesktop ? 20 : 22.sp),
//                     ),
//                     Positioned(
//                       right: 4, top: 4,
//                       child: FadeTransition(
//                         opacity: _blink,
//                         child: Container(
//                           width:  _isDesktop ? 7.0 : 8.w,
//                           height: _isDesktop ? 7.0 : 8.w,
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryRed,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 1.5),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(width: _isDesktop ? 10 : 12.w),
//
//           // Language
//           _circleIcon(
//             size: _isDesktop ? 40.0 : 40.sp,
//             child: InkWell(
//               onTap: () => Get.toNamed(
//                   AppRoutes.language, parameters: {'from': Get.currentRoute}),
//               child: Icon(Icons.language,
//                   color: AppColors.primaryBlue,
//                   size: _isDesktop ? 20 : 22.sp),
//             ),
//           ),
//
//           SizedBox(width: _isDesktop ? 10 : 12.w),
//
//           // Certificate SVG icon
//           _circleIcon(
//             size: _isDesktop ? 40.0 : 40.sp,
//             child: InkWell(
//               onTap: () => Get.toNamed(AppRoutes.certificationScreen),
//               child: CustomSvg(
//                 assetPath: 'assets/images/certificate.svg',
//                 height: _isDesktop ? 20 : 20.sp,
//                 width:  _isDesktop ? 20 : 20.sp,
//                 semanticsLabel: '',
//               ),
//             ),
//           ),
//
//           SizedBox(width: _isDesktop ? 10 : 12.w),
//
//           // Profile avatar — reactive
//           InkWell(
//             onTap: () => Get.to(() =>  ProfileScreen()),
//             child: Obx(() => _circleIcon(
//               size: _isDesktop ? 40.0 : 40.sp,
//               child: ClipOval(
//                 child: _avatarWidget(_isDesktop ? 38.0 : 38.sp),
//               ),
//             )),
//           ),
//         ],
//       ),
//     ],
//   );
//
//   Widget _circleIcon({required double size, required Widget child}) => Container(
//     height: size, width: size,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       border: Border.all(color: AppColors.primaryRed, width: 1.5),
//       color: AppColors.imageBackgroundColor.withOpacity(0.4),
//     ),
//     child: Center(child: child),
//   );
//
//   Widget _avatarWidget(double size) {
//     final url = _userAvatarUrl.value;
//     if (url.isNotEmpty) {
//       return Image(
//         image: _imageProvider(url),
//         fit: BoxFit.cover, width: size, height: size,
//         errorBuilder: (_, __, ___) =>
//             Image.asset('assets/images/solo_image.png', fit: BoxFit.cover),
//         loadingBuilder: (_, child, progress) => progress == null
//             ? child
//             : const Center(child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor:
//             AlwaysStoppedAnimation<Color>(AppColors.primaryRed))),
//       );
//     }
//     return Image.asset('assets/images/solo_image.png',
//         fit: BoxFit.cover, width: size, height: size);
//   }
//
//   // ==========================================================================
//   // MOBILE CARD VIEW — original vertical PageView + robot/bonus from mobile
//   // ==========================================================================
//   Widget _mobileCardView(double sw, double sh) => Row(
//     mainAxisAlignment: MainAxisAlignment.start,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Robot + bonus (from mobile)
//       Center(
//         child: Padding(
//           padding: EdgeInsets.only(left: 4.w),
//           child: AnimatedBuilder(
//             animation: Listenable.merge([_robotBounce, _blink]),
//             builder: (_, __) => Transform.translate(
//               offset: Offset(0, -10 * _robotBounce.value),
//               child: Opacity(
//                 opacity: _blink.value,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset('assets/images/robortarrow.png',
//                         height: 90.h, fit: BoxFit.contain),
//                     SizedBox(height: 8.h),
//                     _bonusButton(sw),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//
//       // Cards
//       Expanded(
//         child: SizedBox(
//           height: sh * 0.5,
//           child: PageView.builder(
//             controller: c.pageController,
//             scrollDirection: Axis.vertical,
//             physics: const BouncingScrollPhysics(),
//             itemCount: c.cards.length,
//             onPageChanged: (i) => c.selectedCardIndex.value = i,
//             itemBuilder: (context, index) => AnimatedBuilder(
//               animation: c.pageController,
//               builder: (_, __) {
//                 final page = c.pageController.hasClients
//                     ? (c.pageController.page ?? 0.0)
//                     : 0.0;
//                 final delta = index - page;
//                 return Transform.translate(
//                   offset: Offset(delta * -40.w, 0),
//                   child: Transform.rotate(
//                     angle: delta * -0.09,
//                     child: Transform.scale(
//                       scale: (1 - delta.abs() * 0.1).clamp(0.9, 1.0),
//                       child: _card(index, context),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//
//       // Dots
//       Padding(
//         padding: EdgeInsets.only(right: 4.w),
//         child: _verticalDots(),
//       ),
//     ],
//   );
//
//   // ==========================================================================
//   // DESKTOP CARD VIEW — original horizontal carousel + robot/bonus
//   // ==========================================================================
//   Widget _desktopCardView(double sw, double sh) {
//     final cardHeight = sh * 0.45;
//     return Row(
//       children: [
//         // Robot + bonus on left
//         AnimatedBuilder(
//           animation: Listenable.merge([_robotBounce, _blink]),
//           builder: (_, __) => Transform.translate(
//             offset: Offset(0, -8 * _robotBounce.value),
//             child: Opacity(
//               opacity: _blink.value,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset('assets/images/robortarrow.png',
//                         height: 90, fit: BoxFit.contain),
//                     const SizedBox(height: 10),
//                     _bonusButton(sw),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         // Cards carousel
//         Expanded(
//           child: Center(
//             child: SizedBox(
//               height: cardHeight,
//               child: PageView.builder(
//                 controller: c.pageController,
//                 itemCount: c.cards.length,
//                 physics: const BouncingScrollPhysics(),
//                 onPageChanged: (i) => c.selectedCardIndex.value = i,
//                 itemBuilder: (context, index) {
//                   final page = c.pageController.hasClients
//                       ? (c.pageController.page ?? 0.0)
//                       : 0.0;
//                   final delta = index - page;
//                   final scale   = (1 - delta.abs() * 0.15).clamp(0.8, 1.0);
//                   final offsetY = delta.abs() * 20.0;
//                   final opacity = (1 - delta.abs() * 0.3).clamp(0.0, 1.0);
//
//                   return GestureDetector(
//                     onTap: () {
//                       if (index == c.selectedCardIndex.value) {
//                         c.onTapCTA();
//                       } else {
//                         c.pageController.animateToPage(index,
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut);
//                       }
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       margin: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Transform.translate(
//                         offset: Offset(0, offsetY),
//                         child: Transform.scale(
//                           scale: scale,
//                           child: Opacity(
//                               opacity: opacity,
//                               child: _card(index, context)),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//
//         // Dots on right
//         Padding(
//           padding: const EdgeInsets.only(right: 8),
//           child: _verticalDots(),
//         ),
//       ],
//     );
//   }
//
//   // ==========================================================================
//   // CARD
//   // ==========================================================================
//   Widget _card(int index, BuildContext context) {
//     final m   = c.cards[index];
//     final bg  = Color(m['bg']  as int);
//     final bg2 = Color(m['bg2'] as int);
//
//     return GestureDetector(
//       onTap: c.onTapCTA,
//       child: Container(
//         padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 16.h),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [bg, bg2],
//           ),
//           borderRadius: BorderRadius.circular(26.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.20),
//               blurRadius: 16,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: _cardBody(m, context),
//       ),
//     );
//   }
//
//   Widget _cardBody(Map<String, dynamic> m, BuildContext context) {
//     final sw = Get.width;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(children: [
//             TextSpan(
//               text: '${(m['titleTop'] ?? '').toString().tr}\n',
//               style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                 fontSize: _fs(sw, 30, desktop: 28),
//                 color: Colors.white,
//               ),
//             ),
//             TextSpan(
//               text: (m['titleBottom'] ?? '').toString().tr,
//               style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                 fontSize: _fs(sw, 27, desktop: 24),
//                 color: Colors.black.withOpacity(0.6),
//               ),
//             ),
//           ]),
//         ),
//         SizedBox(height: 10.h),
//         Text(
//           (m['subtitle'] ?? '').toString().tr,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             fontSize: _fs(sw, 13, desktop: 13),
//             height: 1.35,
//             color: Colors.white,
//           ),
//         ),
//         const Spacer(),
//         Text(
//           (m['cta'] ?? '').toString().tr,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             fontSize: _fs(sw, 14, desktop: 14),
//             fontWeight: FontWeight.w700,
//             decoration: TextDecoration.underline,
//             color: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ==========================================================================
//   // VERTICAL DOTS
//   // ==========================================================================
//   Widget _verticalDots() => Obx(
//         () => Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(c.cards.length * 2 - 1, (i) {
//         if (i.isOdd) return SizedBox(height: _isDesktop ? 6.0 : 6.h);
//         final dotIdx = i ~/ 2;
//         final active = c.selectedCardIndex.value == dotIdx;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           width:  active ? (_isDesktop ? 10.0 : 10.w) : (_isDesktop ? 8.0 : 8.w),
//           height: active ? (_isDesktop ? 10.0 : 10.w) : (_isDesktop ? 8.0 : 8.w),
//           decoration: BoxDecoration(
//             color: active ? const Color(0xFFC34028) : Colors.black26,
//             shape: BoxShape.circle,
//           ),
//         );
//       }),
//     ),
//   );
//
//   // ==========================================================================
//   // BONUS BUTTON
//   // ==========================================================================
//   Widget _bonusButton(double sw) => Obx(() => GestureDetector(
//     onTap: _onBonusTap,
//     child: Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: _isDesktop ? 12.0 : 12.w,
//         vertical:   _isDesktop ?  6.0 :  6.h,
//       ),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//             colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFFFFD700).withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: _isBonusLoading.value
//           ? SizedBox(
//         width:  _isDesktop ? 20.0 : 20.w,
//         height: _isDesktop ? 20.0 : 20.h,
//         child: const CircularProgressIndicator(
//           strokeWidth: 2,
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       )
//           : Text(
//         'bonus_mode'.tr,
//         style: TextStyle(
//           fontSize: _fs(sw, 14, desktop: 13),
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     ),
//   ));
//
//   // ==========================================================================
//   // DASHBOARD BUTTON — original from web screen
//   // ==========================================================================
//   Widget _dashboardButton(BuildContext context) => GestureDetector(
//     onTap: () => Get.toNamed(AppRoutes.personalDashboardScreen),
//     child: FadeTransition(
//       opacity: _blink,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'go_to'.tr,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   fontSize: _isDesktop ? 16 : 15.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               FadeTransition(
//                 opacity: _blink,
//                 child: Image.asset('assets/images/arrow.png',
//                     height: _isDesktop ? 22.0 : 22.h, fit: BoxFit.contain),
//               ),
//             ],
//           ),
//           Text(
//             'dashboard'.tr,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               fontSize: _isDesktop ? 16 : 15.sp,
//               fontWeight: FontWeight.w800,
//               decoration: TextDecoration.underline,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
