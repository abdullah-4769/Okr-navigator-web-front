import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/register_controller.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../core/app_strings.dart';
import '../../../utils/validator.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if it's mobile (width < 768)
          bool isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            // Return original mobile layout unchanged
            return _buildMobileLayout();
          } else {
            // Return web/desktop layout
            return _buildWebDesktopLayout(constraints);
          }
        },
      ),
    );
  }

  // Original mobile layout - unchanged
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.d24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppDimensions.d30.h),

              // Top Logo
              CustomSvg(
                assetPath: AppAssets.okrLogo,
                width: AppDimensions.d70.w,
                height: AppDimensions.d70.h,
                semanticsLabel: '',
              ),
              SizedBox(height: AppDimensions.d40.h),

              // Title
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  AppStrings.enterArena.tr,
                  style: TextStyle(
                    fontSize: AppDimensions.d24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    fontFamily: 'Gothic',
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.d10.h),

              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  AppStrings.signUpRole.tr,
                  style: TextStyle(
                    fontSize: AppDimensions.d18.sp,
                    color: AppColors.primaryBlue,
                    fontFamily: 'Gothic',
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.d40.h),

              // Input Fields
              CustomTextField(
                controller: controller.nameController,
                hint: AppStrings.enterName.tr,
                validator: (value) => Validators.isRequired(value, AppStrings.nameRequired.tr),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: AppDimensions.d14.h),

              CustomTextField(
                controller: controller.emailController,
                hint: AppStrings.enterEmail.tr,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              SizedBox(height: AppDimensions.d14.h),

              CustomTextField(
                controller: controller.phoneController,
                hint: AppStrings.enterPhone.tr,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              SizedBox(height: AppDimensions.d14.h),

              CustomTextField(
                controller: controller.passwordController,
                hint: AppStrings.enterPassword.tr,
                obscureText: true,
                validator: Validators.password,
              ),
              SizedBox(height: AppDimensions.d14.h),

              CustomTextField(
                controller: controller.confirmPasswordController,
                hint: AppStrings.confirmPassword.tr,
                obscureText: true,
                validator: (value) => Validators.confirmPassword(
                  controller.passwordController.text,
                  value,
                ),
              ),

              SizedBox(height: AppDimensions.d30.h),

              // Sign Up Button
              Obx(() => CustomButton(
                text: AppStrings.signUp.tr,
                onPressed: controller.register,
                isLoading: controller.isLoading.value,
              )),
              SizedBox(height: AppDimensions.d20.h),

              // Sign In Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyHaveAccount.tr,
                    style: TextStyle(
                      fontSize: AppDimensions.d14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: AppDimensions.d4.w),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    child: Text(
                      AppStrings.signIn.tr,
                      style: TextStyle(
                        fontSize: AppDimensions.d14.sp,
                        color: AppColors.accentRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.d40.h),

              // Bottom Logo
              Center(
                child: CustomSvg(
                  assetPath: 'assets/images/logo.svg',
                  width: AppDimensions.d30.w,
                  height: AppDimensions.d30.h,
                  semanticsLabel: '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Web/Desktop layout with centered card design
  Widget _buildWebDesktopLayout(BoxConstraints constraints) {
    return Stack(
      children: [
        // Background with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        ),
        // Background image with opacity
        Positioned.fill(
          child: Opacity(
            opacity: 0.08, // Adjust opacity (0.05 to 0.15 recommended)
            child: Image.asset(
              'assets/images/web_background.png', // Add your background image path here
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Main content
        Center(
          child: SingleChildScrollView(
            child: Container(
              width: constraints.maxWidth > 1200 ? 500 : 450,
              margin: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(40),
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
                          width: 80,
                          height: 80,
                          semanticsLabel: '',
                        ),
                        const SizedBox(height: 30),

                        // Title
                        Text(
                          AppStrings.enterArena.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E5BBA), // AppColors.primaryBlue equivalent
                            fontFamily: 'Gothic',
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          AppStrings.signUpRole.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280), // Secondary text color
                            fontFamily: 'Gothic',
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Input Fields
                        _buildWebTextField(
                          controller: controller.nameController,
                          hint: AppStrings.enterName.tr,
                          validator: (value) => Validators.isRequired(value, AppStrings.nameRequired.tr),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),

                        _buildWebTextField(
                          controller: controller.emailController,
                          hint: AppStrings.enterEmail.tr,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        _buildWebTextField(
                          controller: controller.phoneController,
                          hint: AppStrings.enterPhone.tr,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),

                        _buildWebTextField(
                          controller: controller.passwordController,
                          hint: AppStrings.enterPassword.tr,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),

                        _buildWebTextField(
                          controller: controller.confirmPasswordController,
                          hint: AppStrings.confirmPassword.tr,
                          obscureText: true,
                          validator: (value) => Validators.confirmPassword(
                            controller.passwordController.text,
                            value,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Sign Up Button
                        Obx(() => _buildWebButton(
                          text: AppStrings.signUp.tr,
                          onPressed: controller.register,
                          isLoading: controller.isLoading.value,
                        )),
                        const SizedBox(height: 20),

                        // Sign In Prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already a Navigator? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.offAllNamed(AppRoutes.login),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFDC2626), // Red color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Bottom Logo
                        CustomSvg(
                          assetPath: 'assets/images/logo.svg',
                          width: 40,
                          height: 40,
                          semanticsLabel: '',
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
    );

  }

  // Custom TextField for Web/Desktop
  Widget _buildWebTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
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
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
        ),
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
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626), // Red color
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}