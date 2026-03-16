import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/login_controller.dart';
import '../../../controllers/register_controller.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../utils/validator.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterController controller;
  final googlelogin = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RegisterController>()) {
      controller = Get.put(RegisterController());
    } else {
      controller = Get.find<RegisterController>();
    }
  }

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
    return OrientationBuilder(
      builder: (context, orientation) {
        final mediaQuery = MediaQuery.of(context);
        final screenHeight = mediaQuery.size.height;
        final screenWidth = mediaQuery.size.width;
        final isPortrait = orientation == Orientation.portrait;
        final isTablet = screenWidth > 600;
        final isDesktop = screenWidth > 900;
        final maxContentWidth = _getMaxContentWidth(screenWidth);
        final horizontalPadding = _getHorizontalPadding(screenWidth);
        final theme = Theme.of(context);

        return SafeArea(
          child: Center(
            child: Container(
              width: maxContentWidth,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.04)),
                      _buildTopLogo(screenWidth, isPortrait, isTablet),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                      _buildTitleSection(theme, screenWidth, isPortrait, isTablet),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.015)),
                      _buildSubtitleSection(screenWidth, isTablet, isDesktop),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.04)),
                      _buildMobileInputFields(screenHeight, screenWidth, isTablet),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.04)),
                      _buildSignUpButton(isTablet),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.04)),
                      _buildGoogleButton(),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                      _buildSignInPrompt(theme, screenWidth, isPortrait, isTablet),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                      _buildBottomLogo(screenWidth, isTablet),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
                    ],
                  ),
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
    double cardWidth = constraints.maxWidth * 0.38;
    if (cardWidth > 520) cardWidth = 520;
    if (cardWidth < 340) cardWidth = 340;
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
                            'enter_arena'.tr,
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
                            'sign_up_navigator'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: 'GothamMedium',
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Name field
                          _buildWebTextField(
                            controller: controller.nameController,
                            hint: 'enter_name'.tr,
                            prefixIcon: Icons.person_outline,
                            validator: (value) => Validators.isRequired(
                                value, 'name_required'.tr),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 14),

                          // Email field
                          _buildWebTextField(
                            controller: controller.emailController,
                            hint: 'enter_email'.tr,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),

                          // Phone field
                          _buildWebTextField(
                            controller: controller.phoneController,
                            hint: 'enter_phone'.tr,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: Validators.phone,
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
                          const SizedBox(height: 14),

                          // Confirm Password field
                          Obx(() => _buildWebTextField(
                            controller: controller.confirmPasswordController,
                            hint: 'confirm_password'.tr,
                            obscureText:
                            !controller.isConfirmPasswordVisible.value,
                            prefixIcon: Icons.lock_outlined,
                            validator: (value) => Validators.confirmPassword(
                                controller.passwordController.text, value),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF6B7280),
                                size: 20,
                              ),
                              onPressed:
                              controller.toggleConfirmPasswordVisibility,
                            ),
                          )),
                          const SizedBox(height: 24),

                          // Sign Up Button
                          Obx(() => _buildWebButton(
                            text: 'sign_up'.tr,
                            onPressed: controller.register,
                            isLoading: controller.isLoading.value,
                          )),
                          const SizedBox(height: 14),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: Color(0xFFE5E7EB))),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: Color(0xFFE5E7EB))),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Google Sign In Button
                          Obx(() => InkWell(
                            onTap: googlelogin.isGoogleLoading.value
                                ? null
                                : () => googlelogin.loginWithGoogle(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: googlelogin.isGoogleLoading.value
                                      ? const Color(0xFFE5E7EB)
                                      .withOpacity(0.5)
                                      : const Color(0xFFE5E7EB),
                                ),
                                color: googlelogin.isGoogleLoading.value
                                    ? Colors.grey.shade50
                                    : Colors.white,
                              ),
                              child: googlelogin.isGoogleLoading.value
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
                                mainAxisAlignment:
                                MainAxisAlignment.center,
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

                          // Sign In Prompt
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'already_have_account'.tr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.login),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(left: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'sign_in'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Bottom Logo
                          CustomSvg(
                            assetPath: 'assets/images/logo.svg',
                            width: 36,
                            height: 36,
                            semanticsLabel: 'bottom_logo'.tr,
                          ),
                        ],
                      ),
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

  // ─────────────────────────── MOBILE BUILDERS ───────────────────────────

  Widget _buildTopLogo(double screenWidth, bool isPortrait, bool isTablet) {
    final logoSize = _getLogoSize(screenWidth, isPortrait, isTablet, isTop: true);
    return CustomSvg(
      assetPath: AppAssets.okrLogo,
      width: logoSize,
      height: logoSize,
      semanticsLabel: 'okr_logo'.tr,
    );
  }

  Widget _buildTitleSection(ThemeData theme, double screenWidth,
      bool isPortrait, bool isTablet) {
    final titleSize = _getTitleSize(screenWidth, isPortrait, isTablet);
    return Text(
      'enter_arena'.tr,
      style: theme.textTheme.headlineLarge?.copyWith(
        fontSize: titleSize,
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitleSection(
      double screenWidth, bool isTablet, bool isDesktop) {
    final subtitleSize = _getSubtitleSize(screenWidth, isTablet, isDesktop);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? screenWidth * 0.1 : screenWidth * 0.05,
      ),
      child: Text(
        'sign_up_navigator'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "GothamMedium",
          fontSize: subtitleSize,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMobileInputFields(
      double screenHeight, double screenWidth, bool isTablet) {
    final fieldSpacing = _getFieldSpacing(screenHeight, isTablet);
    final iconSize = screenWidth * 0.05;

    return Column(
      children: [
        CustomTextField(
          controller: controller.nameController,
          hint: 'enter_name'.tr,
          validator: (value) =>
              Validators.isRequired(value, 'name_required'.tr),
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(Icons.person_outline,
              color: AppColors.textSecondary, size: iconSize),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          controller: controller.emailController,
          hint: 'enter_email'.tr,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          prefixIcon: Icon(Icons.email_outlined,
              color: AppColors.textSecondary, size: iconSize),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          controller: controller.phoneController,
          hint: 'enter_phone'.tr,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          prefixIcon: Icon(Icons.phone_outlined,
              color: AppColors.textSecondary, size: iconSize),
        ),
        SizedBox(height: fieldSpacing),
        Obx(() => CustomTextField(
          controller: controller.passwordController,
          hint: 'enter_password'.tr,
          obscureText: !controller.isPasswordVisible.value,
          validator: Validators.password,
          prefixIcon: Icon(Icons.lock_outlined,
              color: AppColors.textSecondary, size: iconSize),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: iconSize,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        )),
        SizedBox(height: fieldSpacing),
        Obx(() => CustomTextField(
          controller: controller.confirmPasswordController,
          hint: 'confirm_password'.tr,
          obscureText: !controller.isConfirmPasswordVisible.value,
          validator: (value) => Validators.confirmPassword(
              controller.passwordController.text, value),
          prefixIcon: Icon(Icons.lock_outlined,
              color: AppColors.textSecondary, size: iconSize),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isConfirmPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: iconSize,
            ),
            onPressed: controller.toggleConfirmPasswordVisibility,
          ),
        )),
      ],
    );
  }

  Widget _buildSignUpButton(bool isTablet) {
    return Obx(() => SizedBox(
      width: isTablet ? 350.0 : double.infinity,
      child: CustomButton(
        text: 'sign_up'.tr,
        onPressed: controller.register,
        isLoading: controller.isLoading.value,
      ),
    ));
  }

  Widget _buildGoogleButton() {
    return Obx(() => InkWell(
      onTap: googlelogin.isGoogleLoading.value
          ? null
          : () => googlelogin.loginWithGoogle(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 45.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: googlelogin.isGoogleLoading.value
                ? AppColors.border.withOpacity(0.5)
                : AppColors.border,
          ),
          color: googlelogin.isGoogleLoading.value
              ? Colors.grey.shade100
              : Colors.white,
        ),
        child: googlelogin.isGoogleLoading.value
            ? const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
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
              const Icon(Icons.g_mobiledata, size: 24),
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
    ));
  }

  Widget _buildSignInPrompt(ThemeData theme, double screenWidth,
      bool isPortrait, bool isTablet) {
    final promptTextSize =
    _getPromptTextSize(screenWidth, isPortrait, isTablet);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: promptTextSize,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.login),
          child: Text(
            'sign_in'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: promptTextSize,
              color: AppColors.accentRed,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accentRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLogo(double screenWidth, bool isTablet) {
    final logoSize = _getLogoSize(screenWidth, true, isTablet, isTop: false);
    return CustomSvg(
      assetPath: 'assets/images/logo.svg',
      width: logoSize,
      height: logoSize,
      semanticsLabel: 'bottom_logo'.tr,
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
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
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

  // ─────────────────────────── RESPONSIVE HELPERS ───────────────────────────

  double _getMaxContentWidth(double screenWidth) {
    if (screenWidth > 1200) return 500.0;
    if (screenWidth > 900) return 450.0;
    if (screenWidth > 600) return 400.0;
    return double.infinity;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 900) return 40.0;
    if (screenWidth > 600) return 32.0;
    return screenWidth * 0.06;
  }

  double _getResponsiveSpacing(double screenHeight, double factor) =>
      screenHeight * factor;

  double _getLogoSize(double screenWidth, bool isPortrait, bool isTablet,
      {required bool isTop}) {
    if (isTablet) {
      if (isTop) return isPortrait ? screenWidth * 0.12 : screenWidth * 0.08;
      return screenWidth * 0.06;
    } else {
      if (isTop) return isPortrait ? screenWidth * 0.15 : screenWidth * 0.1;
      return screenWidth * 0.09;
    }
  }

  double _getTitleSize(double screenWidth, bool isPortrait, bool isTablet) {
    if (screenWidth > 900) return 32.0;
    if (isTablet) return isPortrait ? 28.0 : 24.0;
    return isPortrait ? screenWidth * 0.06 : screenWidth * 0.045;
  }

  double _getSubtitleSize(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return 18.0;
    if (isTablet) return 17.0;
    if (screenWidth > 400) return 16.0;
    return 15.0;
  }

  double _getFieldSpacing(double screenHeight, bool isTablet) {
    final baseSpacing = screenHeight * 0.02;
    return isTablet ? baseSpacing * 1.2 : baseSpacing;
  }

  double _getPromptTextSize(
      double screenWidth, bool isPortrait, bool isTablet) {
    if (isTablet) return 16.0;
    return isPortrait ? screenWidth * 0.035 : screenWidth * 0.03;
  }
}