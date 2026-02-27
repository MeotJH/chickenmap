import 'package:flutter/material.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';

// 로그인 시작 화면을 표현한다.
class AuthStartPage extends StatelessWidget {
  const AuthStartPage({super.key});

  @override
  // 로그인 시작 화면 UI를 렌더링한다.
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.appName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.emoji_food_beverage, size: 120, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chicken',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Map',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '로그인하고 내 주변 치킨 지도를 만들어보세요!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _AuthButton(
                            label: '카카오로 시작하기',
                            backgroundColor: AppColors.kakao,
                            textColor: const Color(0xFF3C1E1E),
                            icon: Icons.chat_bubble,
                            onPressed: () => context.go('/ranking'),
                          ),
                          const SizedBox(height: 12),
                          _AuthButton(
                            label: '네이버로 시작하기',
                            backgroundColor: AppColors.naver,
                            textColor: Colors.white,
                            icon: Icons.square,
                            onPressed: () => context.go('/ranking'),
                          ),
                          const SizedBox(height: 12),
                          _AuthButton(
                            label: 'Google로 시작하기',
                            backgroundColor: Colors.white,
                            textColor: AppColors.textPrimary,
                            borderColor: AppColors.cardBorder,
                            icon: Icons.g_mobiledata,
                            onPressed: () => context.go('/ranking'),
                          ),
                          const SizedBox(height: 12),
                          _AuthButton(
                            label: 'Apple로 시작하기',
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            icon: Icons.apple,
                            onPressed: () => context.go('/ranking'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.go('/ranking'),
                            child: const Text('비회원으로 둘러보기'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '로그인하면 이용약관 및 개인정보 처리방침에 동의한 것으로 간주됩니다.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 소셜 로그인 버튼을 표현하는 위젯이다.
class _AuthButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final IconData icon;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  // 소셜 로그인 버튼 스타일을 적용한다.
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
