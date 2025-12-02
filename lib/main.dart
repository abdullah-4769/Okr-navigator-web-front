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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage
  await GetStorage.init();
  Get.lazyPut(() => StorageRepository(), fenix: true);

  // Localization
  final localizationService = LocalizationService();
  await localizationService.init();

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
