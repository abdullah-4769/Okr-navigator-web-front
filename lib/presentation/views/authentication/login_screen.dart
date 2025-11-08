
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/login_controller.dart';
import '../../../controllers/register_controller.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../utils/validator.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  final controller = Get.find<LoginController>();


  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if it's mobile (width < 768)
          bool isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            return _buildMobileLayout(context);
          } else {
            return _buildWebDesktopLayout(context, constraints);
          }


        },
      ),
    );
  }

  // Enhanced mobile layout - fully responsive
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        // Responsive paddings & sizes
        final horizontalPadding = screenWidth * 0.06;
        final logoSize = isPortrait ? screenWidth * 0.22 : screenWidth * 0.15;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: screenHeight * 0.02, // Added  padding
            ),
            child: Form(
              key: controller.formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom -
                      mediaQuery.viewInsets.bottom, // Account for keyboard
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prevent unnecessary expansion
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    /// -------- LOGO --------
                    CustomSvg(
                      assetPath: AppAssets.okrLogo,
                      width: logoSize,
                      height: logoSize,
                      semanticsLabel: 'okr_logo'.tr,
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    /// -------- TITLE --------
                    Text(
                      'rejoin_operation'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: isPortrait ? screenWidth * 0.06 : screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    /// -------- SUBTITLE --------
                    Text(
                      'strategy_awaits'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: isPortrait ? screenWidth * 0.04 : screenWidth * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    /// -------- EMAIL FIELD --------
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

                    /// -------- PASSWORD FIELD --------
                    CustomTextField(
                      controller: controller.passwordController,
                      hint: 'enter_password'.tr,
                      obscureText: true,
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: AppColors.textSecondary,
                        size: screenWidth * 0.05,
                      ),
                      validator: Validators.password,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    /// -------- REMEMBER ME + FORGOT PASSWORD --------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                              () => Row(
                            children: [
                              Checkbox(
                                value: controller.rememberMe.value,
                                onChanged: controller.toggleRememberMe,
                                activeColor: AppColors.primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.d4,
                                  ),
                                ),
                              ),
                              Text(
                                'remember_me'.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => SnackbarHelper.info('password_reset_coming'.tr),
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

                    SizedBox(height: screenHeight * 0.01),

                    /// -------- SIGN IN BUTTON --------
                    Obx(
                          () => CustomButton(
                        text: 'sign_in'.tr,
                        onPressed: controller.login,
                        isLoading: controller.isLoading.value,
                        backgroundColor: AppColors.primaryRed,
                        height: screenHeight * 0.065,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    /// -------- SIGN UP PROMPT --------
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'want_a_navigator'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: screenWidth * 0.035,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(width: screenWidth * 0.015),
                          TextButton(
                            onPressed: () {
                              if (!Get.isRegistered<RegisterController>()) {
                                Get.put(RegisterController());
                              }
                              Get.toNamed(AppRoutes.register);
                            },
                            child: Text(
                              'sign_up'.tr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: screenWidth * 0.035,
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    /// -------- BOTTOM LOGO --------
                    CustomSvg(
                      assetPath: 'assets/images/logo.svg',
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08,
                      semanticsLabel: 'bottom_logo'.tr,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Enhanced web/desktop layout - fully responsive
  Widget _buildWebDesktopLayout(BuildContext context, BoxConstraints constraints) {
    final theme = Theme.of(context);

    // Calculate responsive dimensions
    double cardWidth = constraints.maxWidth * 0.35; // Reduced to 35% for better fit
    if (cardWidth > 500) cardWidth = 500; // Max width cap
    if (cardWidth < 300) cardWidth = 300; // Min width cap
    double cardHeight = constraints.maxHeight * 0.75; // Reduced to 75%
    if (cardHeight > 600) cardHeight = 600; // Max height cap
    if (cardHeight < 400) cardHeight = 400; // Min height cap
    double padding = constraints.maxWidth > 1200 ? 32 : 24; // Responsive padding

    return SizedBox.expand(
      child: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content centered
          Center(
            child: Container(
              width: cardWidth,
              height: cardHeight,
              margin: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.02,
              ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Top Logo
                        Flexible(
                          flex: 2,
                          child: CustomSvg(
                            assetPath: AppAssets.okrLogo,
                            width: cardHeight * 0.15, // Scaled with card height
                            height: cardHeight * 0.15,
                            semanticsLabel: 'okr_logo'.tr,
                          ),
                        ),

                        // Title Section
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'rejoin_operation'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: cardHeight * 0.05, // Scaled font
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E5BBA),
                                  fontFamily: 'Gothic',
                                ),
                              ),
                              SizedBox(height: cardHeight * 0.005),
                              Text(
                                'strategy_awaits'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: cardHeight * 0.03,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Input Fields Section
                        Flexible(
                          flex: 4,
                          child: Column(
                            children: [
                              // Email Field
                              Expanded(
                                child: _buildWebTextField(
                                  controller: controller.emailController,
                                  hint: 'enter_email'.tr,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: Validators.email,
                                ),
                              ),
                              SizedBox(height: cardHeight * 0.005),

                              // Password Field
                              Expanded(
                                child: _buildWebTextField(
                                  controller: controller.passwordController,
                                  hint: 'enter_password'.tr,
                                  obscureText: true,
                                  prefixIcon: Icons.lock_outlined,
                                  validator: Validators.password,
                                ),
                              ),
                              SizedBox(height: cardHeight * 0.005),

                              // Remember Me + Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(
                                        () => Row(
                                      children: [
                                        Checkbox(
                                          value: controller.rememberMe.value,
                                          onChanged: controller.toggleRememberMe,
                                          activeColor: const Color(0xFFDC2626),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        Text(
                                          'remember_me'.tr,
                                          style: TextStyle(
                                            fontSize: cardHeight * 0.025,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        SnackbarHelper.info('password_reset_coming'.tr),
                                    child: Text(
                                      'forget_password'.tr,
                                      style: TextStyle(
                                        fontSize: cardHeight * 0.025,
                                        color: const Color(0xFFDC2626),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Button Section
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Obx(
                                    () => _buildWebButton(
                                  text: 'sign_in'.tr,
                                  onPressed: controller.login,
                                  isLoading: controller.isLoading.value,
                                  height: cardHeight * 0.1, // Scaled button height
                                ),
                              ),
                              SizedBox(height: cardHeight * 0.001),

                              // Sign Up Prompt
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'want_a_navigator'.tr,
                                    style: TextStyle(
                                      fontSize: cardHeight * 0.025,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (!Get.isRegistered<RegisterController>()) {
                                        Get.put(RegisterController());
                                      }
                                      Get.toNamed(AppRoutes.register);
                                    },
                                    child: Text(
                                      'sign_up'.tr,
                                      style: TextStyle(
                                        fontSize: cardHeight * 0.025,
                                        color: const Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ✅ Bottom logo pinned to bottom center
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


  // Custom TextField for Web/Desktop
  Widget _buildWebTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          color: const Color(0xFF6B7280),
          size: 20,
        )
            : null,
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
          borderSide: const BorderSide(
            color: Color(0xFF2E5BBA),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1F2937),
      ),
    );
  }

  // Custom Button for Web/Desktop
  Widget _buildWebButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double height = 50,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFF9CA3AF),
        ),
        child: isLoading
            ? SizedBox(
          width: height * 0.4,
          height: height * 0.4,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: height * 0.32, // Scaled font size
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}