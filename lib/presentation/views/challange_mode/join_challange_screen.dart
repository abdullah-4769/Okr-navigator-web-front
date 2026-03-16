import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/response/status.dart';
import '../../../services/shared_preference.dart';
import '../../../view_model/challange_view_models/challange_create_view_model.dart';
import '../../../view_model/challange_view_models/join_challenge_view_model.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/game_complete_widgets/custom_score_card.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import 'challange_detail_screen.dart';
import 'widget/input_invite_code_card.dart';

class JoinChallengeScreen extends StatefulWidget {
  const JoinChallengeScreen({super.key});

  @override
  State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
  final ChallengeCreateViewModel _vm   = Get.put(ChallengeCreateViewModel());
  final StorageRepository        _repo = Get.put(StorageRepository());
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      final userId = _repo.getUserId();
      if (userId == null || userId.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.snackbar(
            'Authentication Required', 'Please log in to join challenges',
            backgroundColor: Colors.orange, colorText: Colors.white));
        return;
      }
      await _convertUserIdToHostId(userId);
      await _vm.fetchPlayersExceptCurrentUser();
      await _vm.fetchInvitations();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Get.snackbar('Error', 'Failed to initialize: $e',
              backgroundColor: Colors.red, colorText: Colors.white));
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _convertUserIdToHostId(String userId) async {
    try { await SharedPrefs.saveHostId(userId); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(),
          SizedBox(height: 20.h),
          const Text('Loading Challenge Data...'),
        ])),
      );
    }

    final double sw = MediaQuery.of(context).size.width;
    return sw < 768
        ? _buildMobileLayout(context, sw)
        : _buildDesktopLayout(context, sw);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomBackground(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 500.w),
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: _buildContent(isDesktop: false),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07, top: sh * 0.5,
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
            child: Opacity(opacity: 0.1,
                child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover)),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw, screenHeight: sh,
              title: 'Join', subtitle: 'Challenge',
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: _buildContent(isDesktop: true),
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

  Widget _buildContent({required bool isDesktop}) {
    final double gap = isDesktop ? 16 : 10.h;
    return Column(children: [
      if (!isDesktop)
        CustomHeader(title: 'Join', highlightedText: 'Challenge',
            onBackTap: Get.back),
      SizedBox(height: gap),
      CustomScoreCard(title: '', showBackground: false,
          imagePath: 'assets/images/solo_image.png', score: null),
      SizedBox(height: gap),
      InputInviteCodeCard(),
      SizedBox(height: isDesktop ? 20 : 25.h),
      Obx(() {
        if (_vm.inviteCode.isEmpty) return const SizedBox.shrink();
        return _buildInviteCodeCard(_vm, _vm.inviteCode.value, isDesktop: isDesktop);
      }),
      SizedBox(height: isDesktop ? 20 : 25.h),

      // On desktop — players + challengers side by side
      if (isDesktop) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionTitle(title: 'Search Players', isDesktop: true),
              const SizedBox(height: 12),
              _SearchBar(controller: _vm.searchPlayersController,
                  hint: 'Search Players', onClear: _vm.clearPlayerSearch),
              const SizedBox(height: 12),
              Obx(() => _PlayersList(players: _vm.filteredPlayers.value, isDesktop: true)),
            ])),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionTitle(title: 'Active Challengers', isDesktop: true),
              const SizedBox(height: 12),
              _SearchBar(controller: _vm.searchChallengersController,
                  hint: 'Search Challengers', onClear: _vm.clearChallengerSearch),
              const SizedBox(height: 12),
              Obx(() => _buildChallengersSection(isDesktop: true)),
            ])),
          ],
        ),
        const SizedBox(height: 24),
        Center(child: SizedBox(width: 320, child: _buildActionButtons(isDesktop: true))),
      ] else ...[
        _SectionTitle(title: 'Search Players', isDesktop: false),
        SizedBox(height: 15.h),
        _SearchBar(controller: _vm.searchPlayersController,
            hint: 'Search Players', onClear: _vm.clearPlayerSearch),
        SizedBox(height: 15.h),
        Obx(() => _PlayersList(players: _vm.filteredPlayers.value, isDesktop: false)),
        SizedBox(height: 30.h),
        _SectionTitle(title: 'Active Challengers', isDesktop: false),
        SizedBox(height: 15.h),
        _SearchBar(controller: _vm.searchChallengersController,
            hint: 'Search Challengers', onClear: _vm.clearChallengerSearch),
        SizedBox(height: 15.h),
        Obx(() => _buildChallengersSection(isDesktop: false)),
        SizedBox(height: 40.h),
        _buildActionButtons(isDesktop: false),
        SizedBox(height: 15.h),
      ],
    ]);
  }

  // ── CHALLENGERS SECTION ────────────────────────────────────────────────────

  Widget _buildChallengersSection({required bool isDesktop}) {
    final status      = _vm.invitationResponse.value.status;
    final challengers = _vm.filteredChallengers.value;

    final double containerH = isDesktop ? 260
        : challengers.isEmpty ? 280.h
        : challengers.length == 1 ? 160.h
        : challengers.length == 2 ? 240.h
        : 280.h;

    if (status == Status.loading) {
      return SizedBox(height: containerH,
          child: const Center(child: CircularProgressIndicator()));
    }
    if (status == Status.error) {
      return SizedBox(height: containerH,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, color: Colors.red, size: isDesktop ? 38 : 40.sp),
          SizedBox(height: isDesktop ? 8 : 10.h),
          Text('Failed to load challengers',
              style: TextStyle(color: Colors.grey, fontSize: isDesktop ? 13 : 14.sp)),
          SizedBox(height: isDesktop ? 8 : 10.h),
          ElevatedButton(onPressed: () => _vm.fetchInvitations(), child: const Text('Retry')),
        ])),
      );
    }
    if (challengers.isEmpty) {
      return SizedBox(height: containerH,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.group_outlined, color: Colors.grey.shade400,
              size: isDesktop ? 50 : 60.sp),
          SizedBox(height: isDesktop ? 12 : 16.h),
          Text('No Challenges Yet', style: TextStyle(
              fontSize: isDesktop ? 16 : 18.sp, fontWeight: FontWeight.bold,
              color: Colors.grey.shade600)),
          SizedBox(height: isDesktop ? 6 : 8.h),
          Text('When someone challenges you, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isDesktop ? 12 : 14.sp,
                  color: Colors.grey.shade500, height: 1.4)),
        ])),
      );
    }
    return _ChallengersList(challengers: challengers, isDesktop: isDesktop);
  }




  // ── ACTION BUTTONS ─────────────────────────────────────────────────────────

  Widget _buildActionButtons({required bool isDesktop}) {
    final joinVm = Get.put(JoinChallengeViewModel());
    return Obx(() {
      final hasInviteCode = _vm.inviteCode.isNotEmpty;
      final hasJoinCode   = joinVm.inviteCodeController.text.isNotEmpty;
      final userId        = _repo.getUserId();
      return Column(children: [
        if (!hasJoinCode && !hasInviteCode) ...[
          CustomButton2(text: 'Create Challenge',
              onPressed: userId != null ? () => _vm.createChallenge() : null),
          SizedBox(height: isDesktop ? 10 : 10.h),
        ],
        if (hasJoinCode && !hasInviteCode) ...[
          CustomButton2(text: 'Join Challenge',
              onPressed: userId != null ? () {
                joinVm.joinChallengeWithCode(joinVm.inviteCodeController.text, userId);
              } : null),
          SizedBox(height: isDesktop ? 10 : 10.h),
        ],
        CustomButton2(text: 'Continue',
            onPressed: () => Get.to(() => const ChallengeDetailsScreen())),
        SizedBox(height: isDesktop ? 10 : 10.h),
        if (hasInviteCode) ...[
          CustomButton2(text: 'Continue to Challenge',
              onPressed: () => Get.to(() => const ChallengeDetailsScreen())),
          SizedBox(height: isDesktop ? 10 : 10.h),
        ],
        if (userId == null)
          Text('Please log in to create or join challenges',
              style: TextStyle(color: Colors.red, fontSize: isDesktop ? 12 : 12.sp)),
      ]);
    });
  }

  Widget _buildInviteCodeCard(ChallengeCreateViewModel c, String code,
      {required bool isDesktop}) {
    return Container(
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 18),
      padding: EdgeInsets.all(isDesktop ? 14 : 16.h),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Invite Code',
              style: TextStyle(fontSize: isDesktop ? 15 : 16.sp,
                  color: Colors.grey.shade600)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(code, style: TextStyle(
                fontSize: isDesktop ? 17 : 18.sp,
                fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(width: isDesktop ? 7 : 8.w),
            GestureDetector(
              onTap: () => c.copyInviteCode(),
              child: CircleAvatar(
                radius: isDesktop ? 13 : 14.r,
                backgroundColor: Colors.red.shade400,
                child: Icon(Icons.copy, color: Colors.white,
                    size: isDesktop ? 14 : 16.sp),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── SUB-WIDGETS ────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDesktop;
  const _SectionTitle({required this.title, required this.isDesktop});

  @override
  Widget build(BuildContext context) => Padding(
    padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(
          fontSize: isDesktop ? 16 : 20.sp,
          fontWeight: FontWeight.bold, color: const Color(0xff24387F))),
    ),
  );
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onClear;
  const _SearchBar({required this.controller, required this.hint, this.onClear});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;
    return Container(
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 18),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 14 : 18.w,
          vertical: isDesktop ? 6 : 8.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.grey)),
      child: Row(children: [
        CircleAvatar(
          radius: isDesktop ? 13 : 14.r,
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.search, color: Colors.grey.shade600,
              size: isDesktop ? 14 : 16.sp),
        ),
        SizedBox(width: isDesktop ? 10 : 12.w),
        Expanded(
          child: TextField(
            controller: controller,
            // ✅ explicit style required — without it TextField inherits the
            //    theme fontSize which ScreenUtil scales ~3.6x on desktop
            style: TextStyle(
              fontSize: isDesktop ? 13.0 : 14.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500,
                  fontSize: isDesktop ? 13 : 14.sp),
              border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close, size: isDesktop ? 16 : 18.sp,
                  color: Colors.grey.shade600)),
        ),
      ]),
    );
  }
}

