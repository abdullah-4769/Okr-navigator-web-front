import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/scoreboard_controllers/score_board_controller.dart';
import '../widgets/Website/desktop_appbar.dart';
import '../widgets/custom_home_navbar.dart';
import '../widgets/custom_svg.dart';
import '../widgets/global_widgets/custom_top_performer_widget.dart';
import '../widgets/mode_selecter_widget.dart';
import '../widgets/rank_item_widget.dart';
import '../widgets/screens_unique_parts/custom_background.dart';
import '../widgets/screens_unique_parts/custom_header.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScoreboardController());
    final double sw = MediaQuery.of(context).size.width;
    return sw < 768
        ? _buildMobileLayout(context, sw, controller)
        : _buildDesktopLayout(context, sw, controller);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(
      BuildContext context, double sw, ScoreboardController controller) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  CustomHeader(
                    title: 'your'.tr,
                    highlightedText: 'scoreboard'.tr,
                    subtitle: '',
                    onBackTap: () => Get.back(),
                  ),
                  const SizedBox(height: 10),
                  const ModeSelectorWidget(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildBody(context, controller, isDesktop: false)),
                ],
              ),
              Positioned(
                right: sw * -0.07,
                top: MediaQuery.of(context).size.height * 0.5,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(
      BuildContext context, double sw, ScoreboardController controller) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 900.0 : sw * 0.80;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png',
                  fit: BoxFit.cover),
            ),
          ),

          // AppBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw,
              screenHeight: sh,
              title: 'your'.tr,
              subtitle: 'scoreboard'.tr,
            ),
          ),

          // Centered card
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const ModeSelectorWidget(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildBody(context, controller, isDesktop: true),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(
                  assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),

          // Home NavBar
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── SHARED BODY ────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, ScoreboardController controller,
      {required bool isDesktop}) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.red),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading scoreboard',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchScoreboard(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: isDesktop ? 16 : 0),
        child: isDesktop
            ? _buildDesktopContent(context, controller)
            : _buildMobileContent(context, controller),
      );
    });
  }

  // ── MOBILE CONTENT ─────────────────────────────────────────────────────────

  Widget _buildMobileContent(
      BuildContext context, ScoreboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Text(
            'show_personal_achievements'.tr,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 10),
        CustomTopPerformerWidget(topThree: controller.topThree),
        const SizedBox(height: 20),
        _buildUserRankBadge(controller),
        const SizedBox(height: 20),
        _buildLeaderboard(context, controller, isDesktop: false),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── DESKTOP CONTENT ────────────────────────────────────────────────────────

  Widget _buildDesktopContent(
      BuildContext context, ScoreboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal achievements link + user rank badge on same row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'show_personal_achievements'.tr,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
              if (controller.userDetails.value != null)
                _buildUserRankBadge(controller, compact: true),
            ],
          ),
          const SizedBox(height: 20),

          // Podium + leaderboard side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: podium
              Expanded(
                flex: 4,
                child: CustomTopPerformerWidget(topThree: controller.topThree),
              ),
              const SizedBox(width: 24),
              // Right: leaderboard
              Expanded(
                flex: 6,
                child: _buildLeaderboard(context, controller, isDesktop: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SHARED SUB-WIDGETS ─────────────────────────────────────────────────────

  Widget _buildUserRankBadge(ScoreboardController controller,
      {bool compact = false}) {
    if (controller.userDetails.value == null) return const SizedBox.shrink();
    return Container(
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          const Icon(Icons.emoji_events, color: Colors.red, size: 22),
          const SizedBox(width: 10),
          Text(
            'I\'m ranked #${controller.userDetails.value?.rank ?? 'N/A'} in ${controller.getModeName()} this week!',
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, ScoreboardController controller,
      {required bool isDesktop}) {
    return Padding(
      padding: isDesktop
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'leaderboard'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: isDesktop ? 18 : null,
            ),
          ),
          const SizedBox(height: 16),
          if (controller.allPlayers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No leaderboard data available',
                    style: TextStyle(color: Colors.black54)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.allPlayers.length,
              itemBuilder: (context, index) {
                final player = controller.allPlayers[index];
                final isCurrentUser =
                    controller.userDetails.value?.userId == player.userId;
                return RankItemWidget(
                  player: player,
                  isCurrentUser: isCurrentUser,
                  isDesktop: isDesktop,
                );
              },
            ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/scoreboard_controllers/score_board_controller.dart';
// import '../widgets/global_widgets/custom_top_performer_widget.dart';
//
// import '../widgets/mode_selecter_widget.dart';
// import '../widgets/rank_item_widget.dart';
// import '../widgets/screens_unique_parts/custom_header.dart';
//
// class ScoreboardScreen extends StatelessWidget {
//   const ScoreboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ScoreboardController());
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             CustomHeader(
//               title: "your".tr,
//               highlightedText: "scoreboard".tr,
//               subtitle: "".tr,
//               onBackTap: () => Get.back(),
//             ),
//             Container(
//               child: const Column(
//                 children: [
//                   SizedBox(height: 10),
//                   ModeSelectorWidget(),
//                   SizedBox(height: 10),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Obx(() {
//                 if (controller.isLoading.value) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.red,
//                     ),
//                   );
//                 }
//
//                 if (controller.errorMessage.value.isNotEmpty) {
//                   return Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             size: 60,
//                             color: Colors.red,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Error loading scoreboard',
//                             style: Theme.of(context).textTheme.titleLarge,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             controller.errorMessage.value,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(color: Colors.black54),
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton.icon(
//                             onPressed: () => controller.fetchScoreboard(),
//                             icon: const Icon(Icons.refresh),
//                             label: const Text('Retry'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//
//                 return SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       Center(
//                         child: Text(
//                           'show_personal_achievements'.tr,
//                           style: TextStyle(
//                             color: Colors.blue.shade700,
//                             fontSize: 14,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       CustomTopPerformerWidget(
//                          topThree: controller.topThree,
//                       ),
//                       const SizedBox(height: 20),
//                       if (controller.userDetails.value != null)
//                         Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 16),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.emoji_events,
//                                 color: Colors.red,
//                                 size: 24,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   'I\'m ranked #${controller.userDetails.value?.rank ?? 'N/A'} in ${controller.getModeName()} this week!',
//                                   style: const TextStyle(
//                                     color: Colors.black87,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       const SizedBox(height: 20),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'leaderboard'.tr,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleLarge
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             if (controller.allPlayers.isEmpty)
//                               const Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(20.0),
//                                   child: Text(
//                                     'No leaderboard data available',
//                                     style: TextStyle(color: Colors.black54),
//                                   ),
//                                 ),
//                               )
//                             else
//                               ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: controller.allPlayers.length,
//                                 itemBuilder: (context, index) {
//                                   final player = controller.allPlayers[index];
//                                   final isCurrentUser =
//                                       controller.userDetails.value?.userId ==
//                                           player.userId;
//
//                                   // Use computed rank (from sorting) or fallback
//                                   final displayRank = player.rank ?? (index + 1);
//
//                                   return RankItemWidget(
//                                     player: player,
//                                     // rank: displayRank,
//                                     isCurrentUser: isCurrentUser,
//                                   );
//                                 },
//                               ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
