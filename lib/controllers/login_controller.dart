import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/snackbar_helper.dart';
import '../services/google_auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../presentation/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // final GoogleAuthService _googleAuthService = GoogleAuthService();

  late final AuthRepository authRepo = Get.find<AuthRepository>();
  late final StorageRepository _storageRepo = Get.find<StorageRepository>();

  final isGoogleLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  bool validateLoginForm() => formKey.currentState?.validate() ?? false;

  // EMAIL LOGIN - Uses saveUser()
  Future<void> login() async {
    if (!validateLoginForm()) return;
    isLoading.value = true;
    try {
      final user = await authRepo.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (rememberMe.value) await _storageRepo.saveUser(user);

      SnackbarHelper.success('Login successful');
      Get.offAllNamed(AppRoutes.start);
    } catch (e) {
      log("Login error: $e");
      SnackbarHelper.error("Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // GOOGLE LOGIN - Uses saveGoogleUser()
  // Future<void> loginWithGoogle() async {
  //   if (isGoogleLoading.value) return;
  //   isGoogleLoading.value = true;
  //   try {
  //     final idToken = await _googleAuthService.signInWithGoogle();
  //     if (idToken == null) {
  //       SnackbarHelper.error("Google Sign-In cancelled");
  //       return;
  //     }
  //
  //     // Backend se SaveUser milta hai
  //     final saveUser = await authRepo.loginWithGoogle(idToken);
  //
  //     // SaveUser ko directly save karo using saveGoogleUser()
  //     await _storageRepo.saveGoogleUser(saveUser);
  //
  //     SnackbarHelper.success("Welcome ${saveUser.name.split(' ').first}!");
  //     Get.offAllNamed(AppRoutes.start);
  //   } catch (e) {
  //     log("Google login error: $e");
  //     SnackbarHelper.error("Google login failed");
  //   } finally {
  //     isGoogleLoading.value = false;
  //   }
  // }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
// // controllers/login_controller.dart
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../utils/snackbar_helper.dart';
// import '../services/google_auth_service.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../data/repositories/storage_repository.dart';
// import '../../presentation/routes/app_routes.dart';
//
// class LoginController extends GetxController {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   final GoogleAuthService _googleAuthService = GoogleAuthService();
//
//   late final AuthRepository authRepo = Get.find<AuthRepository>();
//   late final StorageRepository _storageRepo = Get.find<StorageRepository>();
//
//   final isGoogleLoading = false.obs;
//   final isPasswordVisible = false.obs;
//   final rememberMe = false.obs;
//   final isLoading = false.obs;
//
//   void togglePasswordVisibility() => isPasswordVisible.toggle();
//   void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;
//
//   bool validateLoginForm() => formKey.currentState?.validate() ?? false;
//
//   // EMAIL LOGIN - Uses saveUser()
//   Future<void> login() async {
//     if (!validateLoginForm()) return;
//     isLoading.value = true;
//     try {
//       final user = await authRepo.login(
//         emailController.text.trim(),
//         passwordController.text,
//       );
//
//       if (rememberMe.value) await _storageRepo.saveUser(user);
//
//       SnackbarHelper.success('Login successful');
//       Get.offAllNamed(AppRoutes.start);
//     } catch (e) {
//       log("Login error: $e");
//       SnackbarHelper.error("Login failed: ${e.toString()}");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // GOOGLE LOGIN - Uses saveGoogleUser()
//   Future<void> loginWithGoogle() async {
//     if (isGoogleLoading.value) return;
//     isGoogleLoading.value = true;
//     try {
//       final idToken = await _googleAuthService.signInWithGoogle();
//       if (idToken == null) {
//         SnackbarHelper.error("Google Sign-In cancelled");
//         return;
//       }
//
//       // Backend se SaveUser milta hai
//       final saveUser = await authRepo.loginWithGoogle(idToken);
//
//       // SaveUser ko directly save karo using saveGoogleUser()
//       await _storageRepo.saveGoogleUser(saveUser);
//
//       SnackbarHelper.success("Welcome ${saveUser.name.split(' ').first}!");
//       Get.offAllNamed(AppRoutes.start);
//     } catch (e) {
//       log("Google login error: $e");
//       SnackbarHelper.error("Google login failed");
//     } finally {
//       isGoogleLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }

// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:game_app/data/repositories/auth_repository.dart';
// import 'package:game_app/data/repositories/storage_repository.dart';
// import 'package:game_app/presentation/routes/app_routes.dart';
// import 'package:get/get.dart';
//
// import '../../utils/snackbar_helper.dart';
//
// class LoginController extends GetxController {
//
//   // Email & Password Controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   // Password visibility
//   final RxBool isPasswordVisible = false.obs;
//
//   // Remember Me Checkbox State
//   final RxBool rememberMe = false.obs;
//   final isLoading = false.obs;
//
//   // Toggle Password Visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }
//
//   // Toggle Remember Me
//   void toggleRememberMe(bool? value) {
//     rememberMe.value = value ?? false;
//   }
//
//   // Form Validation
//   bool validateLoginForm() => formKey.currentState?.validate() ?? false;
//
//   Future<void> login() async {
//     if (!validateLoginForm()) return;
//
//     isLoading.value = true;
//     try {
//       final email = emailController.text.trim();
//       final password = passwordController.text.trim();
//
//       // Call the actual login API
//       final user = await Get.find<AuthRepository>().login(email, password);
//
//       // Save credentials if remember me is checked
//       if (rememberMe.value) {
//         await Get.find<StorageRepository>().saveUser(user);
//       }
//
//       SnackbarHelper.success('login_successful'.tr);
//
//       // Navigate to home screen after successful login
//       await Get.offAllNamed(AppRoutes.start);
//
//     } catch (e, s) {
//       log('Login Error: $e', stackTrace: s);
//
//       // Handle specific error messages from API
//       if (e.toString().toLowerCase().contains('invalid credentials') ||
//           e.toString().toLowerCase().contains('wrong password') ||
//           e.toString().toLowerCase().contains('user not found')) {
//         SnackbarHelper.error('email_or_password_incorrect'.tr);
//       } else if (e.toString().toLowerCase().contains('network') ||
//           e.toString().toLowerCase().contains('connection')) {
//         SnackbarHelper.error('network_error'.tr);
//       } else {
//         SnackbarHelper.error('login_failed'.tr);
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }
//