class _PlayersList extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final bool isDesktop;
  const _PlayersList({required this.players, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final double h = isDesktop ? 180 : (players.isEmpty ? 120.h : 160.h);
    return Container(
      height: h,
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: players.isEmpty
          ? Center(child: Text('No players found',
          style: TextStyle(color: Colors.grey, fontSize: isDesktop ? 13 : 14.sp)))
          : ListView.separated(
        padding: EdgeInsets.all(isDesktop ? 10 : 12.h),
        itemCount: players.length,
        separatorBuilder: (_, __) => SizedBox(height: isDesktop ? 6 : 8.h),
        itemBuilder: (_, i) => _PlayerCard(player: players[i], isDesktop: isDesktop),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final bool isDesktop;
  const _PlayerCard({required this.player, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final vm       = Get.find<ChallengeCreateViewModel>();
    final playerId = player['id']?.toString() ?? '';
    final name     = player['name']?.toString() ?? 'Unknown Player';
    final avatar   = player['avatar']?.toString();
    final canChallenge = playerId.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 10 : 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xffC43917)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: isDesktop ? 18 : 20.r,
          backgroundImage: (avatar != null && avatar.startsWith('http'))
              ? NetworkImage(avatar) : null,
          backgroundColor: Colors.blue.shade100,
          child: (avatar == null || !avatar.startsWith('http'))
              ? Icon(Icons.person, color: Colors.blue.shade600,
              size: isDesktop ? 18 : 20.sp) : null,
        ),
        SizedBox(width: isDesktop ? 8 : 10.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: isDesktop ? 13 : 14.sp,
              fontWeight: FontWeight.bold, color: const Color(0xff24387F)),
              overflow: TextOverflow.ellipsis, maxLines: 1),
          SizedBox(height: isDesktop ? 3 : 4.h),
          Row(children: [
            CircleAvatar(radius: isDesktop ? 3.5 : 4.r, backgroundColor: Colors.green),
            SizedBox(width: isDesktop ? 4 : 5.w),
            Text('Online', style: TextStyle(fontSize: isDesktop ? 10 : 11.sp,
                color: Colors.green.shade700, fontWeight: FontWeight.w500)),
          ]),
        ])),
        Obx(() {
          final isChallenging = vm.isChallengingPlayer(playerId);
          return ElevatedButton(
            onPressed: canChallenge && !isChallenging
                ? () => vm.sendChallengeInvite(playerId) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canChallenge ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 16.w, vertical: isDesktop ? 6 : 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: isChallenging
                ? SizedBox(width: isDesktop ? 14 : 16.w, height: isDesktop ? 14 : 16.h,
                child: const CircularProgressIndicator(strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white)))
                : Text('Challenge', style: TextStyle(
                fontSize: isDesktop ? 11 : 12.sp, fontWeight: FontWeight.bold)),
          );
        }),
      ]),
    );
  }
}

