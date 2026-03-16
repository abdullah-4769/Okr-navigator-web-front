//
// import 'package:flutter/material.dart';
// import 'dart:math';
//
// void main() {
//   runApp(const CarSwipeApp());
// }
//
// typedef MyApp = CarSwipeApp;
//
// class CarSwipeApp extends StatelessWidget {
//   const CarSwipeApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Car Swipe',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFDDEEFB)),
//       home: const CarSwipeScreen(),
//     );
//   }
// }
//
// // ─── Car Data ────────────────────────────────────────────────────────────────
//
// class CarData {
//   final String name;
//   final String year;
//   final String price;
//   final String imageUrl;
//   final String tag;
//
//   const CarData({
//     required this.name,
//     required this.year,
//     required this.price,
//     required this.imageUrl,
//     required this.tag,
//   });
// }
//
// final List<CarData> _cars = [
//   CarData(name: 'Ferrari 488', year: '2023', price: '\$280,000', tag: '🔥 Exotic',
//       imageUrl: 'https://images.unsplash.com/photo-1592198084033-aade902d1aae?w=600&q=80'),
//   CarData(name: 'Lamborghini Huracán', year: '2023', price: '\$261,274', tag: '⚡ Supercar',
//       imageUrl: 'https://images.unsplash.com/photo-1519245659620-e859806a8d3b?w=600&q=80'),
//   CarData(name: 'Porsche 911 GT3', year: '2022', price: '\$161,100', tag: '🏁 Track',
//       imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80'),
//   CarData(name: 'McLaren 720S', year: '2023', price: '\$299,000', tag: '💎 Luxury',
//       imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80'),
//   CarData(name: 'Aston Martin DB11', year: '2022', price: '\$205,000', tag: '🎩 Grand Tourer',
//       imageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=600&q=80'),
//   CarData(name: 'Bugatti Chiron', year: '2023', price: '\$3,000,000', tag: '👑 Hypercar',
//       imageUrl: 'https://images.unsplash.com/photo-1617814076668-8b5fa4b6e954?w=600&q=80'),
//   CarData(name: 'Mercedes AMG GT', year: '2023', price: '\$118,000', tag: '⚙️ Sport',
//       imageUrl: 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=600&q=80'),
//   CarData(name: 'Rolls Royce Phantom', year: '2023', price: '\$460,000', tag: '✨ Ultra Luxury',
//       imageUrl: 'https://images.unsplash.com/photo-1563720223523-1d42f3e38e5b?w=600&q=80'),
// ];
//
// // ─── Main Screen ─────────────────────────────────────────────────────────────
//
// class CarSwipeScreen extends StatefulWidget {
//   const CarSwipeScreen({super.key});
//
//   @override
//   State<CarSwipeScreen> createState() => _CarSwipeScreenState();
// }
//
// class _CarSwipeScreenState extends State<CarSwipeScreen> {
//   List<CarData> _cardStack = List.from(_cars);
//
//   void _onSwipeCompleted() {
//     setState(() {
//       if (_cardStack.isNotEmpty) _cardStack.removeLast();
//     });
//   }
//
//   void _resetCards() {
//     setState(() {
//       _cardStack = List.from(_cars);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFDDEEFB),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Minimal header
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ShaderMask(
//                     shaderCallback: (b) => const LinearGradient(
//                       colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
//                     ).createShader(b),
//                     child: const Text(
//                       'DRIVESWIPE',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.white,
//                         letterSpacing: 3,
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: _resetCards,
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Card stack
//             Expanded(child: _buildCardStack()),
//
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCardStack() {
//     if (_cardStack.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
//                 ),
//                 borderRadius: BorderRadius.circular(40),
//               ),
//               child: const Icon(Icons.directions_car, size: 40, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             const Text('All cars swiped!',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: _resetCards,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
//                   ),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: const Text('Start Again',
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final cardW = constraints.maxWidth * 0.82;
//       final cardH = constraints.maxHeight * 0.90;
//       // Show max 2 background cards
//       final bgCount = min(_cardStack.length - 1, 2);
//
//       return Stack(
//         alignment: Alignment.center,
//         clipBehavior: Clip.none,
//         children: [
//           // Furthest back card (depth 2)
//           if (bgCount >= 2)
//             _BackgroundCard(
//               car: _cardStack[_cardStack.length - 3],
//               depth: 2,
//               cardW: cardW,
//               cardH: cardH,
//             ),
//           // Second card (depth 1, just below top)
//           if (bgCount >= 1)
//             _BackgroundCard(
//               car: _cardStack[_cardStack.length - 2],
//               depth: 1,
//               cardW: cardW,
//               cardH: cardH,
//             ),
//           // Top swipeable card
//           SwipeCard(
//             key: ValueKey(_cardStack.last.name),
//             car: _cardStack.last,
//             cardW: cardW,
//             cardH: cardH,
//             onSwipeCompleted: _onSwipeCompleted,
//           ),
//         ],
//       );
//     });
//   }
// }
//
// // ─── Background Card ──────────────────────────────────────────────────────────
//
// class _BackgroundCard extends StatelessWidget {
//   final CarData car;
//   final int depth; // 1 = just below top, 2 = further below
//   final double cardW;
//   final double cardH;
//
//   const _BackgroundCard({
//     required this.car,
//     required this.depth,
//     required this.cardW,
//     required this.cardH,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Scale down slightly and push DOWN so peeking is at the bottom only
//     final scale = 1.0 - depth * 0.05;
//     final translateY = depth * 16.0; // positive = move down → peeking at bottom
//
//     return Transform(
//       transform: Matrix4.identity()
//         ..translate(0.0, translateY)
//         ..scale(scale),
//       alignment: Alignment.topCenter,
//       child: Container(
//         width: cardW,
//         height: cardH,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           gradient: const LinearGradient(
//             colors: [Color(0xFFFF4500), Color(0xFFFF6B35), Color(0xFFFF8C00)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFFFF4500).withOpacity(0.12),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(3.5),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(21),
//           child: Image.network(
//             car.imageUrl,
//             fit: BoxFit.cover,
//             // Simple solid background while loading (no shimmer/grey)
//             loadingBuilder: (ctx, child, prog) {
//               if (prog == null) return child;
//               return Container(color: const Color(0xFF1E3A5F));
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Swipe Card ───────────────────────────────────────────────────────────────
//
// class SwipeCard extends StatefulWidget {
//   final CarData car;
//   final double cardW;
//   final double cardH;
//   final VoidCallback onSwipeCompleted;
//
//   const SwipeCard({
//     super.key,
//     required this.car,
//     required this.cardW,
//     required this.cardH,
//     required this.onSwipeCompleted,
//   });
//
//   @override
//   State<SwipeCard> createState() => _SwipeCardState();
// }
//
// class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   Offset _drag = Offset.zero;
//   double _angle = 0;
//   bool _isFlying = false;
//
//   static const double _threshold = 90;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   void _onPanUpdate(DragUpdateDetails d) {
//     if (_isFlying) return;
//     setState(() {
//       _drag += d.delta;
//       _angle = _drag.dx * 0.001 * pi;
//     });
//   }
//
//   void _onPanEnd(DragEndDetails d) {
//     if (_isFlying) return;
//     final vel = d.velocity.pixelsPerSecond;
//     if (_drag.dx.abs() > _threshold || vel.dx.abs() > 350) {
//       _flyOut(_drag.dx > 0, d.velocity);
//     } else if (_drag.dy < -_threshold || vel.dy < -350) {
//       _flyUp();
//     } else {
//       _snapBack();
//     }
//   }
//
//   void _flyOut(bool right, Velocity velocity) {
//     setState(() => _isFlying = true);
//     final screenW = MediaQuery.of(context).size.width;
//     final targetX = right ? screenW * 1.6 : -screenW * 1.6;
//     final targetY = _drag.dy + velocity.pixelsPerSecond.dy * 0.12;
//     _animate(Offset(targetX, targetY), right ? 0.38 : -0.38);
//   }
//
//   void _flyUp() {
//     setState(() => _isFlying = true);
//     final screenH = MediaQuery.of(context).size.height;
//     _animate(Offset(_drag.dx, -screenH * 1.6), _angle);
//   }
//
//   void _animate(Offset endPos, double endAngle) {
//     _ctrl.value = 0;
//     final startPos = _drag;
//     final startAngle = _angle;
//
//     final posAnim = Tween(begin: startPos, end: endPos)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
//     final angAnim = Tween(begin: startAngle, end: endAngle)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
//
//     void listener() {
//       setState(() {
//         _drag = posAnim.value;
//         _angle = angAnim.value;
//       });
//     }
//
//     _ctrl.addListener(listener);
//     _ctrl.forward().then((_) {
//       _ctrl.removeListener(listener);
//       widget.onSwipeCompleted();
//     });
//   }
//
//   void _snapBack() {
//     _ctrl.value = 0;
//     final startPos = _drag;
//     final startAngle = _angle;
//
//     final posAnim = Tween(begin: startPos, end: Offset.zero)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
//     final angAnim = Tween(begin: startAngle, end: 0.0)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
//
//     void listener() {
//       setState(() {
//         _drag = posAnim.value;
//         _angle = angAnim.value;
//       });
//     }
//
//     _ctrl.addListener(listener);
//     _ctrl.forward().then((_) => _ctrl.removeListener(listener));
//   }
//
//   double get _likeOpacity => (_drag.dx / _threshold).clamp(0.0, 1.0);
//   double get _nopeOpacity => (-_drag.dx / _threshold).clamp(0.0, 1.0);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanUpdate: _onPanUpdate,
//       onPanEnd: _onPanEnd,
//       child: Transform(
//         transform: Matrix4.identity()
//           ..translate(_drag.dx, _drag.dy)
//           ..rotateZ(_angle),
//         alignment: Alignment.bottomCenter,
//         child: Container(
//           width: widget.cardW,
//           height: widget.cardH,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(24),
//             gradient: const LinearGradient(
//               colors: [Color(0xFFFF4500), Color(0xFFFF6B35), Color(0xFFFF8C00)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFFFF4500).withOpacity(0.4),
//                 blurRadius: 30,
//                 offset: const Offset(0, 14),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.all(3.5),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(21),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 // Car image
//                 Image.network(
//                   widget.car.imageUrl,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (ctx, child, prog) {
//                     if (prog == null) return child;
//                     return Container(
//                       color: const Color(0xFF0D1B2A),
//                       child: const Center(
//                         child: CircularProgressIndicator(
//                             color: Color(0xFFFF8C00), strokeWidth: 2),
//                       ),
//                     );
//                   },
//                 ),
//                 // Bottom gradient overlay
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Colors.black.withOpacity(0.08),
//                         Colors.black.withOpacity(0.72),
//                       ],
//                       stops: const [0.45, 0.65, 1.0],
//                     ),
//                   ),
//                 ),
//                 // LIKE stamp
//                 Positioned(
//                   top: 30,
//                   left: 20,
//                   child: Opacity(
//                     opacity: _likeOpacity,
//                     child: Transform.rotate(
//                       angle: -0.28,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade600,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.white, width: 2.5),
//                         ),
//                         child: const Text('LIKE ❤️',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w900,
//                               fontSize: 20,
//                               letterSpacing: 2,
//                             )),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // NOPE stamp
//                 Positioned(
//                   top: 30,
//                   right: 20,
//                   child: Opacity(
//                     opacity: _nopeOpacity,
//                     child: Transform.rotate(
//                       angle: 0.28,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade700,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.white, width: 2.5),
//                         ),
//                         child: const Text('NOPE ✕',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w900,
//                               fontSize: 20,
//                               letterSpacing: 2,
//                             )),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Car info at bottom
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(22),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(widget.car.tag,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 0.5,
//                               )),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(widget.car.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 26,
//                               fontWeight: FontWeight.w900,
//                               shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
//                             )),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Text(widget.car.year,
//                                 style: TextStyle(
//                                     color: Colors.white.withOpacity(0.75), fontSize: 14)),
//                             const SizedBox(width: 14),
//                             Text(widget.car.price,
//                                 style: const TextStyle(
//                                   color: Color(0xFFFFD166),
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 )),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/app_binding.dart';
import 'core/app_theme.dart';
import 'core/localization/app_translation.dart';
import 'core/localization/localization_services.dart';
import 'data/datasources/auth_api.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'generated/network.dart'; // DioClient
import 'presentation/routes/app_routes.dart';
import 'view_model/challange_view_models/adaptation_ai_analysis-viewmodel.dart';
import 'services/shared_preference.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage
  await GetStorage.init();
  Get.lazyPut(() => StorageRepository(), fenix: true);

  // Localization
  final localizationService = LocalizationService();
  await localizationService.init();
  await SharedPrefs.init();
  // ViewModels
  Get.lazyPut(() => AdaptationAIAnalysisViewModel(), fenix: true);

  // IMPORTANT ❗ Initialize Dio BEFORE injecting AuthApi
  await Get.putAsync(() => DioClient().init());

  // Now inject API + Repository
  Get.put<AuthApi>(AuthApi(dio), permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(Get.find<AuthApi>()),
    permanent: true,
  );

  runApp(MyApp(localizationService: localizationService));
}

class MyApp extends StatelessWidget {
  final LocalizationService localizationService;
  const MyApp({super.key, required this.localizationService});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 784),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Game App',

          // Localization
          translations: AppTranslations(),
          locale: localizationService.currentLocale,
          fallbackLocale: const Locale('en'),

          // Global Dependency Bindings
          initialBinding: AppBindings(),

          // App Routes
          initialRoute: AppRoutes.splash0,
          getPages: AppRoutes.pages,

          theme: appTheme,

          builder: (context, widget) {
            ScreenUtil.init(
              context,
              designSize: const Size(360, 784),
              minTextAdapt: true,
              splitScreenMode: true,
            );

            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: widget!,
            );
          },
        ));
      },
    );
  }
}

