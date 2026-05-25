import 'package:flutter/material.dart';

import '../../models/daily_progress.dart';
import '../../models/meal_plan.dart';
import '../../models/user_profile.dart';
import '../../services/daily_progress_service.dart';
import '../../services/meal_plan_service.dart';
import '../../services/motivation_service.dart';
import '../../services/user_profile_service.dart';
import '../meal/meal_plan_screen.dart';
import '../profile/profile_goal_screen.dart';
import '../progress/progress_screen.dart';
import '../reminders/reminders_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.page,
      body: SafeArea(
        child: StreamBuilder<AppUserProfile?>(
          stream: UserProfileService.instance.watchCurrentProfile(),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;
            final rec =
                profile?.recommendations ?? UserRecommendations.fromMap(null);
            return StreamBuilder<DailyProgress>(
              stream: DailyProgressService.instance.watchToday(),
              builder: (context, progressSnapshot) {
                final progress =
                    progressSnapshot.data ?? const DailyProgress(id: 'today');
                return StreamBuilder<DailyMealPlan>(
                  stream: MealPlanService.instance.watchToday(),
                  builder: (context, mealSnapshot) {
                    final meals =
                        mealSnapshot.data?.meals ?? const <MealPlanItem>[];
                    return _DashboardBody(
                      profile: profile,
                      recommendations: rec,
                      progress: progress,
                      meals: meals,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const _DashboardNavBar(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final AppUserProfile? profile;
  final UserRecommendations recommendations;
  final DailyProgress progress;
  final List<MealPlanItem> meals;

  const _DashboardBody({
    required this.profile,
    required this.recommendations,
    required this.progress,
    required this.meals,
  });

  int get _waterGlasses => (progress.waterMl / 250).floor();
  int get _waterGoalGlasses => (recommendations.waterMl / 250).ceil();
  int get _sleepGoalMinutes => (recommendations.sleepHours * 60).round();

  String _sleepLabel(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
  }

void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        margin: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).size.height - 170,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDDFBDD)),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFDDFBDD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF008A08),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    final firstName = (profile?.fullName.trim().isEmpty ?? true)
        ? 'there'
        : profile!.fullName.trim().split(' ').first;
    final mealGoal = meals.isEmpty ? 4 : meals.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          children: [
            _Header(name: firstName),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressSection(
                      completedMeals: progress.completedMealIds.length,
                      mealGoal: mealGoal,
                      waterMl: progress.waterMl,
                      waterGoalMl: recommendations.waterMl,
                      sleepMinutes: progress.sleepMinutes,
                      sleepGoalMinutes: _sleepGoalMinutes,
                      exerciseMinutes: progress.exerciseMinutes,
                      exerciseGoalMinutes: recommendations.exerciseMinutes,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Recommended for ${profile?.healthGoal ?? 'your goal'}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RecommendationsRow(recommendations: recommendations),
                    const SizedBox(height: 16),
                    _MealCard(
                      meals: meals,
                      completedIds: progress.completedMealIds,
                      onToggle: (meal) async {
                        final completed =
                            progress.completedMealIds.contains(meal.id);
                        await DailyProgressService.instance
                            .setMealCompleted(meal.id, !completed);
                        if (context.mounted) {
                          _message(
                            context,
                            completed
                                ? '${meal.title} removed from today.'
                                : '${meal.title} completed.',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TrackerCard(
                            title: 'Water',
                            subtitle:
                                '${progress.waterMl}/${recommendations.waterMl} ml',
                            icon: Icons.water_drop_rounded,
                            color: DashboardColors.blue,
                            value: '$_waterGlasses/$_waterGoalGlasses',
                            label: 'glasses',
                            progress:
                                progress.waterMl / recommendations.waterMl,
                            button: 'Log 250 ml',
                            onPressed:
                                progress.waterMl >= recommendations.waterMl
                                    ? null
                                    : () => DailyProgressService.instance
                                        .logWater(250, recommendations.waterMl),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TrackerCard(
                            title: 'Sleep',
                            subtitle: 'Goal ${_sleepLabel(_sleepGoalMinutes)}',
                            icon: Icons.bedtime_rounded,
                            color: DashboardColors.purple,
                            value: _sleepLabel(progress.sleepMinutes),
                            label: 'tracked',
                            progress: progress.sleepMinutes / _sleepGoalMinutes,
                            button: 'Log 30 min',
                            onPressed:
                                progress.sleepMinutes >= _sleepGoalMinutes
                                    ? null
                                    : () => DailyProgressService.instance
                                        .logSleep(30, _sleepGoalMinutes),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _TrackerCard(
                      title: 'Exercise',
                      subtitle:
                          'Goal ${recommendations.exerciseMinutes} min for today',
                      icon: Icons.directions_run_rounded,
                      color: DashboardColors.orange,
                      value: '${progress.exerciseMinutes} min',
                      label: 'movement',
                      progress: progress.exerciseMinutes /
                          recommendations.exerciseMinutes,
                      button: 'Log 10 min',
                      onPressed: progress.exerciseMinutes >=
                              recommendations.exerciseMinutes
                          ? null
                          : () => DailyProgressService.instance.logExercise(
                                10,
                                recommendations.exerciseMinutes,
                              ),
                    ),
                    const SizedBox(height: 14),
                    const _MotivationCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;

  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your plan refreshes automatically every day.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DashboardColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: DashboardColors.green,
            ),
            style: IconButton.styleFrom(
              backgroundColor: DashboardColors.softGreen,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final int completedMeals;
  final int mealGoal;
  final int waterMl;
  final int waterGoalMl;
  final int sleepMinutes;
  final int sleepGoalMinutes;
  final int exerciseMinutes;
  final int exerciseGoalMinutes;

  const _ProgressSection({
    required this.completedMeals,
    required this.mealGoal,
    required this.waterMl,
    required this.waterGoalMl,
    required this.sleepMinutes,
    required this.sleepGoalMinutes,
    required this.exerciseMinutes,
    required this.exerciseGoalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ProgressTile(
                icon: Icons.local_dining_rounded,
                color: DashboardColors.green,
                title: '$completedMeals/$mealGoal',
                subtitle: 'meals',
                progress: mealGoal == 0 ? 0 : completedMeals / mealGoal,
              ),
              _ProgressTile(
                icon: Icons.water_drop_rounded,
                color: DashboardColors.blue,
                title: '${(waterMl / 250).floor()}',
                subtitle: 'glasses',
                progress: waterMl / waterGoalMl,
              ),
              _ProgressTile(
                icon: Icons.bedtime_rounded,
                color: DashboardColors.purple,
                title: '${(sleepMinutes / 60).toStringAsFixed(1)}h',
                subtitle: 'sleep',
                progress: sleepMinutes / sleepGoalMinutes,
              ),
              _ProgressTile(
                icon: Icons.directions_run_rounded,
                color: DashboardColors.orange,
                title: '$exerciseMinutes',
                subtitle: 'minutes',
                progress: exerciseMinutes / exerciseGoalMinutes,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final double progress;

  const _ProgressTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 86,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DashboardColors.textGrey,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 5,
                backgroundColor: const Color(0xFFE2E2E2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsRow extends StatelessWidget {
  final UserRecommendations recommendations;

  const _RecommendationsRow({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RecPill('${recommendations.dailyCalories}', 'kcal',
            Icons.local_fire_department_rounded),
        _RecPill('${recommendations.proteinGrams}g', 'protein',
            Icons.egg_alt_rounded),
        _RecPill(
            '${recommendations.waterMl}ml', 'water', Icons.water_drop_rounded),
      ],
    );
  }
}

class _RecPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _RecPill(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 62,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: DashboardColors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: DashboardColors.textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final List<MealPlanItem> meals;
  final Set<String> completedIds;
  final ValueChanged<MealPlanItem> onToggle;

  const _MealCard({
    required this.meals,
    required this.completedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _Surface(
      color: DashboardColors.mealGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu_rounded,
                  color: DashboardColors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Meal Plan Today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MealPlanScreen()),
                ),
                child: const Text('View'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            const Text('Preparing today meal plan...')
          else
            for (final meal in meals)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Image.asset(meal.image, width: 42, height: 42),
                title: Text(meal.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle:
                    Text('${meal.calories} kcal - ${meal.time}', maxLines: 1),
                trailing: Icon(
                  completedIds.contains(meal.id)
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: completedIds.contains(meal.id)
                      ? DashboardColors.green
                      : DashboardColors.textGrey,
                ),
                onTap: () => onToggle(meal),
              ),
        ],
      ),
    );
  }
}

class _TrackerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final double progress;
  final String button;
  final VoidCallback? onPressed;

  const _TrackerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.progress,
    required this.button,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _Surface(
      color: color.withValues(alpha: .12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: DashboardColors.textGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1)),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(button,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: MotivationService.instance.watchToday(),
      builder: (context, snapshot) {
        return _Surface(
          color: DashboardColors.motivationPink,
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: DashboardColors.purple, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  snapshot.data ?? 'Every healthy choice counts today.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, height: 1.2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Surface extends StatelessWidget {
  final Color color;
  final Widget child;

  const _Surface({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _DashboardNavBar extends StatelessWidget {
  const _DashboardNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _NavItem(
                icon: Icons.home_rounded, label: 'Dashboard', isActive: true),
            _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Meal Plan',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MealPlanScreen()))),
            _NavItem(
                icon: Icons.auto_awesome_rounded,
                label: 'Food Help',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()))),
            _NavItem(
                icon: Icons.notifications_none_rounded,
                label: 'Reminders',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const RemindersScreen()))),
            _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProfileGoalScreen()))),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? DashboardColors.green : DashboardColors.navGrey;
    return SizedBox(
      width: 70,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardColors {
  static const page = Color(0xFFFFFFFF);
  static const green = Color(0xFF008A08);
  static const softGreen = Color(0xFFDDFBDD);
  static const mealGreen = Color(0xFFE0FCE0);
  static const blue = Color(0xFF149BFF);
  static const purple = Color(0xFF9C1BA6);
  static const orange = Color(0xFFFF8724);
  static const motivationPink = Color(0xFFECCFEB);
  static const textGrey = Color(0xFF777777);
  static const navGrey = Color(0xFFC4C4CA);

  const DashboardColors._();
}
