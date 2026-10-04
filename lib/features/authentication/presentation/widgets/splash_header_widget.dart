import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class SplashHeaderWidget extends StatelessWidget {
  const SplashHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo
        Image.asset(
          AppAssets.logo,
          width: 140,
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.psychology,
              size: 100,
              color: AppColors.primary,
            );
          },
        ),
        const SizedBox(height: 16),

        // Brand Title: CogniCare AI
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: AppStrings.appTitlePrefix,
                style: TextStyle(
                  color: AppColors.titleNavy,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: AppStrings.appTitleSuffix,
                style: TextStyle(
                  color: AppColors.brandTeal,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tagline
        const Text(
          AppStrings.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.taglineBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 20),

        // Description Paragraph
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(
            AppStrings.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A607A),
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