class _ChallengersList extends StatelessWidget {
  final List<Map<String, dynamic>> challengers;
  final bool isDesktop;
  const _ChallengersList({required this.challengers, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final double itemH = isDesktop ? 120 : 140.h;
    final double maxH  = isDesktop ? 260 : 280.h;
    final double h     = (challengers.length * itemH).clamp(100.0, maxH);
    return SizedBox(
      height: h,
      child: ListView.separated(
        padding: EdgeInsets.all(isDesktop ? 8 : 12.h),
        itemCount: challengers.length,
        separatorBuilder: (_, __) => SizedBox(height: isDesktop ? 8 : 12.h),
        itemBuilder: (_, i) => _ChallengerCard(
            challenger: challengers[i], isDesktop: isDesktop),
      ),
    );
  }
}

class _ChallengerCard extends StatelessWidget {
  final Map<String, dynamic> challenger;
  final bool isDesktop;
  const _ChallengerCard({required this.challenger, required this.isDesktop});

  String _getInitials(String name) {
    final ns = name.split(' ');
    if (ns.length >= 2) return '${ns[0][0]}${ns[1][0]}'.toUpperCase();
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  Color _getColor(String name) {
    const colors = [Colors.blue, Colors.red, Colors.green,
      Colors.orange, Colors.purple, Colors.teal, Colors.indigo];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final vm            = Get.find<ChallengeCreateViewModel>();
    final cData         = challenger['challenge'] ?? {};
    final hostDetail    = cData['hostDetail'] ?? {};
    final invitationId  = challenger['id']?.toString() ?? '';
    final name          = hostDetail['name']?.toString() ?? 'Unknown Challenger';
    final level         = hostDetail['rank']?.toString() ?? '1';
    final points        = hostDetail['totalPoints']?.toString() ?? '0';
    final avatarId      = hostDetail['avatarPicId']?.toString();
    final canRespond    = invitationId.isNotEmpty;

    final double fName  = isDesktop ? 13 : 14.sp;
    final double fSub   = isDesktop ? 9  : 10.sp;
    final double fScore = isDesktop ? 13 : 14.sp;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 12 : 16.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD7D7D7)),
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            radius: isDesktop ? 18 : 20.r,
            backgroundColor: _getColor(name),
            backgroundImage: avatarId != null && avatarId.isNotEmpty
                ? NetworkImage('https://okr-navigator-backend.onrender.com/uploads/$avatarId')
                : null,
            child: avatarId == null || avatarId.isEmpty
                ? Text(_getInitials(name), style: TextStyle(color: Colors.white,
                fontSize: isDesktop ? 12 : 14.sp, fontWeight: FontWeight.bold))
                : null,
          ),
          SizedBox(width: isDesktop ? 10 : 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fName)),
            SizedBox(height: isDesktop ? 3 : 4.h),
            Row(children: [
              Text('Level $level', style: TextStyle(color: Colors.blue, fontSize: fSub)),
              SizedBox(width: isDesktop ? 5 : 6.w),
              Container(height: isDesktop ? 7 : 8.h, width: 1,
                  color: const Color(0xffC43917)),
              SizedBox(width: isDesktop ? 5 : 6.w),
              Text('$points Points', style: TextStyle(
                  color: Colors.grey.shade600, fontSize: fSub)),
            ]),
          ])),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star, color: const Color(0xffC43917),
                size: isDesktop ? 14 : 16.sp),
            SizedBox(width: isDesktop ? 3 : 4.w),
            Text(points, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fScore)),
          ]),
        ]),
        SizedBox(height: isDesktop ? 10 : 12.h),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: canRespond ? () => vm.respondToChallenge(invitationId, true) : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 10.h),
              decoration: BoxDecoration(
                  color: canRespond ? const Color(0xff8DC046) : Colors.grey,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Accept', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 11 : 12.sp)),
            ),
          )),
          SizedBox(width: isDesktop ? 7 : 8.w),
          Expanded(child: GestureDetector(
            onTap: canRespond ? () => vm.respondToChallenge(invitationId, false) : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 10.h),
              decoration: BoxDecoration(
                  color: canRespond ? const Color(0xffC43917) : Colors.grey,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Decline', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 11 : 12.sp)),
            ),
          )),
        ]),
      ]),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:game_app/presentation/views/challange_mode/widget/input_invite_code_card.dart';
