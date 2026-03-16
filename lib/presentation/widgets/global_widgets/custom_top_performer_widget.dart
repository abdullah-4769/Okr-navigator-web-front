import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../generated/models/responses/dashboard_for_all/dashboard_all.dart';

class CustomTopPerformerWidget extends StatelessWidget {
  final List<PlayerModel> topThree;

  const CustomTopPerformerWidget({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;
    final double sh = MediaQuery.of(context).size.height;

    if (topThree.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No top performers available'.tr),
        ),
      );
    }

    final List<PlayerModel> sorted = List.from(topThree)
      ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 12 : 16.w),
      child: LayoutBuilder(builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double blockW = (maxW / 3) - (isDesktop ? 10 : 16.w);

        // Podium heights — capped on desktop so they don't dominate the layout
        final double h1 = isDesktop ? 160 : sh * 0.26;
        final double h2 = isDesktop ? 130 : sh * 0.20;
        final double h3 = isDesktop ? 115 : sh * 0.18;
        final double avatarSz = isDesktop ? 44 : 55.w;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 🥈 2nd
            if (sorted.length > 1)
              Flexible(
                child: _buildPodiumTile(
                  player: sorted[1], rank: 2,
                  height: h2, blockWidth: blockW, avatarSize: avatarSz,
                  isDesktop: isDesktop,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
              )
            else SizedBox(width: blockW),

            // 🥇 1st
            if (sorted.isNotEmpty)
              Flexible(
                child: _buildPodiumTile(
                  player: sorted[0], rank: 1,
                  height: h1, blockWidth: blockW, avatarSize: avatarSz,
                  isDesktop: isDesktop,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF176), Color(0xFFFBC02D)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
              ),

            // 🥉 3rd
            if (sorted.length > 2)
              Flexible(
                child: _buildPodiumTile(
                  player: sorted[2], rank: 3,
                  height: h3, blockWidth: blockW, avatarSize: avatarSz,
                  isDesktop: isDesktop,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
              )
            else SizedBox(width: blockW),
          ],
        );
      }),
    );
  }

  Widget _buildPodiumTile({
    required PlayerModel player,
    required int rank,
    required double height,
    required double blockWidth,
    required double avatarSize,
    required Gradient gradient,
    required bool isDesktop,
  }) {
    final String name  = player.name ?? 'Unknown';
    final int score    = player.totalScore ?? 0;
    final String level = player.level ?? '0';

    final double rankBadge  = isDesktop ? 11  : 12.sp;
    final double scoreFont  = isDesktop ? 15  : 18.sp;
    final double nameFont   = isDesktop ? 11  : 14.sp;
    final double levelFont  = isDesktop ? 9   : 8.sp;
    final double borderW    = isDesktop ? 1.5 : 2.w;
    final double badgePad   = isDesktop ? 3   : 4.w;
    final double gapAbove   = isDesktop ? 6   : 8.h;
    final double gapInBlock = isDesktop ? 4   : 6.h;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 4 : 6.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: rank == 1 ? Colors.red : Colors.blue,
                  width: borderW,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: SizedBox(
                  width: avatarSize,
                  height: avatarSize,
                  child: player.avatarPicId != null &&
                      player.avatarPicId!.isNotEmpty
                      ? Image.network(
                    player.avatarPicId!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(name, rank, avatarSize),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: rank == 1 ? Colors.red : Colors.blue,
                        ),
                      );
                    },
                  )
                      : _buildDefaultAvatar(name, rank, avatarSize),
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              child: Container(
                padding: EdgeInsets.all(badgePad),
                decoration: BoxDecoration(
                  color: rank == 1 ? Colors.red : Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: rankBadge,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: gapAbove),

        // Podium block
        Container(
          height: height,
          width: blockWidth,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(isDesktop ? 10 : 12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(2, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⭐\n$score',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: scoreFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: gapInBlock),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 2 : 2.w),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: nameFont,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: isDesktop ? 3 : 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('level'.tr,
                      style: TextStyle(fontSize: levelFont, color: Colors.black54)),
                  Text('$level',
                      style: TextStyle(fontSize: levelFont, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name, int rank, double size) {
    final Color bg = rank == 1
        ? Colors.red.withOpacity(0.1)
        : rank == 2
        ? Colors.blue.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);
    final Color fg = rank == 1
        ? Colors.red
        : rank == 2
        ? Colors.blue
        : Colors.orange;
    return Container(
      color: bg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import '../../../generated/models/responses/dashboard_for_all/dashboard_all.dart';
//
// class CustomTopPerformerWidget extends StatelessWidget {
//   final List<PlayerModel> topThree;
//
//   const CustomTopPerformerWidget({
//     super.key,
//     required this.topThree,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isPortrait = size.height > size.width;
//
//     if (topThree.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Text('No top performers available'.tr),
//         ),
//       );
//     }
//
//     // Sort by rank
//     final List<PlayerModel> sortedTop = List.from(topThree);
//     sortedTop.sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));
//
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final maxWidth = constraints.maxWidth;
//           final blockWidth = (maxWidth / 3) - 16.w;
//
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               /// 🥈 2nd Place
//               if (sortedTop.length > 1)
//                 Flexible(
//                   child: _buildPodiumTile(
//                     player: sortedTop[1],
//                     rank: 2,
//                     height: isPortrait
//                         ? size.height * 0.20
//                         : size.height * 0.25,
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     width: blockWidth,
//                   ),
//                 )
//               else
//                 SizedBox(width: blockWidth),
//
//               /// 🥇 1st Place
//               if (sortedTop.isNotEmpty)
//                 Flexible(
//                   child: _buildPodiumTile(
//                     player: sortedTop[0],
//                     rank: 1,
//                     height: isPortrait
//                         ? size.height * 0.26
//                         : size.height * 0.32,
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFFFF176), Color(0xFFFBC02D)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     width: blockWidth,
//                   ),
//                 ),
//
//               /// 🥉 3rd Place
//               if (sortedTop.length > 2)
//                 Flexible(
//                   child: _buildPodiumTile(
//                     player: sortedTop[2],
//                     rank: 3,
//                     height: isPortrait
//                         ? size.height * 0.18
//                         : size.height * 0.22,
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     width: blockWidth,
//                   ),
//                 )
//               else
//                 SizedBox(width: blockWidth),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   /// 🔥 Podium Tile Builder
//   Widget _buildPodiumTile({
//     required PlayerModel player,
//     required int rank,
//     required double height,
//     required Gradient gradient,
//     required double width,
//   }) {
//     final name = player.name ?? 'Unknown';
//     final score = player.totalScore ?? 0;
//     final level = player.level ?? '0';
//     final avatarPicId = player.avatarPicId;
//
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         /// Avatar + Rank
//         Stack(
//           alignment: Alignment.center,
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               padding: EdgeInsets.all(6.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: rank == 1 ? Colors.red : Colors.blue,
//                   width: 2.w,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(2, 4),
//                   ),
//                 ],
//               ),
//               child: ClipOval(
//                 child: SizedBox(
//                   height: 55.w,
//                   width: 55.w,
//                   child: avatarPicId != null && avatarPicId.isNotEmpty
//                       ? Image.network(
//                     avatarPicId,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return _buildDefaultAvatar(name, rank);
//                     },
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return Center(
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: rank == 1 ? Colors.red : Colors.blue,
//                         ),
//                       );
//                     },
//                   )
//                       : _buildDefaultAvatar(name, rank),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: -5,
//               child: Container(
//                 padding: EdgeInsets.all(4.w),
//                 decoration: BoxDecoration(
//                   color: rank == 1 ? Colors.red : Colors.black87,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: Text(
//                   "$rank",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 8.h),
//
//         /// Podium Block
//         Container(
//           height: height,
//           width: width,
//           decoration: BoxDecoration(
//             gradient: gradient,
//             borderRadius: BorderRadius.circular(12.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 offset: const Offset(2, 4),
//                 blurRadius: 6,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(
//                 child: Text(
//                   "⭐\n$score",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 6.h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 2.w),
//                 child: Text(
//                   name,
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     "level".tr,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 8.sp,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   Text(
//                     "$level",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 8.sp,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Default Avatar (when image is null or fails to load)
//   Widget _buildDefaultAvatar(String name, int rank) {
//     return Container(
//       color: rank == 1
//           ? Colors.red.withOpacity(0.1)
//           : rank == 2
//           ? Colors.blue.withOpacity(0.1)
//           : Colors.orange.withOpacity(0.1),
//       child: Center(
//         child: Text(
//           name.isNotEmpty ? name[0].toUpperCase() : 'U',
//           style: TextStyle(
//             fontSize: 28.sp,
//             fontWeight: FontWeight.bold,
//             color: rank == 1
//                 ? Colors.red
//                 : rank == 2
//                 ? Colors.blue
//                 : Colors.orange,
//           ),
//         ),
//       ),
//     );
//   }
// }