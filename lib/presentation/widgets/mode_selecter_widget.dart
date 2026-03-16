import 'package:flutter/material.dart';
import 'package:game_app/core/app_colors.dart';
import 'package:get/get.dart';
import '../../../controllers/scoreboard_controllers/score_board_controller.dart';

class ModeSelectorWidget extends StatelessWidget {
  const ModeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;
    // ✅ Get.find — controller already put by ScoreboardScreen
    final controller = Get.find<ScoreboardController>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : 14,
        vertical: isDesktop ? 8 : 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(
            () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModeButton('Solo'.tr, GameMode.solo,
                  controller.selectedMode.value == GameMode.solo, controller,
                  isDesktop: isDesktop),
              _buildModeButton('Team'.tr, GameMode.team,
                  controller.selectedMode.value == GameMode.team, controller,
                  isDesktop: isDesktop),
              _buildModeButton('camp'.tr, GameMode.campaign,
                  controller.selectedMode.value == GameMode.campaign, controller,
                  isDesktop: isDesktop),
              _buildModeButton('challenge'.tr, GameMode.challenge,
                  controller.selectedMode.value == GameMode.challenge, controller,
                  isDesktop: isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
      String label,
      GameMode mode,
      bool isSelected,
      ScoreboardController controller, {
        required bool isDesktop,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 6 : 4),
      child: ElevatedButton(
        onPressed: () => controller.changeMode(mode),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.red : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.red, width: 1),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 10 : 12,
            horizontal: isDesktop ? 18 : 20,
          ),
          elevation: isSelected ? 2 : 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 13 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:game_app/core/app_colors.dart';
// import 'package:get/get.dart';
//
// import '../../../controllers/scoreboard_controllers/score_board_controller.dart';
//
// class ModeSelectorWidget extends StatelessWidget {
//   const ModeSelectorWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<ScoreboardController>();
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Obx(
//             () => SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildModeButton(
//                 'Solo'.tr,
//                 GameMode.solo,
//                 controller.selectedMode.value == GameMode.solo,
//                 controller,
//               ),
//               _buildModeButton(
//                 'Team'.tr,
//                 GameMode.team,
//                 controller.selectedMode.value == GameMode.team,
//                 controller,
//               ),
//               _buildModeButton(
//                 'camp'.tr,
//                 GameMode.campaign,
//                 controller.selectedMode.value == GameMode.campaign,
//                 controller,
//               ),
//               _buildModeButton(
//                 'challenge'.tr,
//                 GameMode.challenge,
//                 controller.selectedMode.value == GameMode.challenge,
//                 controller,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildModeButton(
//       String label,
//       GameMode mode,
//       bool isSelected,
//       ScoreboardController controller,
//       ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ElevatedButton(
//         onPressed: () => controller.changeMode(mode),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isSelected ? Colors.red : Colors.white,
//           foregroundColor: isSelected ? Colors.white : Colors.red,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//             side: const BorderSide(color: Colors.red, width: 1),
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // horizontal padding added
//         ),
//         child: Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
