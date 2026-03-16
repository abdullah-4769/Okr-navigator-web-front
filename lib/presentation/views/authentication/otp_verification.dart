import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../view_model/forget_password_and_otp.dart';
import '../../widgets/custom_button.dart';

class OtpVerificationScreen extends StatelessWidget {
  final ForgotPasswordController controller;

  const OtpVerificationScreen({
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
          // When embedded inside ForgotPasswordScreen's web card,
          // this widget is used directly as the step content.
          // The web rendering is handled by ForgotPasswordScreen itself.
          // This fallback handles standalone use.
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
          'verify_otp_title'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          '${'otp_sent_to'.tr} ${controller.emailController.text}',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 32.h),
        _buildOtpInputField(),
        SizedBox(height: 24.h),
        _buildTimerSection(),
        SizedBox(height: 48.h),
        Obx(() => CustomButton(
          text: 'verify_otp'.tr,
          onPressed: (controller.isOtpExpired.value || controller.isLoading.value)
              ? () {}
              : () => controller.verifyOtp(),
          isLoading: controller.isLoading.value,
          backgroundColor: (controller.isOtpExpired.value || controller.isLoading.value)
              ? AppColors.border
              : AppColors.primaryRed,
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
                    children: [
                      const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5BBA),
                          fontFamily: 'Gothic',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${'otp_sent_to'.tr} ${controller.emailController.text}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildWebOtpBoxes(cardWidth),
                      const SizedBox(height: 16),
                      _buildWebTimerSection(),
                      const SizedBox(height: 24),
                      Obx(() => _buildWebButton(
                        text: 'verify_otp'.tr,
                        onPressed: (controller.isOtpExpired.value || controller.isLoading.value)
                            ? null
                            : controller.verifyOtp,
                        isLoading: controller.isLoading.value,
                        disabled: controller.isOtpExpired.value,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebOtpBoxes(double cardWidth) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: (cardWidth - 72 - 40) / 6,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.otpControllers[index].text.isEmpty
                  ? const Color(0xFFE5E7EB)
                  : (controller.isOtpExpired.value
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFF2E5BBA)),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
            color: controller.isOtpExpired.value
                ? const Color(0xFFF3F4F6)
                : Colors.white,
          ),
          child: TextField(
            controller: controller.otpControllers[index],
            focusNode: controller.otpFocusNodes[index],
            enabled: !controller.isOtpExpired.value && !controller.isLoading.value,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
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
            onChanged: (value) => controller.onOtpFieldChanged(value, index),
          ),
        );
      }),
    ));
  }

  Widget _buildWebTimerSection() {
    return Obx(() => Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: controller.isOtpExpired.value
                ? const Color(0xFFF3F4F6)
                : const Color(0xFFDC2626).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                color: controller.isOtpExpired.value
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFFDC2626),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                controller.isOtpExpired.value
                    ? 'otp_expired'.tr
                    : '${'time_remaining'.tr} ${controller.getFormattedTime()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: controller.isOtpExpired.value
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: controller.isOtpExpired.value ? controller.resendOtp : null,
          child: Text(
            controller.isOtpExpired.value
                ? 'resend_otp'.tr
                : 'did_not_receive_code'.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: controller.isOtpExpired.value
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    ));
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
            : Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─────────────────────────── MOBILE HELPERS ───────────────────────────

  Widget _buildOtpInputField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) => _buildOtpBox(index)),
    );
  }

  Widget _buildOtpBox(int index) {
    return Obx(() => Container(
      width: 50.w,
      height: 60.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: controller.otpControllers[index].text.isEmpty
              ? AppColors.border
              : (controller.isOtpExpired.value
              ? AppColors.border
              : AppColors.primaryBlue),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: controller.isOtpExpired.value
            ? AppColors.border.withOpacity(0.2)
            : Colors.white,
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.otpFocusNodes[index],
        enabled: !controller.isOtpExpired.value && !controller.isLoading.value,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        onChanged: (value) => controller.onOtpFieldChanged(value, index),
      ),
    ));
  }

  Widget _buildTimerSection() {
    return Obx(() => Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: controller.isOtpExpired.value
                ? AppColors.border.withOpacity(0.2)
                : AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                color: controller.isOtpExpired.value
                    ? AppColors.border
                    : AppColors.primaryRed,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                controller.isOtpExpired.value
                    ? 'otp_expired'.tr
                    : '${'time_remaining'.tr} ${controller.getFormattedTime()}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: controller.isOtpExpired.value
                      ? AppColors.border
                      : AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: TextButton(
            onPressed: controller.isOtpExpired.value ? controller.resendOtp : null,
            child: Text(
              controller.isOtpExpired.value
                  ? 'resend_otp'.tr
                  : 'did_not_receive_code'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: controller.isOtpExpired.value
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    ));
  }
}