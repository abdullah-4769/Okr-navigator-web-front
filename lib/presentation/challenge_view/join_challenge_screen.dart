// lib/presentation/views/challenge/join_challenge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../data/response/status.dart';
import '../../../view_model/challange_view_models/challange_create_view_model.dart';
import '../../../view_model/challange_view_models/join_challenge_view_model.dart';

import '../widgets/custom_button2.dart';
import '../widgets/screens_unique_parts/custom_background.dart';
import '../widgets/screens_unique_parts/custom_header.dart';
import 'challenge_details_screen.dart';
import 'input_invite_card.dart';

class JoinChallengeScreen extends StatefulWidget {
  const JoinChallengeScreen({Key? key}) : super(key: key);

  @override
  State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
  late final ChallengeCreateViewModel createVM;
  late final JoinChallengeViewModel joinVM;
  late final StorageRepository storageRepo;

  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

    // Properly register both ViewModels
    createVM = Get.put(ChallengeCreateViewModel());
    joinVM = Get.put(JoinChallengeViewModel());
    storageRepo = Get.find<StorageRepository>();

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() => _isInitializing = true);

    try {
      final userId = storageRepo.getUserId();

      if (userId == null || userId.isEmpty) {
        Get.snackbar(
          'Login Required',
          'Please log in to join or create challenges',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      await Future.wait([
        createVM.fetchPlayersExceptCurrentUser(),
        createVM.fetchInvitations(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryRed),
              SizedBox(height: 24.h),
              Text('Loading Challenges...', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Column(
              children: [
                // Header
                CustomHeader(
                  title: "Join",
                  highlightedText: "Challenge",
                  onBackTap: () => Get.back(),
                ),

                SizedBox(height: 16.h),

                // Input Invite Code Card
                InputInviteCodeCard(),

                SizedBox(height: 20.h),

                // Show created invite code
                Obx(() => createVM.inviteCode.value.isNotEmpty
                    ? _buildInviteCodeCard(createVM.inviteCode.value)
                    : const SizedBox.shrink()),

                SizedBox(height: 30.h),

                // Search Players Section
                _SectionTitle(title: 'Search Players'),
                SizedBox(height: 15.h),
                _SearchBar(
                  controller: createVM.searchPlayersController,
                  hint: 'Search Players',
                  onClear: createVM.clearPlayerSearch,
                ),
                SizedBox(height: 15.h),
                Obx(() => _PlayersList(players: createVM.filteredPlayers.value)),

                SizedBox(height: 30.h),

                // Active Challengers Section
                _SectionTitle(title: 'Active Challengers'),
                SizedBox(height: 15.h),
                _SearchBar(
                  controller: createVM.searchChallengersController,
                  hint: 'Search Challengers',
                  onClear: createVM.clearChallengerSearch,
                ),
                SizedBox(height: 15.h),
                Obx(() => _buildChallengersSection()),

                SizedBox(height: 40.h),

                // Action Buttons
                _buildActionButtons(),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(String code) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(18.h),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Your Invite Code', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(code, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: createVM.copyInviteCode,
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primaryRed,
                  child: Icon(Icons.copy, size: 18.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final userId = storageRepo.getUserId();

    return Obx(() {
      final hasCreatedCode = createVM.inviteCode.value.isNotEmpty;
      final hasJoinCode = joinVM.inviteCodeController.text.trim().isNotEmpty;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            // Create Challenge
            if (!hasCreatedCode && !hasJoinCode)
              CustomButton2(
                text: "Create Challenge",
                onPressed: userId != null ? createVM.createChallenge : null,
                backgroundColor: AppColors.primaryBlue,
              ),

            // Join with Code
            if (hasJoinCode && !hasCreatedCode)
              CustomButton2(
                text: "Join Challenge",
                onPressed: userId != null
                    ? () => joinVM.joinChallengeWithCode(joinVM.inviteCodeController.text.trim(), userId!)
                    : null,
                backgroundColor: AppColors.primaryRed,
              ),

            // Continue to Challenge
            if (hasCreatedCode || hasJoinCode)
              CustomButton2(
                text: "Continue to Challenge",
                onPressed: () => Get.to(() => const ChallengeDetailsScreen()),
                backgroundColor: AppColors.primaryBlue,
              ),

            if (userId == null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Text(
                  'Please log in to create or join challenges',
                  style: TextStyle(color: Colors.red, fontSize: 13.sp, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildChallengersSection() {
    return Obx(() {
      final status = createVM.invitationResponse.value.status;
      final challengers = createVM.filteredChallengers.value;

      if (status == Status.loading) {
        return _emptyState('Loading challengers...', Icons.hourglass_empty);
      }

      if (status == Status.error) {
        return _emptyState('Failed to load challengers', Icons.error_outline, retry: createVM.fetchInvitations);
      }

      if (challengers.isEmpty) {
        return _emptyState(
          'No Challenges Yet',
          Icons.group_off,
          subtitle: 'When someone challenges you, they will appear here.\nShare your invite code to get started!',
        );
      }

      return _ChallengersList(challengers: challengers);
    });
  }

  Widget _emptyState(String title, IconData icon, {String? subtitle, VoidCallback? retry}) {
    return Container(
      height: 300.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 20.h),
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            if (subtitle != null) ...[
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
              ),
            ],
            if (retry != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton(onPressed: retry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Widgets (All included)

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xff24387F))),
    ),
  );
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onClear;
  const _SearchBar({required this.controller, required this.hint, this.onClear});

  @override Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(onTap: onClear, child: Icon(Icons.close, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}

class _PlayersList extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  const _PlayersList({required this.players});

  @override Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Container(
        height: 120.h,
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16.r)),
        child: Center(child: Text('No players found', style: TextStyle(color: Colors.grey.shade600))),
      );
    }

    return Container(
      height: 180.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16.r)),
      child: ListView.separated(
        padding: EdgeInsets.all(12.w),
        itemCount: players.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (_, i) => _PlayerCard(player: players[i]),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerCard({required this.player});

  @override Widget build(BuildContext context) {
    final createVM = Get.find<ChallengeCreateViewModel>();
    final playerId = player['id']?.toString() ?? '';
    final playerName = player['name']?.toString() ?? 'Unknown';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: AppColors.primaryRed),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22.r, backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, color: Colors.blue.shade700)),
          SizedBox(width: 12.w),
          Expanded(child: Text(playerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
          Obx(() {
            final isLoading = createVM.isChallengingPlayer(playerId);
            return ElevatedButton(
              onPressed: playerId.isNotEmpty && !isLoading ? () => createVM.sendChallengeInvite(playerId) : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(horizontal: 16.w)),
              child: isLoading
                  ? SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text("Challenge", style: TextStyle(fontSize: 12.sp)),
            );
          }),
        ],
      ),
    );
  }
}

class _ChallengersList extends StatelessWidget {
  final List<Map<String, dynamic>> challengers;
  const _ChallengersList({required this.challengers});

  @override Widget build(BuildContext context) {
    final height = challengers.length > 2 ? 320.h : challengers.length * 160.h;
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: challengers.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, i) => _ChallengerCard(challenger: challengers[i]),
      ),
    );
  }
}

class _ChallengerCard extends StatelessWidget {
  final Map<String, dynamic> challenger;
  const _ChallengerCard({required this.challenger});

  @override Widget build(BuildContext context) {
    final createVM = Get.find<ChallengeCreateViewModel>();
    final data = challenger['challenge']?['hostDetail'] ?? {};
    final name = data['name']?.toString() ?? 'Unknown';
    final level = data['rank']?.toString() ?? '1';
    final points = data['totalPoints']?.toString() ?? '0';
    final invitationId = challenger['id']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24.r, backgroundColor: Colors.orange.shade100, child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                  Text('Level $level • $points pts', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                ]),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: invitationId.isNotEmpty ? () => createVM.respondToChallenge(invitationId, true) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20.r)),
                    child: Text('Accept', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: invitationId.isNotEmpty ? () => createVM.respondToChallenge(invitationId, false) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(20.r)),
                    child: Text('Decline', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}