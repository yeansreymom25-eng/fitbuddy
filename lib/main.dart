import 'package:flutter/material.dart';

void main() {
  runApp(const FitBuddyApp());
}

class FitBuddyApp extends StatelessWidget {
  const FitBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _primaryGreen = Color(0xFF008A08);

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
      frame: 'Frame 1',
    ),
    OnboardData(
      image: 'assets/images/track.png',
      greenTitle: 'Track',
      blackTitle: 'Everything',
      description: 'Log your meals, sleep\nand stay on track',
      button: 'Next',
      frame: 'Frame 2',
    ),
    OnboardData(
      image: 'assets/images/heart.png',
      greenTitle: 'Improve',
      blackTitle: 'Your Health',
      description:
          'Get insights and personalized\nrecommendation to build\nbetter habits',
      button: 'Next',
      frame: 'Frame 3',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Login Screen next')),
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
                final topGap = constraints.maxHeight * 0.11;
                final imageHeight = constraints.maxHeight * 0.24;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      SizedBox(height: topGap.clamp(54.0, 86.0)),
                      Image.asset(
                        page.image,
                        height: imageHeight.clamp(145.0, 185.0),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 58),
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
                              style: const TextStyle(color: _primaryGreen),
                            ),
                            TextSpan(
                              text: page.blackTitle,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF7B7B7B),
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
                                  ? _primaryGreen
                                  : const Color(0xFFD8D8D8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: 165,
                        child: Text(
                          page.frame,
                          style: const TextStyle(
                            color: Color(0xFFE1E1E1),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        width: 165,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            page.button,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

class OnboardData {
  final String image;
  final String greenTitle;
  final String blackTitle;
  final String description;
  final String button;
  final String frame;

  const OnboardData({
    required this.image,
    required this.greenTitle,
    required this.blackTitle,
    required this.description,
    required this.button,
    required this.frame,
  });
}
