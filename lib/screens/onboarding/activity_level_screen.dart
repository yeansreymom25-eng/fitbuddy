import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/recommendation_calculator.dart';
import '../../services/user_profile_service.dart';
import 'profile_ready_screen.dart';

class ActivityLevelScreen extends StatefulWidget {
  final AppUserProfile profile;

  const ActivityLevelScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  int selectedIndex = 0;
  bool isSaving = false;

  final List<_ActivityOption> options = const [
    _ActivityOption(
      icon: Icons.accessibility_new,
      title: 'Sedentary',
      subtitle: 'Little or no exercise',
    ),
    _ActivityOption(
      icon: Icons.directions_walk,
      title: 'Lightly Active',
      subtitle: 'Exercise 1-3 days per week',
    ),
    _ActivityOption(
      icon: Icons.directions_run,
      title: 'Moderately Active',
      subtitle: 'Exercise 3-5 days per week',
    ),
    _ActivityOption(
      icon: Icons.sports_gymnastics,
      title: 'Very Active',
      subtitle: 'Exercise 6-7 days per week',
    ),
  ];

  Future<void> continueNext() async {
    setState(() => isSaving = true);
    final profile = widget.profile.copyWith(
      activityLevel: options[selectedIndex].title,
      onboardingComplete: true,
      clearTargetWeight: !widget.profile.needsWeightGoal,
    );

    try {
      await UserProfileService.instance.saveProfile(profile);
      if (!mounted) {
        return;
      }
      final readyProfile = profile.copyWith(
        recommendations: RecommendationCalculator.calculate(profile),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfileReadyScreen(profile: readyProfile),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Unable to finish your profile right now.'),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ActivityColors.paleGreen,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4F2E4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(24, 92, 36, 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(31, 29, 31, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 11),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: 0,
                            ),
                            children: [
                              TextSpan(text: 'How Active\n'),
                              TextSpan(
                                text: 'Are You ?',
                                style: TextStyle(color: _ActivityColors.green),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell us your current weight and\nyour target weight.',
                          style: TextStyle(
                            color: _ActivityColors.textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Image.asset(
                            'assets/images/track.png',
                            width: 235,
                            height: 190,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Select your activity level',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          options.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ActivityTile(
                              option: options[index],
                              isSelected: selectedIndex == index,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : continueNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _ActivityColors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isSaving ? 'Saving...' : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? _ActivityColors.surfaceGreen : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? _ActivityColors.green
                  : _ActivityColors.softBorder,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _ActivityColors.softGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon, color: Colors.black87, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      option.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ActivityColors.textGrey,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? _ActivityColors.green
                        : const Color(0xFFCFCFCF),
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: _ActivityColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityOption {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _ActivityColors {
  static const green = Color(0xFF008A08);
  static const paleGreen = Color(0xFFEAF8EA);
  static const surfaceGreen = Color(0xFFF6FCF6);
  static const softGreen = Color(0xFFDDFBDD);
  static const textGrey = Color(0xFF777777);
  static const softBorder = Color(0xFFE0E8E0);

  const _ActivityColors._();
}
