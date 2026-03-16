import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../utils/validator.dart';
import '../../../view_model/forget_password_and_otp.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ResetPasswordScreen extends StatelessWidget {
  final ForgotPasswordController controller;

  const ResetPasswordScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        if (isMobile) {
          return _buildMobileLayout();
        } else {
          // Standalone web use; normally embedded in ForgotPasswordScreen card
          return _buildWebStandaloneLayout(constraints);
        }
      },
    );
  }

  // ─────────────────────────── MOBILE ───────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create_new_password'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'password_requirements'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 32.h),

        Obx(() => CustomTextField(
          controller: controller.newPasswordController,
          hint: 'enter_new_password_hint'.tr,
          obscureText: !controller.isPasswordVisible.value,
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          validator: Validators.password,
        )),
        SizedBox(height: 20.h),

        Obx(() => CustomTextField(
          controller: controller.confirmPasswordController,
          hint: 'confirm_password_hint'.tr,
          obscureText: !controller.isConfirmPasswordVisible.value,
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isConfirmPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            onPressed: controller.toggleConfirmPasswordVisibility,
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'please_confirm_password'.tr;
            if (value != controller.newPasswordController.text) {
              return 'passwords_do_not_match'.tr;
            }
            return null;
          },
        )),
        SizedBox(height: 48.h),

        Obx(() => CustomButton(
          text: 'reset_password_button'.tr,
          onPressed: controller.resetPassword,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.primaryRed,
          height: 56.h,
        )),
      ],
    );
  }

  // ─────────────────────────── WEB STANDALONE ───────────────────────────

  Widget _buildWebStandaloneLayout(BoxConstraints constraints) {
    double cardWidth = constraints.maxWidth * 0.35;
    if (cardWidth > 480) cardWidth = 480;
    if (cardWidth < 320) cardWidth = 320;

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: cardWidth,
                margin: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E5BBA),
                            fontFamily: 'Gothic',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'password_requirements'.tr,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 24),
                        Obx(() => _buildWebTextField(
                          controller: controller.newPasswordController,
                          hint: 'enter_new_password_hint'.tr,
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
                        const SizedBox(height: 16),
                        Obx(() => _buildWebTextField(
                          controller: controller.confirmPasswordController,
                          hint: 'confirm_password_hint'.tr,
                          obscureText: !controller.isConfirmPasswordVisible.value,
                          prefixIcon: Icons.lock_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'please_confirm_password'.tr;
                            if (value != controller.newPasswordController.text) {
                              return 'passwords_do_not_match'.tr;
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                        )),
                        const SizedBox(height: 32),
                        Obx(() => _buildWebButton(
                          text: 'reset_password_button'.tr,
                          onPressed: controller.resetPassword,
                          isLoading: controller.isLoading.value,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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
          borderSide: const BorderSide(color: Color(0xFF2E5BBA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: const Color(0xFF9CA3AF),
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}