import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/login_controller.dart';
import '../../../controllers/register_controller.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../utils/validator.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/custom_textfield.dart';
import 'forget_password.dart';

class LoginScreen extends StatelessWidget {
  final controller = Get.find<LoginController>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          if (isMobile) {
            return _buildMobileLayout(context);
          } else {
            return _buildWebDesktopLayout(context, constraints);
          }
        },
      ),
    );
  }

  // ─────────────────────────── MOBILE ───────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        final mediaQuery = MediaQuery.of(context);
        final screenHeight = mediaQuery.size.height;
        final screenWidth = mediaQuery.size.width;
        final horizontalPadding = screenWidth * 0.06;
        final logoSize = isPortrait ? screenWidth * 0.22 : screenWidth * 0.15;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Form(
              key: controller.formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    /// LOGO
                    CustomSvg(
                      assetPath: AppAssets.okrLogo,
                      width: logoSize,
                      height: logoSize,
                      semanticsLabel: 'okr_logo'.tr,
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    /// TITLE
                    Text(
                      'rejoin_operation'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: isPortrait
                            ? screenWidth * 0.06
                            : screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    /// SUBTITLE
                    Text(
                      'strategy_awaits'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: isPortrait
                            ? screenWidth * 0.04
                            : screenWidth * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    /// EMAIL FIELD
                    CustomTextField(
                      controller: controller.emailController,
                      hint: 'enter_email'.tr,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                        size: screenWidth * 0.05,
                      ),
                      validator: Validators.email,
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    /// PASSWORD FIELD
                    Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      hint: 'enter_password'.tr,
                      obscureText: !controller.isPasswordVisible.value,
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: AppColors.textSecondary,
                        size: screenWidth * 0.05,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: screenWidth * 0.05,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      validator: Validators.password,
                    )),
                    SizedBox(height: screenHeight * 0.02),

                    /// REMEMBER ME + FORGOT PASSWORD
                    Row(
                      children: [
                        Obx(() => Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: controller.toggleRememberMe,
                          activeColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(AppDimensions.d4),
                          ),
                        )),
                        Text(
                          'remember_me'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: screenWidth * 0.035,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Get.to(
                                  () => ForgotPasswordScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300),
                            );
                          },
                          child: Text(
                            'forget_password'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: screenWidth * 0.035,
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    /// SIGN IN BUTTON
                    Obx(() => CustomButton(
                      text: 'sign_in'.tr,
                      onPressed: controller.login,
                      isLoading: controller.isLoading.value,
                      backgroundColor: AppColors.primaryRed,
                      height: screenHeight * 0.065,
                    )),

                    SizedBox(height: screenHeight * 0.03),

                    /// GOOGLE SIGN IN
                    Obx(() => InkWell(
                      onTap: controller.isGoogleLoading.value
                          ? null
                          : () => controller.loginWithGoogle(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 45.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: controller.isGoogleLoading.value
                                ? AppColors.border.withOpacity(0.5)
                                : AppColors.border,
                          ),
                          color: controller.isGoogleLoading.value
                              ? Colors.grey.shade100
                              : Colors.white,
                        ),
                        child: controller.isGoogleLoading.value
                            ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryRed),
                            ),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google.png",
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.g_mobiledata,
                                  size: 24),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "continue_with_google".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    SizedBox(height: screenHeight * 0.04),

                    /// SIGN UP PROMPT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'want_a_navigator'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: screenWidth * 0.035,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            'sign_up'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: screenWidth * 0.035,
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    /// BOTTOM LOGO
                    CustomSvg(
                      assetPath: 'assets/images/logo.svg',
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08,
                      semanticsLabel: 'bottom_logo'.tr,
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────── WEB / DESKTOP ───────────────────────────

  Widget _buildWebDesktopLayout(BuildContext context, BoxConstraints constraints) {
    double cardWidth = constraints.maxWidth * 0.35;
    if (cardWidth > 500) cardWidth = 500;
    if (cardWidth < 320) cardWidth = 320;
    final double padding = constraints.maxWidth > 1200 ? 40 : 32;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[200]!, Colors.grey[300]!],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Centered card
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: cardWidth,
                margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Logo
                          CustomSvg(
                            assetPath: AppAssets.okrLogo,
                            width: 72,
                            height: 72,
                            semanticsLabel: 'okr_logo'.tr,
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            'rejoin_operation'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E5BBA),
                              fontFamily: 'Gothic',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'strategy_awaits'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email field
                          _buildWebTextField(
                            controller: controller.emailController,
                            hint: 'enter_email'.tr,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),

                          // Password field
                          Obx(() => _buildWebTextField(
                            controller: controller.passwordController,
                            hint: 'enter_password'.tr,
                            obscureText: !controller.isPasswordVisible.value,
                            prefixIcon: Icons.lock_outlined,
                            validator: Validators.password,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF6B7280),
                                size: 20,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          )),
                          const SizedBox(height: 10),

                          // Remember Me + Forgot Password
                          Row(
                            children: [
                              Obx(() => SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged: controller.toggleRememberMe,
                                  activeColor: const Color(0xFFDC2626),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                              )),
                              const SizedBox(width: 8),
                              Text(
                                'remember_me'.tr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Get.to(
                                        () => ForgotPasswordScreen(),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'forget_password'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Sign In Button
                          Obx(() => _buildWebButton(
                            text: 'sign_in'.tr,
                            onPressed: controller.login,
                            isLoading: controller.isLoading.value,
                          )),
                          const SizedBox(height: 14),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Google Sign In Button
                          Obx(() => InkWell(
                            onTap: controller.isGoogleLoading.value
                                ? null
                                : () => controller.loginWithGoogle(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: controller.isGoogleLoading.value
                                      ? const Color(0xFFE5E7EB).withOpacity(0.5)
                                      : const Color(0xFFE5E7EB),
                                ),
                                color: controller.isGoogleLoading.value
                                    ? Colors.grey.shade50
                                    : Colors.white,
                              ),
                              child: controller.isGoogleLoading.value
                                  ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Color(0xFFDC2626)),
                                  ),
                                ),
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/google.png",
                                    height: 20,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.g_mobiledata,
                                        size: 22,
                                        color: Color(0xFF6B7280)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "continue_with_google".tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                          const SizedBox(height: 20),

                          // Sign Up Prompt
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'want_a_navigator'.tr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(AppRoutes.register),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(left: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'sign_up'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom logo pinned
          Positioned(
            bottom: constraints.maxHeight * 0.04,
            left: 0,
            right: 0,
            child: Center(
              child: CustomSvg(
                assetPath: 'assets/images/logo.svg',
                width: cardWidth * 0.1,
                height: cardWidth * 0.1,
                semanticsLabel: 'bottom_logo'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── WEB HELPERS ───────────────────────────

  Widget _buildWebTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF6B7280), size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF2E5BBA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
    );
  }

  Widget _buildWebButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: const Color(0xFF9CA3AF),
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
            AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}