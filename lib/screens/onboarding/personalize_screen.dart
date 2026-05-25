import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
import '../auth/auth_common.dart';
import 'activity_level_screen.dart';
import 'weight_goal_screen.dart';

class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  String? gender;
  DateTime? dateOfBirth;
  String? weight;
  String? height;
  String? healthGoal;
  String? country;
  bool isSaving = false;

  String get birthDateLabel {
    final value = dateOfBirth;
    if (value == null) {
      return 'Select your date of birth';
    }

    return '${value.month}/${value.day}/${value.year}';
  }

  Future<void> chooseGender() async {
    final selected = await showOptionsSheet(
      title: 'Gender',
      options: const ['Female', 'Male', 'Other'],
      currentValue: gender,
    );

    if (selected != null) {
      setState(() {
        gender = selected;
      });
    }
  }

  Future<void> chooseDateOfBirth() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        dateOfBirth = selected;
      });
    }
  }

  Future<void> chooseWeight() async {
    final selected = await showNumberDialog(
      title: 'Weight',
      hintText: 'Enter your weight',
      suffix: 'kg',
      initialValue: weight?.replaceAll(' kg', ''),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        weight = '$selected kg';
      });
    }
  }

  Future<void> chooseHeight() async {
    final selected = await showNumberDialog(
      title: 'Height',
      hintText: 'Enter your height',
      suffix: 'cm',
      initialValue: height?.replaceAll(' cm', ''),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        height = '$selected cm';
      });
    }
  }

  Future<void> chooseHealthGoal() async {
    final selected = await showOptionsSheet(
      title: 'Health Goal',
      options: const [
        'Lose Weight',
        'Build Muscle',
        'Sleep Better',
        'Eat Healthier',
        'Stay Active',
      ],
      currentValue: healthGoal,
    );

    if (selected != null) {
      setState(() {
        healthGoal = selected;
      });
    }
  }

  Future<void> chooseCountry() async {
  final selected = await showOptionsSheet(
    title: 'Country',
    options: const [
      'Cambodia',
      'Vietnam',
      'Korea',
      'Japan',
      'United States',
      'Other',
    ],
    currentValue: country,
  );

  if (selected != null) {
    setState(() {
      country = selected;
     });
   }
 }

  Future<String?> showOptionsSheet({
    required String title,
    required List<String> options,
    String? currentValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.38),
      builder: (context) {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...options.map(
                  (option) {
                    final isSelected = currentValue == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(option);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF8EA)
                                : const Color(0xFFF9FBF9),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.textGrey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> showNumberDialog({
    required String title,
    required String hintText,
    required String suffix,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              suffixText: suffix,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  double? _numberFromLabel(String? value, String suffix) {
    final raw = value?.replaceAll(suffix, '').trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }

  Future<void> continueNext() async {
      final isComplete = gender != null &&
      dateOfBirth != null &&
      weight != null &&
      height != null &&
      healthGoal != null &&
      country != null;

    if (!isComplete) {
      showMessage(context, 'Please complete all fields first.');
      return;
    }

    final user = AuthService.instance.currentUser;
    final weightKg = _numberFromLabel(weight, 'kg');
    final heightCm = _numberFromLabel(height, 'cm');
    if (user == null || weightKg == null || heightCm == null) {
      showMessage(context, 'Unable to save your profile right now.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final profile = AppUserProfile(
        uid: user.uid,
        fullName: user.displayName ?? '',
        email: user.email ?? '',
        gender: gender!,
        dateOfBirth: dateOfBirth!,
        weightKg: weightKg,
        heightCm: heightCm,
        healthGoal: healthGoal!,
        targetWeightKg: null,
        activityLevel: null,
        country: country!,
        onboardingComplete: false,
      );
      await UserProfileService.instance.saveProfile(profile);
      if (!mounted) {
        return;
      }

      if (profile.needsWeightGoal) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WeightGoalScreen(profile: profile)),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityLevelScreen(profile: profile),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Unable to save your profile right now.');
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      PreferenceOption(
        icon: Icons.person,
        title: 'Gender',
        subtitle: gender ?? 'Select your gender',
        onTap: chooseGender,
      ),
      PreferenceOption(
        icon: Icons.calendar_month,
        title: 'Date of Birth',
        subtitle: birthDateLabel,
        onTap: chooseDateOfBirth,
      ),
      PreferenceOption(
        icon: Icons.monitor_weight,
        title: 'Weight',
        subtitle: weight ?? 'Enter your weight',
        onTap: chooseWeight,
      ),
      PreferenceOption(
        icon: Icons.insert_chart,
        title: 'Height',
        subtitle: height ?? 'Enter your height',
        onTap: chooseHeight,
      ),
      PreferenceOption(
        icon: Icons.signpost,
        title: 'Health Goal',
        subtitle: healthGoal ?? "What's your main goal?",
        onTap: chooseHealthGoal,
      ),
      PreferenceOption(
        icon: Icons.public,
        title: 'Country',
        subtitle: country ?? 'Select your country',
        onTap: chooseCountry,
      ),
    ];
    return AuthScaffold(
      decorated: false,
      horizontalPadding: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 42),
          const BackArrow(),
          const SizedBox(height: 10),
          const Text(
            'Personalize Your\nExperience',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us a bit about yourself to get\nbetter recommendations',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PreferenceTile(option: option),
            ),
          ),
          const SizedBox(height: 4),
          const SafeDataTile(),
          const Spacer(),
          PrimaryButton(
            label: isSaving ? 'Saving...' : 'Continue',
            onPressed: isSaving ? null : continueNext,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
