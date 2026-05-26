import 'package:flutter/material.dart';

import '../../services/user_settings_service.dart';

class AchievementFeedbackScreen extends StatefulWidget {
  const AchievementFeedbackScreen({super.key});

  @override
  State<AchievementFeedbackScreen> createState() =>
      _AchievementFeedbackScreenState();
}

class _AchievementFeedbackScreenState extends State<AchievementFeedbackScreen> {
  UserFeedbackSettings _feedback = UserFeedbackSettings.defaults();
  bool _saving = false;

  Future<void> _save(UserFeedbackSettings feedback) async {
    setState(() {
      _saving = true;
      _feedback = feedback;
    });
    try {
      await UserSettingsService.instance.saveFeedback(feedback);
      if (mounted) {
        _message('Rating saved. Achievement unlocked.');
      }
    } catch (_) {
      if (mounted) {
        _message('Unable to save rating right now.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _AchievementColors.green,
        content:
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AchievementColors.page,
      appBar: AppBar(
        backgroundColor: _AchievementColors.page,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Achievements & Rating',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: StreamBuilder<UserFeedbackSettings>(
        stream: UserSettingsService.instance.watchFeedback(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _feedback;
          if (!_saving && snapshot.hasData) {
            _feedback = data;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _AchievementCard(
                      icon: Icons.person_pin_rounded,
                      title: 'Profile Ready',
                      subtitle: 'Health details saved',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _AchievementCard(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Meal Planner',
                      subtitle: 'Daily meals active',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: _AchievementCard(
                      icon: Icons.tune_rounded,
                      title: 'Personalized',
                      subtitle: 'Preferences added',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AchievementCard(
                      icon: Icons.rate_review_rounded,
                      title: 'Rating',
                      subtitle: '${_ratingValue(data.rating)}/5 stars saved',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: _AchievementColors.surfaceDecoration,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate your FitBuddy experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StarRating(
                      value: _ratingValue(data.rating),
                      onChanged: (value) =>
                          _save(data.copyWith(rating: '$value')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StarRating({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your rating',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => onChanged(i),
                  icon: Icon(
                    i <= value ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFE8A11A),
                    size: 30,
                  ),
                  tooltip: '$i stars',
                ),
              const SizedBox(width: 6),
              Text(
                '$value/5',
                style: const TextStyle(
                  color: _AchievementColors.textGrey,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int _ratingValue(String rating) {
  final parsed = int.tryParse(rating);
  if (parsed != null) {
    return parsed.clamp(1, 5);
  }
  if (rating == 'Great') {
    return 5;
  }
  if (rating == 'Needs Work') {
    return 2;
  }
  return 4;
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      decoration: _AchievementColors.surfaceDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: _AchievementColors.softGreen,
            child: Icon(icon, color: _AchievementColors.green, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _AchievementColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementColors {
  static const page = Color(0xFFFAFCFB);
  static const green = Color(0xFF1F8A5B);
  static const softGreen = Color(0xFFE7F6EE);
  static const border = Color(0xFFE0E5E0);
  static const textGrey = Color(0xFF66736B);

  static BoxDecoration get surfaceDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  const _AchievementColors._();
}
