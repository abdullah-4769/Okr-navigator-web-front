import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../utils/validator.dart';
import '../../../view_model/forget_password_and_otp.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'otp_verification.dart';
import 'reset_password.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final controller = Get.put(ForgotPasswordController());

  ForgotPasswordScreen({super.key});

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
    return Obx(() {
      return PopScope(
        canPop: controller.currentStep.value == 0,
        onPopInvoked: (didPop) {
          if (!didPop) controller.goBackStep();
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
              onPressed: controller.goBackStep,
            ),
            title: Text(
              _getAppBarTitle(controller.currentStep.value).tr,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: _buildCurrentStep(controller),
            ),
          ),
        ),
      );
    });
  }

  // ─────────────────────────── WEB / DESKTOP ───────────────────────────

  Widget _buildWebDesktopLayout(BuildContext context, BoxConstraints constraints) {
    double cardWidth = constraints.maxWidth * 0.35;
    if (cardWidth > 500) cardWidth = 500;
    if (cardWidth < 320) cardWidth = 320;
    final double padding = constraints.maxWidth > 1200 ? 40 : 32;

    return Obx(() {
      return PopScope(
        canPop: controller.currentStep.value == 0,
        onPopInvoked: (didPop) {
          if (!didPop) controller.goBackStep();
        },
        child: SizedBox.expand(
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
                      color: Colors.grey[200],
                    ),
                  ),
                ),
              ),

              // Back button top-left
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue, size: 24),
                  onPressed: controller.goBackStep,
                ),
              ),

              // Centered card
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
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Step indicator
                            _buildWebStepIndicator(),
                            const SizedBox(height: 32),

                            // Step title
                            Text(
                              _getAppBarTitle(controller.currentStep.value).tr,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E5BBA),
                                fontFamily: 'Gothic',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Step content
                            _buildWebCurrentStep(controller, cardWidth, padding),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWebStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Row(
          children: [
            Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: controller.currentStep.value == index ? 32 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: controller.currentStep.value >= index
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
            )),
            if (index < 2)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: const Color(0xFFE5E7EB),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildWebCurrentStep(ForgotPasswordController ctrl, double cardWidth, double padding) {
    switch (ctrl.currentStep.value) {
      case 0:
        return _buildWebEmailStep(ctrl);
      case 1:
        return _buildWebOtpStep(ctrl, cardWidth);
      case 2:
        return _buildWebResetStep(ctrl);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWebEmailStep(ForgotPasswordController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_email_address'.tr,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'we_will_send_otp'.tr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        _buildWebTextField(
          controller: ctrl.emailController,
          hint: 'enter_email_hint'.tr,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: Validators.email,
        ),
        const SizedBox(height: 32),
        Obx(() => _buildWebButton(
          text: 'send_otp'.tr,
          onPressed: ctrl.sendOtp,
          isLoading: ctrl.isLoading.value,
        )),
      ],
    );
  }

  Widget _buildWebOtpStep(ForgotPasswordController ctrl, double cardWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'verify_otp_title'.tr,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${'otp_sent_to'.tr} ${ctrl.emailController.text}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        // OTP boxes
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return Container(
              width: (cardWidth - 80 - 48) / 6,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: ctrl.otpControllers[index].text.isEmpty
                      ? const Color(0xFFE5E7EB)
                      : (ctrl.isOtpExpired.value
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF2E5BBA)),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
                color: ctrl.isOtpExpired.value
                    ? const Color(0xFFF3F4F6)
                    : Colors.white,
              ),
              child: TextField(
                controller: ctrl.otpControllers[index],
                focusNode: ctrl.otpFocusNodes[index],
                enabled: !ctrl.isOtpExpired.value && !ctrl.isLoading.value,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                onChanged: (value) => ctrl.onOtpFieldChanged(value, index),
              ),
            );
          }),
        )),
        const SizedBox(height: 16),

        // Timer
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: ctrl.isOtpExpired.value
                ? const Color(0xFFF3F4F6)
                : const Color(0xFFDC2626).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                color: ctrl.isOtpExpired.value
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFFDC2626),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                ctrl.isOtpExpired.value
                    ? 'otp_expired'.tr
                    : '${'time_remaining'.tr} ${ctrl.getFormattedTime()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ctrl.isOtpExpired.value
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),

        Obx(() => Center(
          child: TextButton(
            onPressed: ctrl.isOtpExpired.value ? ctrl.resendOtp : null,
            child: Text(
              ctrl.isOtpExpired.value
                  ? 'resend_otp'.tr
                  : 'did_not_receive_code'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ctrl.isOtpExpired.value
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        )),
        const SizedBox(height: 24),

        Obx(() => _buildWebButton(
          text: 'verify_otp'.tr,
          onPressed: (ctrl.isOtpExpired.value || ctrl.isLoading.value)
              ? null
              : ctrl.verifyOtp,
          isLoading: ctrl.isLoading.value,
          disabled: ctrl.isOtpExpired.value,
        )),
      ],
    );
  }

  Widget _buildWebResetStep(ForgotPasswordController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create_new_password'.tr,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'password_requirements'.tr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        Obx(() => _buildWebTextField(
          controller: ctrl.newPasswordController,
          hint: 'enter_new_password_hint'.tr,
          obscureText: !ctrl.isPasswordVisible.value,
          prefixIcon: Icons.lock_outlined,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(
              ctrl.isPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
            onPressed: ctrl.togglePasswordVisibility,
          ),
        )),
        const SizedBox(height: 16),
        Obx(() => _buildWebTextField(
          controller: ctrl.confirmPasswordController,
          hint: 'confirm_password_hint'.tr,
          obscureText: !ctrl.isConfirmPasswordVisible.value,
          prefixIcon: Icons.lock_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'please_confirm_password'.tr;
            if (value != ctrl.newPasswordController.text) return 'passwords_do_not_match'.tr;
            return null;
          },
          suffixIcon: IconButton(
            icon: Icon(
              ctrl.isConfirmPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
            onPressed: ctrl.toggleConfirmPasswordVisibility,
          ),
        )),
        const SizedBox(height: 32),
        Obx(() => _buildWebButton(
          text: 'reset_password_button'.tr,
          onPressed: ctrl.resetPassword,
          isLoading: ctrl.isLoading.value,
        )),
      ],
    );
  }

  // ─────────────────────────── SHARED HELPERS ───────────────────────────

  String _getAppBarTitle(int step) {
    switch (step) {
      case 0: return 'forgot_password';
      case 1: return 'verify_otp';
      case 2: return 'reset_password';
      default: return '';
    }
  }

  Widget _buildCurrentStep(ForgotPasswordController ctrl) {
    switch (ctrl.currentStep.value) {
      case 0: return _buildEmailStep(ctrl);
      case 1: return OtpVerificationScreen(controller: ctrl);
      case 2: return ResetPasswordScreen(controller: ctrl);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep(ForgotPasswordController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_email_address'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'we_will_send_otp'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 32.h),
        CustomTextField(
          controller: ctrl.emailController,
          hint: 'enter_email_hint'.tr,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          validator: Validators.email,
        ),
        SizedBox(height: 48.h),
        Obx(() => CustomButton(
          text: 'send_otp'.tr,
          onPressed: ctrl.sendOtp,
          isLoading: ctrl.isLoading.value,
          backgroundColor: AppColors.primaryRed,
          height: 56.h,
        )),
      ],
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
    bool disabled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (isLoading || disabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? const Color(0xFF9CA3AF) : const Color(0xFFDC2626),
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
            : Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}