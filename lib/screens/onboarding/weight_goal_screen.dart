import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_profile.dart';
import '../../services/user_profile_service.dart';
import 'activity_level_screen.dart';

class WeightGoalScreen extends StatefulWidget {
  final AppUserProfile profile;

  const WeightGoalScreen({
    super.key,
    required this.profile,
  });

  @override
  State<WeightGoalScreen> createState() => _WeightGoalScreenState();
}

class _WeightGoalScreenState extends State<WeightGoalScreen> {
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();
  bool showTip = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    currentWeightController.text = widget.profile.weightKg.toStringAsFixed(0);
  }

  @override
  void dispose() {
    currentWeightController.dispose();
    targetWeightController.dispose();
    super.dispose();
  }

  Future<void> continueNext() async {
    final currentWeight = currentWeightController.text.trim();
    final targetWeight = targetWeightController.text.trim();

    if (currentWeight.isEmpty || targetWeight.isEmpty) {
      _showMessage('Please fill both current and target weight.');
      return;
    }

    final current = double.tryParse(currentWeight);
    final target = double.tryParse(targetWeight);
    if (current == null || target == null) {
      _showMessage('Please enter valid numbers.');
      return;
    }
    if (target >= current) {
      _showMessage('Target weight should be lower for a lose weight goal.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final profile = widget.profile.copyWith(
        weightKg: current,
        targetWeightKg: target,
      );
      await UserProfileService.instance.saveProfile(profile);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ActivityLevelScreen(profile: profile)),
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to save your weight goal right now.');
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _GoalColors.green,
          content: Text(message),
        ),
      );
  }

  Widget _buildWeightField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: _GoalColors.surfaceGreen,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 8),
            child: Icon(icon, color: _GoalColors.green, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 10, top: 8),
            child: Text(
              'Kg',
              style: TextStyle(
                color: _GoalColors.textGrey,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 30,
            minHeight: 24,
          ),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                hint,
                style: const TextStyle(
                  color: _GoalColors.textGrey,
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _GoalColors.softBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _GoalColors.green, width: 1.2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _GoalColors.paleGreen,
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
                              TextSpan(text: "Let's Set Your\n"),
                              TextSpan(
                                text: 'Weight Goal',
                                style: TextStyle(color: _GoalColors.green),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell us your current weight and\nyour target weight.',
                          style: TextStyle(
                            color: _GoalColors.textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              color: _GoalColors.surfaceGreen,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE4F2E4),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/track.png',
                              width: 250,
                              height: 205,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildWeightField(
                          icon: Icons.calendar_today_outlined,
                          label: 'Current Weight',
                          hint: 'Enter your current weight',
                          controller: currentWeightController,
                        ),
                        const SizedBox(height: 12),
                        _buildWeightField(
                          icon: Icons.signpost_outlined,
                          label: 'Target Weight',
                          hint: 'Enter your target weight',
                          controller: targetWeightController,
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () => setState(() => showTip = !showTip),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 61),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDFBDD),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFA9E7A9),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 7),
                                  child: Icon(
                                    Icons.trending_up,
                                    color: _GoalColors.green,
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Goal Tip',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                      if (showTip) ...[
                                        const SizedBox(height: 3),
                                        const Text(
                                          'A realistic goal is 0.5-1kg per week.\nSmall step lead to big changes!',
                                          style: TextStyle(
                                            color: _GoalColors.textGrey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            height: 1.15,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  showTip
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  color: _GoalColors.green,
                                  size: 18,
                                ),
                              ],
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
                              backgroundColor: _GoalColors.green,
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
                        const SizedBox(height: 10),
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

class _GoalColors {
  static const green = Color(0xFF008A08);
  static const paleGreen = Color(0xFFEAF8EA);
  static const surfaceGreen = Color(0xFFF6FCF6);
  static const textGrey = Color(0xFF777777);
  static const softBorder = Color(0xFFE0E8E0);

  const _GoalColors._();
}