// import 'package:get/get.dart';
// import '../../../core/app_colors.dart';
// import '../../../data/repositories/storage_repository.dart';
// import '../../../data/response/status.dart';
// import '../../../services/shared_preference.dart';
// import '../../../view_model/challange_view_models/challange_create_view_model.dart';
// import '../../../view_model/challange_view_models/join_challenge_view_model.dart';
// import '../../widgets/custom_button2.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
// import '../../widgets/game_complete_widgets/custom_score_card.dart';
// import 'challange_detail_screen.dart';
//
// class JoinChallengeScreen extends StatefulWidget {
//   const JoinChallengeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
// }
//
// class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
//   final ChallengeCreateViewModel _viewModel = Get.put(ChallengeCreateViewModel());
//   bool _isInitializing = true;
//   final StorageRepository _storageRepo = Get.put(StorageRepository());
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//     try {
//       setState(() {
//         _isInitializing = true;
//       });
//
//       // ✅ FIXED: Get user ID from StorageRepository (works for both email and Google)
//       final userId = _storageRepo.getUserId();
//
//       if (userId == null || userId.isEmpty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Get.snackbar(
//             'Authentication Required',
//             'Please log in to join challenges',
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//           );
//         });
//         return;
//       }
//
//       print('✅ Initializing with user ID: $userId');
//
//       // Use the actual user ID from authentication
//       await _convertUserIdToHostId(userId);
//       await _viewModel.fetchPlayersExceptCurrentUser();
//       await _viewModel.fetchInvitations();
//
//     } catch (e) {
//       print('❌ Error initializing screen: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.snackbar(
//           'Error',
//           'Failed to initialize: $e',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isInitializing = false;
//         });
//       }
//     }
//   }
//
//   // Function to convert user ID to host ID and save it
//   Future<void> _convertUserIdToHostId(String userId) async {
//     try {
//       await SharedPrefs.saveHostId(userId);
//       print('🔑 User ID saved as Host ID: $userId');
//     } catch (e) {
//       print('⚠️ Error saving host ID: $e');
//     }
//   }
//   // Function to convert user ID to host ID and save it
//   // Future<void> _convertUserIdToHostId(String userId) async {
//   //   try {
//   //     await SharedPrefs.saveHostId(userId);
//   //     print('🔑 User ID saved as Host ID: $userId');
//   //   } catch (e) {
//   //     print('⚠️ Error saving host ID: $e');
//   //   }
//   // }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20.h),
//               Text('Loading Challenge Data...'),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: CustomBackground(
//           child: SingleChildScrollView(
//             child: Center(
//               child: Container(
//                 constraints: BoxConstraints(maxWidth: 500.w),
//                 padding: EdgeInsets.symmetric(vertical: 6.h),
//                 child: Column(
//                   children: [
//                     CustomHeader(
//                       title: "Join",
//                       highlightedText: "Challenge",
//                       onBackTap: Get.back,
//                     ),
//                   //  SizedBox(height: 10.h),
//                     //_buildUserInfoCard(),
//                     SizedBox(height: 10.h),
//                     CustomScoreCard(
//                       title: '',
//                       showBackground: false,
//                       imagePath: "assets/images/solo_image.png", score: null,
//                     ),
//                     SizedBox(height: 10.h),
//                     InputInviteCodeCard(),
//                     SizedBox(height: 25.h),
//                     Obx(() {
//                       if (_viewModel.inviteCode.isEmpty) {
//                         return const SizedBox.shrink();
//                       }
//                       return _buildInviteCodeCard(_viewModel, _viewModel.inviteCode.value);
//                     }),
//                     SizedBox(height: 25.h),
//                     _SectionTitle(title: 'Search Players'),
//                     SizedBox(height: 15.h),
//                     _SearchBar(
//                       controller: _viewModel.searchPlayersController,
//                       hint: 'Search Players',
//                       onClear: _viewModel.clearPlayerSearch,
//                     ),
//                     SizedBox(height: 15.h),
//                     Obx(() => _PlayersList(players: _viewModel.filteredPlayers.value)),
//                     SizedBox(height: 30.h),
//                     _SectionTitle(title: 'Active Challengers'),
//                     SizedBox(height: 15.h),
//                     _SearchBar(
//                       controller: _viewModel.searchChallengersController,
//                       hint: 'Search Challengers',
//                       onClear: _viewModel.clearChallengerSearch,
//                     ),
//                     SizedBox(height: 15.h),
//                     Obx(() => _buildChallengersSection()),
//                     SizedBox(height: 40.h),
//                     _buildActionButtons(),
//                     SizedBox(height: 15.h),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // User info card showing current user
//   Widget _buildUserInfoCard() {
//     final userName = SharedPrefs.getUserName() ?? 'User';
//     final userId = SharedPrefs.getUserId();
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 18.w),
//       padding: EdgeInsets.all(12.h),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20.r,
//             backgroundColor: Colors.blue,
//             child: Text(
//               userName[0].toUpperCase(),
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   userName,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//                 ),
//                 Text(
//                   'ID: ${userId?.substring(0, 8)}...',
//                   style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// // Action buttons with proper validation - FIXED: Single button that transforms
// // Replace your _buildActionButtons() method with this:
//   Widget _buildActionButtons() {
//     final JoinChallengeViewModel joinViewModel = Get.put(JoinChallengeViewModel());
//     final ChallengeCreateViewModel createViewModel = Get.find<ChallengeCreateViewModel>();
//
//     return Obx(() {
//       final hasInviteCode = createViewModel.inviteCode.isNotEmpty;
//       final hasJoinCode = joinViewModel.inviteCodeController.text.isNotEmpty;
//       final userId = _storageRepo.getUserId();
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Column(
//           children: [
//             // CREATE CHALLENGE BUTTON - Show when no code is entered
//             if (!hasJoinCode && !hasInviteCode) ...[
//               CustomButton2(
//                 text: "Create Challenge",
//                 onPressed: userId != null ? () {
//                   createViewModel.createChallenge();
//                 } : null,
//               ),
//               SizedBox(height: 10.h),
//             ],
//
//             // JOIN CHALLENGE BUTTON - Show when user entered a code
//             if (hasJoinCode && !hasInviteCode) ...[
//               CustomButton2(
//                 text: "Join Challenge",
//                 onPressed: userId != null ? () {
//                   final code = joinViewModel.inviteCodeController.text;
//                   joinViewModel.joinChallengeWithCode(code, userId);
//                 } : null,
//               ),
//               SizedBox(height: 10.h),
//             ],
//             CustomButton2(
//               text: "Continue",
//               onPressed: () {
//                 Get.to(() => ChallengeDetailsScreen());
//               },
//             ),
//             SizedBox(height: 10.h),
//             // CREATE CHALLENGE BUTTON - Show after creating challenge
//             if (hasInviteCode)
//             // CONTINUE BUTTON - Show after creating challenge
//             if (hasInviteCode) ...[
//               CustomButton2(
//                 text: "Continue to Challenge",
//                 onPressed: () {
//                   Get.to(() => ChallengeDetailsScreen());
//                 },
//               ),
//               SizedBox(height: 10.h),
//             ],
//
//             // Show authentication error
//             if (userId == null) ...[
//               SizedBox(height: 8.h),
//               Text(
//                 'Please log in to create or join challenges',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 12.sp,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       );
//     });
//   }  //   return Column(
//   //     children: [
//   //       Obx(() {
//   //         final status = _viewModel.inviteCodeResponse.value.status;
//   //         final isLoading = status == Status.loading;
//   //         final userId = SharedPrefs.getUserId();
//   //
//   //         return Padding(
//   //           padding: const EdgeInsets.symmetric(horizontal: 12),
//   //           child: CustomButton2(
//   //             text: isLoading ? "Creating Challenge..." : "Create Challenge",
//   //             onPressed: (isLoading || userId == null)
//   //                 ? null
//   //                 : () {
//   //               _viewModel.createChallenge(userId);
//   //             },
//   //           ),
//   //         );
//   //       }),
//   //       SizedBox(height: 10.h),
//   //       Padding(
//   //         padding: const EdgeInsets.symmetric(horizontal: 12),
//   //         child: CustomButton2(
//   //           text: "Continue",
//   //           onPressed: () {
//   //             final userId = SharedPrefs.getUserId();
//   //             if (userId == null) {
//   //               Get.snackbar(
//   //                 'Authentication Required',
//   //                 'Please log in to continue',
//   //                 backgroundColor: Colors.orange,
//   //                 colorText: Colors.white,
//   //               );
//   //               return;
//   //             }
//   //             Get.to(() => ChallengeDetailsScreen());
//   //           },
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   // Build challengers section based on API state - FIXED: Dynamic height
//   Widget _buildChallengersSection() {
//     final status = _viewModel.invitationResponse.value.status;
//     final challengers = _viewModel.filteredChallengers.value;
//
//     // ✅ FIXED: Dynamic height based on content
//     final containerHeight = challengers.isEmpty ? 280.h :
//     challengers.length == 1 ? 160.h :
//     challengers.length == 2 ? 240.h : 280.h;
//
//     if (status == Status.loading) {
//       return Container(
//         height: containerHeight,
//         margin: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     if (status == Status.error) {
//       return Container(
//         height: containerHeight,
//         margin: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
//               SizedBox(height: 10.h),
//               Text(
//                 'Failed to load challengers',
//                 style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//               ),
//               SizedBox(height: 10.h),
//               ElevatedButton(
//                 onPressed: () => _viewModel.fetchInvitations(),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (challengers.isEmpty) {
//       return Container(
//         height: containerHeight,
//         margin: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.group_outlined,
//                 color: Colors.grey.shade400,
//                 size: 60.sp,
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'No Challenges Yet',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.w),
//                 child: Text(
//                   'When someone challenges you, they will appear here. Share your invite code to get started!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.grey.shade500,
//                     height: 1.4,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return _ChallengersList(challengers: challengers);
//   }
//
// // Build challengers section based on API state - FIXED: Use invitationResponse
// //   Widget _buildChallengersSection() {
// //     final status = _viewModel.invitationResponse.value.status;
// //
// //     // ✅ ADD DEBUG INFO
// //     print('🎯 Challengers API Status: $status');
// //     print('🎯 Number of challengers: ${_viewModel.filteredChallengers.value.length}');
// //
// //     if (_viewModel.filteredChallengers.value.isNotEmpty) {
// //       print('🎯 First challenger data: ${_viewModel.filteredChallengers.value.first}');
// //     }
// //
// //     if (status == Status.loading) {
// //       return Container(
// //         height: 280.h,
// //         margin: const EdgeInsets.symmetric(horizontal: 16.0),
// //         child: const Center(child: CircularProgressIndicator()),
// //       );
// //     }
// //
// //     if (status == Status.error) {
// //       return Container(
// //         height: 280.h,
// //         margin: const EdgeInsets.symmetric(horizontal: 16.0),
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
// //               SizedBox(height: 10.h),
// //               Text(
// //                 'Failed to load challengers',
// //                 style: TextStyle(color: Colors.grey, fontSize: 14.sp),
// //               ),
// //               SizedBox(height: 10.h),
// //               ElevatedButton(
// //                 onPressed: () => _viewModel.fetchInvitations(),
// //                 child: const Text('Retry'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // ✅ ADD THIS: Check if filteredChallengers is empty and show professional message
// //     if (_viewModel.filteredChallengers.value.isEmpty) {
// //       return Container(
// //         height: 280.h,
// //         margin: const EdgeInsets.symmetric(horizontal: 16.0),
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.group_outlined,
// //                 color: Colors.grey.shade400,
// //                 size: 60.sp,
// //               ),
// //               SizedBox(height: 16.h),
// //               Text(
// //                 'No Challenges Yet',
// //                 style: TextStyle(
// //                   fontSize: 18.sp,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.grey.shade600,
// //                 ),
// //               ),
// //               SizedBox(height: 8.h),
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 20.w),
// //                 child: Text(
// //                   'When someone challenges you, they will appear here. Share your invite code to get started!',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     color: Colors.grey.shade500,
// //                     height: 1.4,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return _ChallengersList(challengers: _viewModel.filteredChallengers.value);
// //   }
//   // Build challengers section based on API state
//   // Widget _buildChallengersSection() {
//   //   final status = _viewModel.invitationResponse.value.status;
//   //
//   //   if (status == Status.loading) {
//   //     return Container(
//   //       height: 200.h,
//   //       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//   //       child: Center(
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             CircularProgressIndicator(),
//   //             SizedBox(height: 10.h),
//   //             Text('Loading challengers...'),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //
//   //   if (status == Status.error) {
//   //     return Container(
//   //       height: 200.h,
//   //       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//   //       child: Center(
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
//   //             SizedBox(height: 10.h),
//   //             Text(
//   //               'Failed to load challengers',
//   //               style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//   //             ),
//   //             SizedBox(height: 10.h),
//   //             ElevatedButton(
//   //               onPressed: () => _viewModel.fetchInvitations(),
//   //               child: const Text('Retry'),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //
//   //   // Check if we have any challengers
//   //   final challengers = _viewModel.filteredChallengers.value;
//   //   if (challengers.isEmpty) {
//   //     return Container(
//   //       height: 200.h,
//   //       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//   //       child: Center(
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             Icon(Icons.group_off, color: Colors.grey, size: 40.sp),
//   //             SizedBox(height: 10.h),
//   //             Text(
//   //               'No active challengers',
//   //               style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//   //             ),
//   //             SizedBox(height: 5.h),
//   //             Text(
//   //               'When someone challenges you, they will appear here',
//   //               style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//   //               textAlign: TextAlign.center,
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //
//   //   return _ChallengersList(challengers: challengers);
//   // }
//
//   Widget _buildInviteCodeCard(ChallengeCreateViewModel controller, String code) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 18),
//       padding: EdgeInsets.all(16.h),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Invite Code',
//             style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
//           ),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 code,
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               GestureDetector(
//                 onTap: () => controller.copyInviteCode(),
//                 child: CircleAvatar(
//                   radius: 14.r,
//                   backgroundColor: Colors.red.shade400,
//                   child: Icon(Icons.copy, color: Colors.white, size: 16.sp),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// Section Title
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xff24387F),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Search Bar
// class _SearchBar extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final VoidCallback? onClear;
//
//   const _SearchBar({required this.controller, required this.hint, this.onClear});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 18),
//       padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: Colors.grey),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 14.r,
//             backgroundColor: Colors.grey.shade200,
//             child: Icon(Icons.search, color: Colors.grey.shade600, size: 16.sp),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//               ),
//             ),
//           ),
//           ValueListenableBuilder<TextEditingValue>(
//             valueListenable: controller,
//             builder: (context, value, child) {
//               if (value.text.isEmpty) return const SizedBox.shrink();
//               return GestureDetector(
//                 onTap: onClear,
//                 child: Icon(Icons.close, size: 18.sp, color: Colors.grey.shade600),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// Players List
// class _PlayersList extends StatelessWidget {
//   final List<Map<String, dynamic>> players;
//   const _PlayersList({required this.players});
//
//   @override
//   Widget build(BuildContext context) {
//     if (players.isEmpty) {
//       return Container(
//         height: 120.h,
//         margin: const EdgeInsets.symmetric(horizontal: 16.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Center(
//           child: Text(
//             'No players found',
//             style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       height: 160.h,
//       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: ListView.separated(
//         padding: EdgeInsets.all(12.h),
//         itemCount: players.length,
//         separatorBuilder: (_, __) => SizedBox(height: 8.h),
//         itemBuilder: (context, index) => _PlayerCard(player: players[index]),
//       ),
//     );
//   }
// }
//
// /// Player Card - FIXED: Complete null safety for all player data
// class _PlayerCard extends StatelessWidget {
//   final Map<String, dynamic> player;
//   const _PlayerCard({required this.player});
//
//   @override
//   Widget build(BuildContext context) {
//     final ChallengeCreateViewModel viewModel = Get.find<ChallengeCreateViewModel>();
//
//     // FIXED: Complete null safety - this was the main issue
//     final playerId = player['id']?.toString() ?? '';
//     final playerName = player['name']?.toString() ?? 'Unknown Player';
//     final canChallenge = playerId.isNotEmpty;
//
//     return Container(
//       padding: EdgeInsets.all(12.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(color: const Color(0xffC43917)),
//       ),
//       child: Row(
//         children: [
//           // Avatar with error handling
//           _buildPlayerAvatar(player),
//           SizedBox(width: 10.w),
//
//           // Player name and status
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Player Name
//                 Text(
//                   playerName,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xff24387F),
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//                 SizedBox(height: 4.h),
//
//                 // Online Status
//                 Row(
//                   children: [
//                     CircleAvatar(radius: 4.r, backgroundColor: Colors.green),
//                     SizedBox(width: 5.w),
//                     Text(
//                       'Online',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Colors.green.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Challenge Button with loading state - FIXED: Complete null safety
//           Obx(() {
//             final isChallenging = viewModel.isChallengingPlayer(playerId);
//             return ElevatedButton(
//               onPressed: canChallenge && !isChallenging
//                   ? () {
//                 print('🎯 Challenging player: $playerId - $playerName');
//                 viewModel.sendChallengeInvite(playerId);
//               }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: canChallenge ? Colors.blue : Colors.grey,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: isChallenging
//                   ? SizedBox(
//                 width: 16.w,
//                 height: 16.h,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//                   : Text(
//                 "Challenge",
//                 style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPlayerAvatar(Map<String, dynamic> player) {
//     final avatar = player['avatar']?.toString();
//
//     // Use default avatar if none provided or URL is invalid
//     if (avatar == null || avatar.isEmpty || !avatar.startsWith('http')) {
//       return CircleAvatar(
//         radius: 20.r,
//         backgroundColor: Colors.blue.shade100,
//         child: Icon(Icons.person, color: Colors.blue.shade600, size: 20.sp),
//       );
//     }
//
//     return CircleAvatar(
//       radius: 20.r,
//       backgroundImage: NetworkImage(avatar),
//       onBackgroundImageError: (exception, stackTrace) {
//         print('❌ Failed to load avatar: $avatar');
//       },
//       child: Icon(Icons.person, color: Colors.white, size: 20.sp),
//     );
//   }
// }
//
// /// Challengers List
// class _ChallengersList extends StatelessWidget {
//   final List<Map<String, dynamic>> challengers;
//   const _ChallengersList({required this.challengers});
//
//   @override
//   Widget build(BuildContext context) {
//     final itemHeight = 140.h; // Approximate height per item
//     final maxHeight = 280.h; // Maximum height
//     final calculatedHeight = (challengers.length * itemHeight).clamp(120.h, maxHeight);
//     return Container(
//       height: calculatedHeight.h,
//       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: ListView.separated(
//         padding: EdgeInsets.all(12.h),
//         itemCount: challengers.length,
//         separatorBuilder: (_, __) => SizedBox(height: 12.h),
//         itemBuilder: (context, index) => _ChallengerCard(challenger: challengers[index]),
//       ),
//     );
//   }
// }
//
// /// Challenger Card - FIXED: Use correct API response structure
// class _ChallengerCard extends StatelessWidget {
//   final Map<String, dynamic> challenger;
//   const _ChallengerCard({required this.challenger});
//
//   @override
//   Widget build(BuildContext context) {
//     final ChallengeCreateViewModel viewModel = Get.find<ChallengeCreateViewModel>();
//
//     // ✅ FIXED: Use the correct nested structure from your API response
//     final challengeData = challenger['challenge'] ?? {};
//     final hostDetail = challengeData['hostDetail'] ?? {};
//     final invitationId = challenger['id']?.toString() ?? '';
//     final canRespond = invitationId.isNotEmpty;
//
//     // ✅ FIXED: Extract data from correct nested structure
//     final challengerName = hostDetail['name']?.toString() ?? 'Unknown Challenger';
//     final level = hostDetail['rank']?.toString() ?? '1';
//     final points = hostDetail['totalPoints']?.toString() ?? '0';
//     final avatar = hostDetail['avatarPicId']?.toString();
//
//     return Container(
//       padding: EdgeInsets.all(16.h),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xffD7D7D7)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               // ✅ FIXED: Avatar with proper fallback
//               _buildChallengerAvatar(avatar, challengerName),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       challengerName,
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//                     ),
//                     SizedBox(height: 4.h),
//                     Row(
//                       children: [
//                         Text(
//                           'Level $level',
//                           style: TextStyle(color: Colors.blue, fontSize: 10.sp),
//                         ),
//                         SizedBox(width: 6.w),
//                         Container(height: 8.h, width: 1.w, color: const Color(0xffC43917)),
//                         SizedBox(width: 6.w),
//                         Text(
//                           '$points Points',
//                           style: TextStyle(color: Colors.grey.shade600, fontSize: 10.sp),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.star, color: Color(0xffC43917), size: 16.sp),
//                   SizedBox(width: 4.w),
//                   Text(
//                     points,
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: canRespond ? () => viewModel.respondToChallenge(invitationId, true) : null,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                     decoration: BoxDecoration(
//                       color: canRespond ? const Color(0xff8DC046) : Colors.grey,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'Accept',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: canRespond ? () => viewModel.respondToChallenge(invitationId, false) : null,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                     decoration: BoxDecoration(
//                       color: canRespond ? const Color(0xffC43917) : Colors.grey,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'Decline',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ FIXED: Better avatar builder with initials fallback
//   Widget _buildChallengerAvatar(String? avatarId, String challengerName) {
//     // Get initials for fallback avatar
//     final initials = _getInitials(challengerName);
//
//     if (avatarId == null || avatarId.isEmpty) {
//       return CircleAvatar(
//         radius: 20.r,
//         backgroundColor: _getAvatarColor(challengerName),
//         child: Text(
//           initials,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }
//
//     // Build proper avatar URL if you have an endpoint
//     final avatarUrl = 'https://okr-navigator-backend.onrender.com/uploads/$avatarId';
//
//     return CircleAvatar(
//       radius: 20.r,
//       backgroundImage: NetworkImage(avatarUrl),
//       onBackgroundImageError: (exception, stackTrace) {
//         print('❌ Failed to load challenger avatar: $avatarUrl');
//       },
//       child: Text(
//         initials,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   String _getInitials(String name) {
//     final names = name.split(' ');
//     if (names.length >= 2) {
//       return '${names[0][0]}${names[1][0]}'.toUpperCase();
//     }
//     return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
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
//     final index = name.length % colors.length;
//     return colors[index];
//   }
// }
//
//
