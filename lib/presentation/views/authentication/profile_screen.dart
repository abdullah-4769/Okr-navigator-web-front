import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../view_model/profile_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/custom_textfield.dart';

class ProfileScreen extends StatelessWidget {
  final controller = Get.find<ProfileController>();

  ProfileScreen({super.key});

  final List<String> profileImages = [
    "assets/profile_images/1.jpeg",
    "assets/profile_images/2.jpeg",
    "assets/profile_images/3.jpeg",
    "assets/profile_images/4.jpeg",
    "assets/profile_images/5.jpeg",
    "assets/profile_images/6.jpeg",
    "assets/profile_images/7.jpeg",
    "assets/profile_images/8.jpeg",
    "assets/profile_images/9.jpeg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          if (isMobile) {
            return _buildMobileLayout(context, constraints);
          } else {
            return _buildWebDesktopLayout(context, constraints);
          }
        },
      ),
    );
  }

  // ─────────────────────────── MOBILE ───────────────────────────

  Widget _buildMobileLayout(BuildContext context, BoxConstraints outerConstraints) {
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
          child: Obx(
                () => controller.isLoading.value && controller.user.value == null
                ? _buildLoadingState()
                : controller.errorMessage.value.isNotEmpty
                ? _buildErrorState(context, theme)
                : Center(
              child: Container(
                width: maxContentWidth,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
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
                                _buildInputFieldsSection(screenHeight, screenWidth, isTablet, context),
                                SizedBox(height: _getResponsiveSpacing(screenHeight, 0.04)),
                                Obx(() => controller.isEditMode.value
                                    ? _buildUpdateCancelButtons(isTablet)
                                    : _buildEditLogoutButtons(isTablet)),
                                SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                                _buildBottomLogo(screenWidth, isTablet),
                                SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
              ),
            ),
          ),

          // Centered card
          Center(
            child: Obx(
                  () => controller.isLoading.value && controller.user.value == null
                  ? _buildWebLoadingState()
                  : controller.errorMessage.value.isNotEmpty
                  ? _buildWebErrorState()
                  : SingleChildScrollView(
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
                            // Top logo
                            CustomSvg(
                              assetPath: AppAssets.okrLogo,
                              width: 70,
                              height: 70,
                              semanticsLabel: 'okr_logo'.tr,
                            ),
                            const SizedBox(height: 20),

                            // Title
                            Text(
                              'my_profile'.tr,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E5BBA),
                                fontFamily: 'Gothic',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'view_manage_profile'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // Avatar
                            _buildWebAvatar(context, cardWidth),
                            const SizedBox(height: 24),

                            // Fields
                            _buildWebFields(),
                            const SizedBox(height: 28),

                            // Buttons
                            Obx(() => controller.isEditMode.value
                                ? _buildWebUpdateCancelButtons()
                                : _buildWebEditLogoutButtons()),

                            const SizedBox(height: 24),

                            // Bottom logo
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
          ),
        ],
      ),
    );
  }

  Widget _buildWebLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF2E5BBA)),
        const SizedBox(height: 16),
        const Text(
          'Loading profile...',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildWebErrorState() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Color(0xFFDC2626)),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.refreshProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5BBA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebAvatar(BuildContext context, double cardWidth) {
    return Obx(() => GestureDetector(
      onTap: controller.isEditMode.value
          ? () => _showWebImagePickerDialog(context)
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E5BBA).withOpacity(0.1),
              border: Border.all(
                color: controller.isEditMode.value
                    ? const Color(0xFF2E5BBA)
                    : Colors.transparent,
                width: 3,
              ),
              image: controller.selectedProfileImage.value.isNotEmpty
                  ? DecorationImage(
                image: AssetImage(controller.selectedProfileImage.value),
                fit: BoxFit.cover,
              )
                  : controller.user.value?.avatarPicId?.isNotEmpty == true
                  ? DecorationImage(
                image: _getImageProvider(controller.user.value!.avatarPicId),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: (controller.user.value?.avatarPicId?.isEmpty == true &&
                controller.selectedProfileImage.value.isEmpty)
                ? const Icon(Icons.person, size: 46, color: Color(0xFF2E5BBA))
                : null,
          ),
          if (controller.isEditMode.value)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2E5BBA),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildWebFields() {
    return Obx(() => Column(
      children: [
        _buildWebTextField(
          controller: controller.nameController,
          hint: 'enter_name'.tr,
          enabled: controller.isEditMode.value,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _buildWebTextField(
          controller: controller.emailController,
          hint: 'enter_email'.tr,
          enabled: false,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildWebTextField(
          controller: controller.phoneController,
          hint: 'enter_phone'.tr,
          enabled: controller.isEditMode.value,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    ));
  }

  Widget _buildWebUpdateCancelButtons() {
    return Column(
      children: [
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: const Color(0xFF9CA3AF),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'update_profile'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        )),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: controller.toggleEditMode,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E5BBA), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(
                color: Color(0xFF2E5BBA),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebEditLogoutButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.toggleEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BBA),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'edit_profile'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: const Color(0xFF9CA3AF),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'logout'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWebTextField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF6B7280), size: 20)
            : null,
        filled: true,
        fillColor: enabled ? const Color(0xFFF3F4F6) : const Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E5BBA), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(
        fontSize: 14,
        color: enabled ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
      ),
    );
  }

  void _showWebImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'select_profile_image'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E5BBA),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: profileImages.length,
                itemBuilder: (context, index) {
                  final imageAsset = profileImages[index];
                  final isSelected =
                      controller.selectedProfileImage.value == imageAsset;

                  return GestureDetector(
                    onTap: () {
                      controller.selectProfileImage(imageAsset);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E5BBA)
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 2,
                        ),
                        image: DecorationImage(
                          image: AssetImage(imageAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: isSelected
                          ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2E5BBA).withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E5BBA),
                            size: 28,
                          ),
                        ),
                      )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'cancel'.tr,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── MOBILE HELPERS ───────────────────────────

  _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  _buildErrorState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.accentRed, size: 64),
          const SizedBox(height: 16),
          Text('Error Loading Profile', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Obx(() => Text(
            controller.errorMessage.value,
            style: TextStyle(color: AppColors.accentRed),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.refreshProfile(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  _buildTopLogo(double screenWidth, bool isPortrait, bool isTablet) {
    final logoSize = _getLogoSize(screenWidth, isPortrait, isTablet, isTop: true);
    return CustomSvg(
      assetPath: AppAssets.okrLogo,
      width: logoSize,
      height: logoSize,
      semanticsLabel: 'okr_logo'.tr,
    );
  }

  _buildTitleSection(ThemeData theme, double screenWidth, bool isPortrait, bool isTablet) {
    final titleSize = _getTitleSize(screenWidth, isPortrait, isTablet);
    return Text(
      'my_profile'.tr,
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

  _buildSubtitleSection(double screenWidth, bool isTablet, bool isDesktop) {
    final subtitleSize = _getSubtitleSize(screenWidth, isTablet, isDesktop);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? screenWidth * 0.1 : screenWidth * 0.05,
      ),
      child: Text(
        'view_manage_profile'.tr,
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

  _buildInputFieldsSection(double screenHeight, double screenWidth, bool isTablet, BuildContext context) {
    final fieldSpacing = _getFieldSpacing(screenHeight, isTablet);
    final iconSize = screenWidth * 0.05;

    return Obx(() => Column(
      children: [
        GestureDetector(
          onTap: controller.isEditMode.value
              ? () => _showMobileImagePickerBottomSheet(context)
              : null,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.1),
              border: Border.all(
                color: controller.isEditMode.value
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                width: 3,
              ),
              image: controller.selectedProfileImage.value.isNotEmpty
                  ? DecorationImage(
                image: AssetImage(controller.selectedProfileImage.value),
                fit: BoxFit.cover,
              )
                  : controller.user.value?.avatarPicId?.isNotEmpty == true
                  ? DecorationImage(
                image: _getImageProvider(controller.user.value!.avatarPicId),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: controller.user.value?.avatarPicId?.isEmpty == true &&
                controller.selectedProfileImage.value.isEmpty
                ? Icon(Icons.person, size: 50, color: AppColors.primaryBlue)
                : controller.isEditMode.value
                ? Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            )
                : null,
          ),
        ),
        SizedBox(height: fieldSpacing * 1.5),
        CustomTextField(
          controller: controller.nameController,
          hint: 'enter_name'.tr,
          enabled: controller.isEditMode.value,
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: iconSize),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          controller: controller.emailController,
          hint: 'enter_email'.tr,
          enabled: false,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary, size: iconSize),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          controller: controller.phoneController,
          hint: 'enter_phone'.tr,
          enabled: controller.isEditMode.value,
          keyboardType: TextInputType.phone,
          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: iconSize),
        ),
      ],
    ));
  }

  ImageProvider _getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return const AssetImage('assets/images/placeholder.png');
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    return AssetImage(imagePath);
  }

  void _showMobileImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_profile_image'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: profileImages.length,
              itemBuilder: (context, index) {
                final imageAsset = profileImages[index];
                final isSelected = controller.selectedProfileImage.value == imageAsset;

                return GestureDetector(
                  onTap: () {
                    controller.selectProfileImage(imageAsset);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                        width: isSelected ? 3 : 2,
                      ),
                      image: DecorationImage(
                        image: AssetImage(imageAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: isSelected
                        ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                      child: const Center(
                        child: Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 28),
                      ),
                    )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildUpdateCancelButtons(bool isTablet) {
    return Column(
      children: [
        Obx(() => SizedBox(
          width: isTablet ? 350.0 : double.infinity,
          child: CustomButton(
            text: 'update_profile'.tr,
            onPressed: controller.updateProfile,
            isLoading: controller.isLoading.value,
          ),
        )),
        const SizedBox(height: 12),
        SizedBox(
          width: isTablet ? 350.0 : double.infinity,
          child: OutlinedButton(
            onPressed: controller.toggleEditMode,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  _buildEditLogoutButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: isTablet ? 350.0 : double.infinity,
          child: CustomButton(text: 'edit_profile'.tr, onPressed: controller.toggleEditMode),
        ),
        const SizedBox(height: 12),
        Obx(() => SizedBox(
          width: isTablet ? 350.0 : double.infinity,
          child: CustomButton(
            text: 'logout'.tr,
            onPressed: controller.logout,
            isLoading: controller.isLoading.value,
            backgroundColor: AppColors.accentRed,
          ),
        )),
      ],
    );
  }

  _buildBottomLogo(double screenWidth, bool isTablet) {
    final logoSize = _getLogoSize(screenWidth, true, isTablet, isTop: false);
    return CustomSvg(
      assetPath: 'assets/images/logo.svg',
      width: logoSize,
      height: logoSize,
      semanticsLabel: 'bottom_logo'.tr,
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

  double _getResponsiveSpacing(double screenHeight, double factor) => screenHeight * factor;

  double _getLogoSize(double screenWidth, bool isPortrait, bool isTablet, {required bool isTop}) {
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
}