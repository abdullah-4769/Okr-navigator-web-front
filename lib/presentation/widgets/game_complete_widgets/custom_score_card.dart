import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Breakpoints
// ─────────────────────────────────────────────────────────────────────────────
bool _isMobile(double sw)  => sw < 600;
bool _isTablet(double sw)  => sw >= 600 && sw < 1024;
bool _isDesktop(double sw) => sw >= 1024;

class CustomScoreCard extends StatelessWidget {
  final int? score;
  final String title;
  final String? description;
  final String? imagePath;
  final bool showBackground;

  const CustomScoreCard({
    super.key,
    this.score,
    required this.title,
    this.description,
    this.imagePath,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    // ── Responsive circle size ───────────────────────────────────────────────
    // Mobile: relative to width | Tablet: smaller relative | Desktop: fixed
    final double circleSize = _isDesktop(sw)
        ? 110.0
        : _isTablet(sw)
        ? (sw * 0.14).clamp(80.0, 110.0)
        : (sw * 0.26).clamp(72.0, 100.0);

    // ── Responsive font sizes — plain double on desktop, .sp on mobile ───────
    final double scoreFontSize = _isDesktop(sw)
        ? 22.0
        : _isTablet(sw)
        ? 18.0
        : 20.sp;

    final double labelFontSize = _isDesktop(sw)
        ? 11.0
        : _isTablet(sw)
        ? 10.0
        : 10.sp;

    final double titleFontSize = _isDesktop(sw)
        ? 15.0
        : _isTablet(sw)
        ? 14.0
        : 14.sp;

    final double descFontSize = _isDesktop(sw)
        ? 12.0
        : _isTablet(sw)
        ? 11.0
        : 11.sp;

    // ── Responsive padding & spacing ─────────────────────────────────────────
    final double cardPadding = _isDesktop(sw)
        ? 18.0
        : _isTablet(sw)
        ? 14.0
        : sw * 0.035;

    final double cardMarginH = _isDesktop(sw)
        ? 0.0
        : _isTablet(sw)
        ? sw * 0.02
        : sw * 0.025;

    final double gapBelowCircle = _isDesktop(sw) ? 10.0 : 8.0;
    final double gapBelowTitle  = _isDesktop(sw) ? 5.0  : 4.0;

    // ── Circle content ───────────────────────────────────────────────────────
    final Widget circleContent = SizedBox(
      width:  circleSize,
      height: circleSize,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryRed.withOpacity(0.12),
              Colors.white,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _GradientBorderPainter(),
          child: Center(
            child: imagePath != null
                ? ClipOval(
              child: Image.asset(
                imagePath!,
                width:  circleSize * 0.88,
                height: circleSize * 0.88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: circleSize * 0.5,
                  color: AppColors.primaryRed,
                ),
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${score ?? 0}%',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: scoreFontSize,
                    height: 1.1,
                  ),
                ),
                Text(
                  'final_score'.tr,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: labelFontSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // ── Card body ────────────────────────────────────────────────────────────
    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        circleContent,
        SizedBox(height: gapBelowCircle),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontSize: titleFontSize,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (description != null && description!.isNotEmpty) ...[
          SizedBox(height: gapBelowTitle),
          Text(
            description!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: descFontSize,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    if (!showBackground) return body;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: cardMarginH),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_isDesktop(sw) ? 18 : 16.r),
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryRed,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: body,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient border painter — unchanged logic, same visual
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryRed.withOpacity(0.9),
        AppColors.primaryRed.withOpacity(0.25),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.035;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -3.14 / 2,
      3.14 * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}