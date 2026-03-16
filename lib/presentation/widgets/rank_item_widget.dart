import 'package:flutter/material.dart';
import '../../../generated/models/responses/dashboard_for_all/dashboard_all.dart';

class RankItemWidget extends StatelessWidget {
  final PlayerModel player;
  final bool isCurrentUser;
  final bool isDesktop;

  const RankItemWidget({
    super.key,
    required this.player,
    this.isCurrentUser = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final double vPad  = isDesktop ? 8  : 8;
    final double hPad  = isDesktop ? 12 : 14;
    final double mb    = isDesktop ? 8  : 10;
    final double r     = isDesktop ? 24 : 30;
    final double avSz  = isDesktop ? 32 : 36;
    final double rankF = isDesktop ? 14 : 16;
    final double nameF = isDesktop ? 14 : 16;
    final double subF  = isDesktop ? 11 : 12;
    final double scoreF = isDesktop ? 16 : 18;

    return Container(
      padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
      margin: EdgeInsets.only(bottom: mb),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: isDesktop ? 28 : 32,
            child: Text(
              '${player.rank ?? 0}.',
              style: TextStyle(
                fontSize: rankF,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 8 : 12),

          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: player.avatarPicId != null
                ? ClipOval(
              child: Image.network(
                player.avatarPicId!,
                width: avSz,
                height: avSz,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildInitialAvatar(avSz),
              ),
            )
                : _buildInitialAvatar(avSz),
          ),
          SizedBox(width: isDesktop ? 10 : 12),

          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name ?? 'Unknown',
                  style: TextStyle(
                    fontSize: nameF,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Level ${player.level ?? 'N/A'} | ${player.totalScore ?? 0} Points',
                  style: TextStyle(
                    fontSize: subF,
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: isCurrentUser ? Colors.white : Colors.red,
                  size: isDesktop ? 16 : 18),
              const SizedBox(width: 4),
              Text(
                '${player.totalScore ?? 0}',
                style: TextStyle(
                  fontSize: scoreF,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(double size) {
    final String initial =
    player.name != null && player.name!.isNotEmpty ? player.name![0] : 'U';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import '../../../generated/models/responses/dashboard_for_all/dashboard_all.dart';
//
// class RankItemWidget extends StatelessWidget {
//   final PlayerModel player;
//   final bool isCurrentUser;
//
//   const RankItemWidget({
//     super.key,
//     required this.player,
//     this.isCurrentUser = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: isCurrentUser ? Colors.red : Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(
//           color: Colors.red,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Text(
//             '${player.rank ?? 0}.',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isCurrentUser ? Colors.white : Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.15),
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.red, width: 2),
//             ),
//             child: player.avatarPicId != null
//                 ? ClipOval(
//               child: Image.network(
//                 player.avatarPicId!,
//                 width: 36,
//                 height: 36,
//                 errorBuilder: (context, error, stackTrace) =>
//                     _buildInitialAvatar(),
//               ),
//             )
//                 : _buildInitialAvatar(),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   player.name ?? 'Unknown',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: isCurrentUser ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Level ${player.level ?? 'N/A'} | ${player.totalScore ?? 0} Points Earned',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isCurrentUser ? Colors.white70 : Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               const Icon(Icons.star, color: Colors.red, size: 18),
//               const SizedBox(width: 4),
//               Text(
//                 '${player.totalScore ?? 0}',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: isCurrentUser ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInitialAvatar() {
//     final String initial =
//     player.name != null && player.name!.isNotEmpty ? player.name![0] : 'U';
//     return Container(
//       width: 36,
//       height: 36,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Text(
//           initial.toUpperCase(),
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }
// }
