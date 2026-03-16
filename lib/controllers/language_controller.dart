import 'package:game_app/generated/models/enums/language_enum.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/localization/localization_services.dart';

class LanguageController extends GetxController {
  final LocalizationService _localizationService =
  Get.find<LocalizationService>();

  final _storage = GetStorage();
  static const String _storageKey = 'langCode';

  /// Reactive selected language code
  final Rx<SupportedLanguage> selectedLanguage = SupportedLanguage.en.obs;

  /// Add this getter for supported languages data
  List<Map<String, String>> get supportedLanguages => [
    {
      'code': SupportedLanguage.en.code,
      'name': SupportedLanguage.en.name,
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': SupportedLanguage.es.code,
      'name': SupportedLanguage.es.name,
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
    {
      'code': SupportedLanguage.fr.code,
      'name': SupportedLanguage.fr.name,
      'nativeName': 'Français',
      'flag': '🇫🇷',
    },

  ];

  @override
  void onInit() {
    super.onInit();
    final currentLanguage =
        _storage.read(_storageKey) ?? _localizationService.currentLanguageCode;

    try {
      // Load saved or fallback language
      selectedLanguage.value = SupportedLanguage.values.byName(currentLanguage);
    } catch (e) {
      // Fallback to English if language not found
      selectedLanguage.value = SupportedLanguage.en;
    }

    // Apply language immediately
    _localizationService.changeLocale(selectedLanguage.value.code);
  }

  /// Change the app language dynamically
  void changeLanguage(SupportedLanguage supportedLang) {
    if (selectedLanguage.value == supportedLang) return;

    selectedLanguage.value = supportedLang;
    _localizationService.changeLocale(supportedLang.code);

    // Persist in storage
    _storage.write(_storageKey, supportedLang.code);
  }

  /// Helper method to change language by code string
  void changeLanguageByCode(String languageCode) {
    try {
      final language = SupportedLanguage.values.firstWhere(
            (lang) => lang.code == languageCode,
        orElse: () => SupportedLanguage.en,
      );
      changeLanguage(language);
    } catch (e) {
      // Fallback to English
      changeLanguage(SupportedLanguage.en);
    }
  }

  SupportedLanguage get currentLanguage => selectedLanguage.value;

  /// Get language by code
  Map<String, String>? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere(
            (lang) => lang['code'] == code,
        orElse: () => supportedLanguages.first,
      );
    } catch (e) {
      return supportedLanguages.first;
    }
  }
}


// import 'package:game_app/generated/models/enums/language_enum.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// import '../../core/localization/localization_services.dart';
//
// class LanguageController extends GetxController {
//   final LocalizationService _localizationService =
//       Get.find<LocalizationService>();
//
//   final _storage = GetStorage();
//   static const String _storageKey = 'langCode';
//
//   /// Reactive selected language code
//   final Rx<SupportedLanguage> selectedLanguage = SupportedLanguage.en.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     final currentLanguage =
//         _storage.read(_storageKey) ?? _localizationService.currentLanguageCode;
//     // Load saved or fallback language
//     selectedLanguage.value = SupportedLanguage.values.byName(currentLanguage);
//
//     // Apply language immediately
//     _localizationService.changeLocale(selectedLanguage.value.code);
//   }
//
//   /// Change the app language dynamically
//   void changeLanguage(SupportedLanguage supportedLang) {
//     if (selectedLanguage.value == supportedLang) return;
//
//     selectedLanguage.value = supportedLang;
//     _localizationService.changeLocale(supportedLang.code);
//
//     // Persist in storage
//     _storage.write(_storageKey, supportedLang.code);
//   }
//
//   SupportedLanguage get currentLanguage => selectedLanguage.value;
//
//   /// Get language details
//   // Map<String, String>? getLanguageByCode(String code) =>
//   //     supportedLanguages.firstWhere(
//   //       (lang) => lang['code'] == code,
//   //       orElse: () => supportedLanguages.first,
//   //     );
// }
