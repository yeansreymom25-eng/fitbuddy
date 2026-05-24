import 'package:flutter/material.dart';

import '../../models/meal_plan.dart';
import '../../services/meal_plan_service.dart';
import '../../services/motivation_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_goal_screen.dart';
import '../progress/progress_screen.dart';
import '../reminders/reminders_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealPlanColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const _MealHeader(),
            Expanded(
              child: StreamBuilder<DailyMealPlan>(
                stream:
                    MealPlanService.instance.watchPlanForDate(_selectedDate),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: MealPlanColors.green),
                    );
                  }
                  final plan = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeekStrip(
                          selected: _selectedDate,
                          onSelected: (date) => setState(() {
                            _selectedDate = date;
                          }),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${_dayTitle(_selectedDate)} - ${plan.caloriesTarget} kcal target',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final meal in plan.meals) ...[
                          _MealPlanCard(meal: meal),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 4),
                        const _MealMotivationCard(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _MealNavBar(),
    );
  }

  String _dayTitle(DateTime date) {
    final now = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (selected == today) {
      return "Today's Plan";
    }
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${names[date.weekday - 1]} ${date.month}/${date.day} Plan';
  }
}

class _MealHeader extends StatelessWidget {
  const _MealHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Plan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fresh meals are generated and saved every day',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: MealPlanColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Reminders',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  const _WeekStrip({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = start.add(Duration(days: index));
          final active = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return InkWell(
            onTap: () => onSelected(day),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 58,
              decoration: BoxDecoration(
                color: active ? MealPlanColors.softGreen : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active ? MealPlanColors.green : MealPlanColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: active ? MealPlanColors.green : Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${day.month}/${day.day}',
                    style: TextStyle(
                      color: active
                          ? MealPlanColors.green
                          : MealPlanColors.textGrey,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  final MealPlanItem meal;

  const _MealPlanCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MealPlanColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: MealPlanColors.softGreen,
            child: Image.asset(meal.image, width: 38, height: 38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${meal.time} - ${meal.calories} kcal',
                  style: const TextStyle(
                    color: MealPlanColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MealPlanColors.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Carbs ${meal.carbs}g  Protein ${meal.protein}g  Fat ${meal.fat}g',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MealPlanColors.textGrey,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'How to cook',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => _MealDetailScreen(meal: meal)),
              );
            },
            icon: const Icon(Icons.chevron_right_rounded),
            color: MealPlanColors.iconGrey,
          ),
        ],
      ),
    );
  }
}

class _MealDetailScreen extends StatelessWidget {
  final MealPlanItem meal;

  const _MealDetailScreen({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealPlanColors.page,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MealPlanColors.softGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Image.asset(meal.image, width: 86, height: 86),
                    const SizedBox(height: 12),
                    Text(
                      meal.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${meal.time} - ${meal.calories} kcal',
                      style: const TextStyle(
                        color: MealPlanColors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      meal.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: MealPlanColors.textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _NutritionTile(label: 'Carbs', value: '${meal.carbs}g'),
                  _NutritionTile(label: 'Protein', value: '${meal.protein}g'),
                  _NutritionTile(label: 'Fat', value: '${meal.fat}g'),
                ],
              ),
              const SizedBox(height: 22),
              const Text('Ingredients', style: _sectionStyle),
              const SizedBox(height: 10),
              for (final item in meal.ingredients) _DetailBullet(text: item),
              const SizedBox(height: 22),
              const Text('How to Cook', style: _sectionStyle),
              const SizedBox(height: 10),
              for (var i = 0; i < meal.steps.length; i++)
                _CookingStep(number: i + 1, text: meal.steps[i]),
            ],
          ),
        ),
      ),
    );
  }
}

const _sectionStyle = TextStyle(
  color: Colors.black,
  fontSize: 18,
  fontWeight: FontWeight.w900,
);

class _NutritionTile extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MealPlanColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: MealPlanColors.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _DetailBullet extends StatelessWidget {
  final String text;

  const _DetailBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: MealPlanColors.green, size: 18),
          const SizedBox(width: 9),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _CookingStep extends StatelessWidget {
  final int number;
  final String text;

  const _CookingStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: MealPlanColors.green,
            child: Text('$number',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.25))),
        ],
      ),
    );
  }
}

class _MealMotivationCard extends StatelessWidget {
  const _MealMotivationCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: MotivationService.instance.watchToday(),
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            color: MealPlanColors.motivationPink,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: MealPlanColors.purple, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  snapshot.data ?? 'Eat with care and keep going.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900, height: 1.2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MealNavBar extends StatelessWidget {
  const _MealNavBar();

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
            _MealNavItem(
                icon: Icons.home_rounded,
                label: 'Dashboard',
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen()))),
            const _MealNavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Meal Plan',
                isActive: true),
            _MealNavItem(
                icon: Icons.auto_awesome_rounded,
                label: 'Food Help',
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()))),
            _MealNavItem(
                icon: Icons.notifications_none_rounded,
                label: 'Reminders',
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const RemindersScreen()))),
            _MealNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const ProfileGoalScreen()))),
          ],
        ),
      ),
    );
  }
}

class _MealNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _MealNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? MealPlanColors.green : MealPlanColors.navGrey;
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

class MealPlanColors {
  static const page = Color(0xFFFFFFFF);
  static const green = Color(0xFF008A08);
  static const softGreen = Color(0xFFE5FBE8);
  static const purple = Color(0xFF9C1BA6);
  static const motivationPink = Color(0xFFECCFEB);
  static const textGrey = Color(0xFF777777);
  static const iconGrey = Color(0xFF8F8F96);
  static const navGrey = Color(0xFFC4C4CA);
  static const border = Color(0xFFD7D7D7);

  const MealPlanColors._();
}
