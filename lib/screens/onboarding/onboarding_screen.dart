import 'package:flutter/material.dart';

import '../auth/auth_common.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<OnboardData> pages = const [
    OnboardData(
      image: 'assets/images/welcome.png',
      greenTitle: 'Healthy You,',
      blackTitle: 'Better Tomorrow',
      description:
          'Track your meals, improve\nyour sleep and achieve\nyour health goals',
      button: 'Get Start',
    ),
    OnboardData(
      image: 'assets/images/track.png',
      greenTitle: 'Track',
      blackTitle: 'Everything',
      description: 'Log your meals, sleep\nand stay on track',
      button: 'Next',
    ),
    OnboardData(
      image: 'assets/images/heart.png',
      greenTitle: 'Improve',
      blackTitle: 'Your Health',
      description:
          'Get insights and personalized\nrecommendation to build\nbetter habits',
      button: 'Next',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final page = pages[index];

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final topGap = constraints.maxHeight * 0.09;
                final imageHeight = constraints.maxHeight * 0.24;
                final titleGap = constraints.maxHeight * 0.05;
                final descriptionGap = constraints.maxHeight * 0.035;
                final bottomGap = constraints.maxHeight * 0.04;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      SizedBox(height: topGap.clamp(36.0, 86.0)),
                      Image.asset(
                        page.image,
                        height: imageHeight.clamp(145.0, 185.0),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: titleGap.clamp(24.0, 58.0)),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                            letterSpacing: 0,
                          ),
                          children: [
                            TextSpan(
                              text: '${page.greenTitle} ',
                              style: const TextStyle(color: AppColors.green),
                            ),
                            TextSpan(
                              text: page.blackTitle,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: descriptionGap.clamp(18.0, 34.0)),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 7),
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: currentIndex == dotIndex
                                  ? AppColors.green
                                  : const Color(0xFFD8D8D8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: 165,
                        height: 40,
                        child: PrimaryButton(
                          label: page.button,
                          onPressed: nextPage,
                        ),
                      ),
                      SizedBox(height: bottomGap.clamp(18.0, 40.0)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
