
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/app_binding.dart';
import 'core/app_theme.dart';
import 'core/localization/app_translation.dart';
import 'core/localization/localization_services.dart';
import 'presentation/routes/app_routes.dart';

Future<void> main() async {
  // Ensure Flutter engine and bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (GetStorage)
  await GetStorage.init();

  // Initialize localization service
  final localizationService = LocalizationService();
  await localizationService.init();

  // Run the app
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
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Observe locale changes dynamically
            return Obx(
                  () => GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Game App',
                translations: AppTranslations(), // For `.tr` localization
                locale: localizationService.currentLocale,
                fallbackLocale: const Locale('en'),

                // Inject all global bindings (controllers)
                initialBinding: AppBindings(),

                // App routes and initial screen
                initialRoute: AppRoutes.home,
                // initialRoute: AppRoutes.splash0,
                getPages: AppRoutes.pages,

                // Theme
                theme: appTheme,

                // Ensure UI scales correctly on all screens
                builder: (context, widget) {
                  ScreenUtil.init(
                    context,
                    designSize: const Size(360, 784),
                    minTextAdapt: true,
                    splitScreenMode: true,
                  );

                  // Remove scrollbars globally (for mobile, web, desktop)
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false,
                    ),
                    child: widget!,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// import 'controllers/game_mode_controller.dart';
// import 'controllers/journey_controller.dart';
// import 'core/app_binding.dart';
// import 'core/app_theme.dart';
// import 'core/localization/app_translation.dart';
// import 'core/localization/localization_services.dart';
// import 'presentation/routes/app_routes.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//
//   // Register controllers globally so they never get disposed
//   Get.put(GameModeController(), permanent: true);
//   Get.put(JourneyController(), permanent: true);
//
//   final localizationService = LocalizationService();
//   await localizationService.init();
//
//   runApp(MyApp(localizationService: localizationService));
// }
//
// class MyApp extends StatelessWidget {
//   final LocalizationService localizationService;
//   const MyApp({super.key, required this.localizationService});
//
//   @override
//   Widget build(BuildContext context) => ScreenUtilInit(
//       designSize: const Size(360, 784), // Base Figma/sketch design size
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         // Wrap with LayoutBuilder to adapt to all screen sizes (mobile, tablet, desktop)
//         return LayoutBuilder(
//           builder: (context, constraints) => Obx(
//                   () => GetMaterialApp(
//                 debugShowCheckedModeBanner: false,
//                 title: 'Game App',
//                 translations: AppTranslations(),
//                 locale: localizationService.currentLocale,
//                 fallbackLocale: const Locale('en'),
//                 initialBinding: AppBindings(),
//                 initialRoute: AppRoutes.splash0,
//                 getPages: AppRoutes.pages,
//                 theme: appTheme,
//                 builder: (context, widget) {
//                   // ✅ Ensures text & UI scale correctly everywhere
//                   ScreenUtil.init(
//                     context,
//                     designSize: const Size(360, 784),
//                     minTextAdapt: true,
//                     splitScreenMode: true,
//                   );
//
//                   // ✅ Removes scrollbars globally (mobile, web, desktop)
//                   return ScrollConfiguration(
//                     behavior: ScrollConfiguration.of(context).copyWith(
//                       scrollbars: false,
//                     ),
//                     child: widget!,
//                   );
//                 },
//               ),
//             ),
//         );
//       },
//     );
// }
