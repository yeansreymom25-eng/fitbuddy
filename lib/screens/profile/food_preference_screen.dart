import 'package:flutter/material.dart';

import '../../services/user_settings_service.dart';

class FoodPreferenceScreen extends StatefulWidget {
  const FoodPreferenceScreen({super.key});

  @override
  State<FoodPreferenceScreen> createState() => _FoodPreferenceScreenState();
}

class _FoodPreferenceScreenState extends State<FoodPreferenceScreen> {
  final _allergyController = TextEditingController();
  final _dislikeController = TextEditingController();
  UserFoodPreferences _preferences = UserFoodPreferences.defaults();
  bool _saving = false;
  bool _controllersSynced = false;

  @override
  void dispose() {
    _allergyController.dispose();
    _dislikeController.dispose();
    super.dispose();
  }

  Future<void> _save(UserFoodPreferences preferences) async {
    setState(() {
      _saving = true;
      _preferences = preferences;
    });
    try {
      await UserSettingsService.instance.saveFoodPreferences(preferences);
      if (mounted) {
        _message('Food preferences saved.');
      }
    } catch (_) {
      if (mounted) {
        _message('Unable to save food preferences right now.');
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
        backgroundColor: _FoodColors.green,
        content:
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodColors.page,
      appBar: AppBar(
        backgroundColor: _FoodColors.page,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Food Preferences',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: StreamBuilder<UserFoodPreferences>(
        stream: UserSettingsService.instance.watchFoodPreferences(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _preferences;
          if (!_saving && snapshot.hasData) {
            _preferences = data;
            if (!_controllersSynced) {
              _allergyController.text = data.allergies.join(', ');
              _dislikeController.text = data.dislikedFoods.join(', ');
              _controllersSynced = true;
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const _IntroCard(
                icon: Icons.restaurant_rounded,
                title: 'Personalize future meal plans',
                text:
                    'These choices are saved to your Firebase profile and used when FitBuddy creates new meal plans.',
              ),
              const SizedBox(height: 16),
              _SectionTitle('Diet style'),
              _ChoiceWrap(
                options: const ['Balanced', 'High Protein', 'Vegetarian'],
                selected: data.dietStyle,
                onSelected: (value) => _save(data.copyWith(dietStyle: value)),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Preferred protein'),
              _ChoiceWrap(
                options: const ['Any', 'Chicken', 'Fish', 'Egg', 'Tofu'],
                selected: data.preferredProtein,
                onSelected: (value) =>
                    _save(data.copyWith(preferredProtein: value)),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Spice level'),
              _ChoiceWrap(
                options: const ['Mild', 'Medium', 'Spicy'],
                selected: data.spiceLevel,
                onSelected: (value) => _save(data.copyWith(spiceLevel: value)),
              ),
              const SizedBox(height: 16),
              _TextSaveCard(
                title: 'Allergies',
                hint: 'Example: peanut, shrimp',
                controller: _allergyController,
                onSave: () => _save(
                  data.copyWith(allergies: _parseTags(_allergyController.text)),
                ),
              ),
              const SizedBox(height: 12),
              _TextSaveCard(
                title: 'Foods to avoid',
                hint: 'Example: pork, mushroom',
                controller: _dislikeController,
                onSave: () => _save(
                  data.copyWith(
                    dislikedFoods: _parseTags(_dislikeController.text),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChoiceWrap({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final active = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: active,
          onSelected: (_) => onSelected(option),
          selectedColor: _FoodColors.softGreen,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: active ? _FoodColors.green : _FoodColors.border,
          ),
          labelStyle: TextStyle(
            color: active ? _FoodColors.green : Colors.black,
            fontWeight: FontWeight.w800,
          ),
        );
      }).toList(),
    );
  }
}

class _TextSaveCard extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onSave;

  const _TextSaveCard({
    required this.title,
    required this.hint,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _FoodColors.surfaceDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF7F9F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _FoodColors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _IntroCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _FoodColors.surfaceDecoration,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _FoodColors.softGreen,
            child: Icon(icon, color: _FoodColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: _FoodColors.textGrey,
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
    );
  }
}

class _FoodColors {
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

  const _FoodColors._();
}
