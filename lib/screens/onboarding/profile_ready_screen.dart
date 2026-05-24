import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../dashboard/dashboard_screen.dart';

class ProfileReadyScreen extends StatelessWidget {
  final AppUserProfile profile;

  const ProfileReadyScreen({
    super.key,
    required this.profile,
  });

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = profile.targetWeightKg;
    final hasTarget = profile.needsWeightGoal && target != null;
    final weightSubtitle = hasTarget
        ? 'Current ${profile.weightKg.toStringAsFixed(0)}kg - Target ${target.toStringAsFixed(0)}kg'
        : '${profile.healthGoal} - ${profile.weightKg.toStringAsFixed(0)}kg';
    final trailing = hasTarget
        ? '${(profile.weightKg - target).abs().toStringAsFixed(0)} kg to go'
        : '${profile.recommendations?.dailyCalories ?? 0} kcal/day';

    return Scaffold(
      backgroundColor: _ReadyColors.paleGreen,
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(24, 92, 36, 0.08),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 260,
                          decoration: BoxDecoration(
                            color: _ReadyColors.surfaceGreen,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _ReadyColors.softBorder),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: _ReadyColors.softBorder,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: _ReadyColors.green,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Plan ready',
                                      style: TextStyle(
                                        color: _ReadyColors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Image.asset(
                                'assets/images/track.png',
                                width: 226,
                                height: 185,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: 0,
                            ),
                            children: [
                              TextSpan(
                                text: "You're ",
                                style: TextStyle(color: _ReadyColors.green),
                              ),
                              TextSpan(text: 'All Set!'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your personalized plan is ready.\nLet's achieve your goals together!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _ReadyColors.textGrey,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.16,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Plan Summary',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SummaryTile(
                          icon: Icons.calendar_today_outlined,
                          title: hasTarget ? 'Weight Goal' : 'Health Goal',
                          subtitle: weightSubtitle,
                          trailing: trailing,
                        ),
                        const SizedBox(height: 10),
                        _SummaryTile(
                          icon: Icons.directions_walk,
                          title: 'Activity Level',
                          subtitle: profile.activityLevel ?? 'Sedentary',
                          trailing:
                              '${profile.recommendations?.exerciseMinutes ?? 25} min',
                        ),
                        const SizedBox(height: 18),
                        const _JourneyTip(),
                        const Spacer(),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _goToDashboard(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _ReadyColors.green,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor:
                                  const Color.fromRGBO(0, 138, 8, 0.18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Go to Dashboard',
                              style: TextStyle(
                                fontSize: 21,
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

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: _ReadyColors.surfaceGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _ReadyColors.softBorder),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(24, 92, 36, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _ReadyColors.softGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _ReadyColors.green, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ReadyColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFC8EFC8)),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                color: _ReadyColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyTip extends StatelessWidget {
  const _JourneyTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: _ReadyColors.softGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA8E8A8)),
      ),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.star_border,
              color: _ReadyColors.green,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Let's Begin Your Journey!",
                  style: TextStyle(
                    color: _ReadyColors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Stay consistent and track your progress.\nWe're here to support you every step of the way.",
                  style: TextStyle(
                    color: _ReadyColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: _ReadyColors.green,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ReadyColors {
  static const green = Color(0xFF008A08);
  static const paleGreen = Color(0xFFEAF8EA);
  static const surfaceGreen = Color(0xFFF6FCF6);
  static const softGreen = Color(0xFFDDFBDD);
  static const textGrey = Color(0xFF777777);
  static const softBorder = Color(0xFFE0E8E0);

  const _ReadyColors._();
}
