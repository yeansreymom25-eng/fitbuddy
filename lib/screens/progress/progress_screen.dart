import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/food_ai_service.dart';
import '../../services/user_profile_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../meal/meal_plan_screen.dart';
import '../profile/profile_goal_screen.dart';
import '../reminders/reminders_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = ['Chicken', 'Broccoli', 'Rice'];
  int _selectedTab = 0;
  AppUserProfile? _profile;

  static const _tabs = [
    _HelperTab('Cook Ideas', Icons.restaurant_menu_rounded),
    _HelperTab('Health Check', Icons.verified_rounded),
    _HelperTab('Nutrition', Icons.eco_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfileService.instance.getCurrentProfile();
    if (mounted) {
      setState(() => _profile = profile);
    }
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final value = _ingredientController.text.trim();
    if (value.isEmpty) {
      return;
    }
    final newIngredients = value
        .split(RegExp(r'[,;\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    setState(() {
      for (final ingredient in newIngredients) {
        final alreadyAdded = _ingredients.any(
          (item) => item.toLowerCase() == ingredient.toLowerCase(),
        );
        if (!alreadyAdded) {
          _ingredients.add(ingredient);
        }
      }
      _ingredientController.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() => _ingredients.remove(ingredient));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodHelperColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const _FoodHelperHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IngredientInput(
                      controller: _ingredientController,
                      onAdd: _addIngredient,
                    ),
                    const SizedBox(height: 14),
                    _IngredientChips(
                      ingredients: _ingredients,
                      onRemove: _removeIngredient,
                    ),
                    const SizedBox(height: 18),
                    _HelperTabs(
                      tabs: _tabs,
                      selectedIndex: _selectedTab,
                      onChanged: (index) =>
                          setState(() => _selectedTab = index),
                    ),
                    const SizedBox(height: 18),
                    _HelperBody(
                      key: ValueKey(
                        '$_selectedTab-${_ingredients.join('|')}-${_profile?.healthGoal}',
                      ),
                      selectedTab: _selectedTab,
                      ingredients: _ingredients,
                      profile: _profile,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _FoodHelperNavBar(),
    );
  }
}

class _FoodHelperHeader extends StatelessWidget {
  const _FoodHelperHeader();

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
                  'Food Helper',
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
                  'Add ingredients and get healthy meal ideas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: FoodHelperColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: FoodHelperColors.softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: FoodHelperColors.green,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const _IngredientInput({
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FoodHelperColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        children: [
          const Icon(
            Icons.kitchen_rounded,
            color: FoodHelperColors.green,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onAdd(),
              decoration: const InputDecoration(
                hintText: 'Add ingredient, e.g. egg, tomato',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: FoodHelperColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientChips extends StatelessWidget {
  final List<String> ingredients;
  final ValueChanged<String> onRemove;

  const _IngredientChips({
    required this.ingredients,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Text(
        'No ingredients added yet.',
        style: TextStyle(
          color: FoodHelperColors.textGrey,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final ingredient in ingredients)
          InputChip(
            label: Text(ingredient),
            onDeleted: () => onRemove(ingredient),
            deleteIcon: const Icon(Icons.close_rounded, size: 16),
            backgroundColor: FoodHelperColors.softGreen,
            side: BorderSide.none,
            labelStyle: const TextStyle(
              color: FoodHelperColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class _HelperTabs extends StatelessWidget {
  final List<_HelperTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _HelperTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FoodHelperColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            Expanded(
              child: _HelperTabButton(
                tab: tabs[i],
                active: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
            if (i != tabs.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _HelperTabButton extends StatelessWidget {
  final _HelperTab tab;
  final bool active;
  final VoidCallback onTap;

  const _HelperTabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? FoodHelperColors.green : FoodHelperColors.iconGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: active ? FoodHelperColors.softGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, color: color, size: 20),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelperBody extends StatelessWidget {
  final int selectedTab;
  final List<String> ingredients;
  final AppUserProfile? profile;

  const _HelperBody({
    super.key,
    required this.selectedTab,
    required this.ingredients,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTab == 1) {
      return _HealthCheckPanel(ingredients: ingredients, profile: profile);
    }
    if (selectedTab == 2) {
      return _NutritionPanel(ingredients: ingredients, profile: profile);
    }
    return _CookIdeasPanel(ingredients: ingredients, profile: profile);
  }
}

class _CookIdeasPanel extends StatelessWidget {
  final List<String> ingredients;
  final AppUserProfile? profile;

  const _CookIdeasPanel({required this.ingredients, required this.profile});

  @override
  Widget build(BuildContext context) {
    final result =
        FoodAiService.analyze(ingredients: ingredients, profile: profile);
    final ingredientText = ingredients.isEmpty
        ? 'your ingredients'
        : ingredients.take(3).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyzing $ingredientText',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _RecipeIdeaCard(
          title: result.title,
          subtitle: result.summary,
          time: result.time,
          difficulty: result.difficulty,
          color: FoodHelperColors.green,
          icon: Icons.rice_bowl_rounded,
          steps: result.steps,
        ),
        const SizedBox(height: 12),
        _RecipeIdeaCard(
          title: 'Smart Backup Meal',
          subtitle: 'Another idea using ${result.ingredientSummary}',
          time: '15 min',
          difficulty: 'Easy',
          color: FoodHelperColors.orange,
          icon: Icons.local_fire_department_rounded,
          steps: [
            'Cut ingredients into similar sizes.',
            'Cook protein first with a small amount of oil.',
            'Add vegetables and a splash of water to soften.',
            'Season lightly and stop cooking while vegetables still have color.',
          ],
        ),
      ],
    );
  }
}

class _RecipeIdeaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String difficulty;
  final Color color;
  final IconData icon;
  final List<String> steps;

  const _RecipeIdeaCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.difficulty,
    required this.color,
    required this.icon,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: .18),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FoodHelperColors.textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RecipePill(icon: Icons.timer_rounded, text: time, color: color),
              const SizedBox(width: 8),
              _RecipePill(
                icon: Icons.signal_cellular_alt_rounded,
                text: difficulty,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            _CookingLine(number: i + 1, text: steps[i], color: color),
        ],
      ),
    );
  }
}

class _RecipePill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _RecipePill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CookingLine extends StatelessWidget {
  final int number;
  final String text;
  final Color color;

  const _CookingLine({
    required this.number,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: color,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCheckPanel extends StatelessWidget {
  final List<String> ingredients;
  final AppUserProfile? profile;

  const _HealthCheckPanel({required this.ingredients, required this.profile});

  @override
  Widget build(BuildContext context) {
    final result =
        FoodAiService.analyze(ingredients: ingredients, profile: profile);
    return Column(
      children: [
        for (final note in result.healthNotes) ...[
          _IngredientHealthCard(
            icon: Icons.check_circle_rounded,
            title: 'Health check',
            ingredient: note.split(':').first,
            note: note.contains(':')
                ? note.split(':').skip(1).join(':').trim()
                : note,
            color: FoodHelperColors.green,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _IngredientHealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String ingredient;
  final String note;
  final Color color;

  const _IngredientHealthCard({
    required this.icon,
    required this.title,
    required this.ingredient,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FoodHelperColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ingredient,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: const TextStyle(
                    color: FoodHelperColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionPanel extends StatelessWidget {
  final List<String> ingredients;
  final AppUserProfile? profile;

  const _NutritionPanel({required this.ingredients, required this.profile});

  @override
  Widget build(BuildContext context) {
    final result =
        FoodAiService.analyze(ingredients: ingredients, profile: profile);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FoodHelperColors.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balanced plate suggestion',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (final entry in result.split.entries) ...[
            _NutritionSplit(
              label: entry.key,
              value: '${(entry.value * 100).round()}%',
              progress: entry.value,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            result.summary,
            style: TextStyle(
              color: FoodHelperColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionSplit extends StatelessWidget {
  final String label;
  final String value;
  final double progress;

  const _NutritionSplit({
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: .78),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(FoodHelperColors.green),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: FoodHelperColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _FoodHelperNavBar extends StatelessWidget {
  const _FoodHelperNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FoodHelperNavItem(
              icon: Icons.home_rounded,
              label: 'Dashboard',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
            _FoodHelperNavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Meal Plan',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MealPlanScreen()),
                );
              },
            ),
            const _FoodHelperNavItem(
              icon: Icons.auto_awesome_rounded,
              label: 'Food Help',
              isActive: true,
            ),
            _FoodHelperNavItem(
              icon: Icons.notifications_none_rounded,
              label: 'Reminders',
              hasDot: true,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                );
              },
            ),
            _FoodHelperNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProfileGoalScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodHelperNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasDot;
  final VoidCallback? onTap;

  const _FoodHelperNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.hasDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? FoodHelperColors.green : FoodHelperColors.navGrey;

    return SizedBox(
      width: 70,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 23),
                if (hasDot)
                  Positioned(
                    top: 1,
                    right: -1,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: FoodHelperColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
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

class _HelperTab {
  final String label;
  final IconData icon;

  const _HelperTab(this.label, this.icon);
}

class FoodHelperColors {
  static const page = Color(0xFFFFFFFF);
  static const green = Color(0xFF008A08);
  static const softGreen = Color(0xFFDDFBDD);
  static const blue = Color(0xFF0D80FF);
  static const orange = Color(0xFFFF8724);
  static const textGrey = Color(0xFF777777);
  static const iconGrey = Color(0xFF808080);
  static const navGrey = Color(0xFFC4C4CA);
  static const border = Color(0xFFE1E1E1);

  const FoodHelperColors._();
}
