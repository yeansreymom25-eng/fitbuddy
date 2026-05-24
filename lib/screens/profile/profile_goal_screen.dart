import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../meal/meal_plan_screen.dart';
import '../progress/progress_screen.dart';
import '../reminders/reminders_screen.dart';

class ProfileGoalScreen extends StatefulWidget {
  const ProfileGoalScreen({super.key});

  @override
  State<ProfileGoalScreen> createState() => _ProfileGoalScreenState();
}

class _ProfileGoalScreenState extends State<ProfileGoalScreen> {
  AppUserProfile? _profile;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  final Map<String, String> _values = {
    'Full Name': 'Mey',
    'Email': 'mey123@gmail.com.kh',
    'Date of birth': 'May 15, 2002',
    'Gender': 'Female',
    'Height': '160 cm',
    'Weight': '58 kg',
    'Weight Goal': 'Current 70kg - Target 60kg',
    'Activity level': 'Low activity',
    'Health Goal': 'What is your goal ?',
    'Country': 'Cambodia',
    'Photo Url': '',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserProfileService.instance.getCurrentProfile();
      if (!mounted) {
        return;
      }
      if (profile != null) {
        _applyProfile(profile);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _dateLabel(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  void _applyProfile(AppUserProfile profile) {
    _profile = profile;
    _values
      ..['Full Name'] = profile.fullName.isEmpty ? 'Mey' : profile.fullName
      ..['Email'] = profile.email
      ..['Date of birth'] = _dateLabel(profile.dateOfBirth)
      ..['Gender'] = profile.gender
      ..['Height'] = '${profile.heightCm.toStringAsFixed(0)} cm'
      ..['Weight'] = '${profile.weightKg.toStringAsFixed(0)} kg'
      ..['Weight Goal'] = profile.targetWeightKg == null
          ? profile.healthGoal
          : 'Current ${profile.weightKg.toStringAsFixed(0)}kg - Target ${profile.targetWeightKg!.toStringAsFixed(0)}kg'
      ..['Activity level'] = profile.activityLevel ?? 'Sedentary'
      ..['Health Goal'] = profile.healthGoal
      ..['Country'] = profile.country ?? 'Cambodia'
      ..['Photo Url'] = profile.photoUrl ?? '';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editValue(String label) async {
    if (label == 'Gender') {
      await _editChoice(
        label: label,
        options: const ['Female', 'Male', 'Other'],
        currentValue: _values[label],
      );
      return;
    }
    if (label == 'Activity level') {
      await _editChoice(
        label: label,
        options: const [
          'Sedentary',
          'Lightly Active',
          'Moderately Active',
          'Very Active',
        ],
        currentValue: _values[label],
      );
      return;
    }
    if (label == 'Health Goal') {
      await _editChoice(
        label: label,
        options: const [
          'Lose Weight',
          'Build Muscle',
          'Sleep Better',
          'Eat Healthier',
          'Stay Active',
        ],
        currentValue: _values[label],
      );
      return;
    }
    if (label == 'Country') {
      await _editChoice(
        label: label,
        options: const [
          'Cambodia',
          'Thailand',
          'Vietnam',
          'Korea',
          'Japan',
          'United States',
          'Other',
        ],
        currentValue: _values[label],
      );
      return;
    }
    if (label == 'Date of birth') {
      await _editDateOfBirth();
      return;
    }
    if (label == 'Weight Goal') {
      await _editWeightGoal();
      return;
    }
    if (label == 'Height') {
      await _editNumber(
        label: label,
        suffix: 'cm',
        initialValue: _profile?.heightCm.toStringAsFixed(0) ?? '',
      );
      return;
    }
    if (label == 'Weight') {
      await _editNumber(
        label: label,
        suffix: 'kg',
        initialValue: _profile?.weightKg.toStringAsFixed(0) ?? '',
      );
      return;
    }

    final controller = TextEditingController(text: _values[label] ?? '');
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit $label',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _ProfileColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (value != null && value.trim().isNotEmpty) {
      await _saveEditedValue(label, value.trim());
    }
    controller.dispose();
  }

  Future<void> _editChoice({
    required String label,
    required List<String> options,
    required String? currentValue,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit $label',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                for (final option in options)
                  _ProfileChoiceTile(
                    label: option,
                    selected: option == currentValue,
                    onTap: () => Navigator.pop(context, option),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await _saveEditedValue(label, selected);
    }
  }

  Future<void> _editNumber({
    required String label,
    required String suffix,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final value = await _showProfileTextSheet(
      title: 'Edit $label',
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      suffixText: suffix,
    );
    if (value != null && value.trim().isNotEmpty) {
      await _saveEditedValue(label, value.trim());
    }
    controller.dispose();
  }

  Future<void> _editDateOfBirth() async {
    final profile = _profile;
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: profile?.dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (selected == null || profile == null) {
      return;
    }
    await _saveProfile(
      profile.copyWith(dateOfBirth: selected),
      successMessage: 'Date of birth saved. Recommendations updated.',
    );
  }

  Future<void> _editWeightGoal() async {
    final profile = _profile;
    if (profile == null) {
      _showMessage('Profile is still loading.');
      return;
    }
    if (!profile.needsWeightGoal) {
      _showMessage('Weight goal is only needed for Lose Weight.');
      return;
    }

    final currentController = TextEditingController(
      text: profile.weightKg.toStringAsFixed(0),
    );
    final targetController = TextEditingController(
      text: profile.targetWeightKg?.toStringAsFixed(0) ?? '',
    );

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Weight Goal',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _ProfileNumberField(
                  controller: currentController,
                  label: 'Current Weight',
                  suffix: 'kg',
                ),
                const SizedBox(height: 10),
                _ProfileNumberField(
                  controller: targetController,
                  label: 'Target Weight',
                  suffix: 'kg',
                ),
                const SizedBox(height: 18),
                _ProfileSaveButton(
                  label: 'Save',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      final current = double.tryParse(currentController.text.trim());
      final target = double.tryParse(targetController.text.trim());
      if (current == null || target == null) {
        _showMessage('Please enter valid weight numbers.');
      } else if (target >= current) {
        _showMessage('Target weight should be lower than current weight.');
      } else {
        await _saveProfile(
          profile.copyWith(weightKg: current, targetWeightKg: target),
          successMessage: 'Weight goal saved. Recommendations updated.',
        );
      }
    }

    currentController.dispose();
    targetController.dispose();
  }

  Future<String?> _showProfileTextSheet({
    required String title,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? suffixText,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    suffixText: suffixText,
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileSaveButton(
                  label: 'Save',
                  onPressed: () => Navigator.pop(context, controller.text),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveEditedValue(String label, String value) async {
    final profile = _profile;
    if (profile == null) {
      setState(() => _values[label] = value);
      _showMessage('$label updated locally. Login profile was not loaded.');
      return;
    }

    AppUserProfile updated = profile;
    if (label == 'Full Name') {
      updated = updated.copyWith(fullName: value);
    } else if (label == 'Gender') {
      updated = updated.copyWith(gender: value);
    } else if (label == 'Height') {
      final number = double.tryParse(value.replaceAll('cm', '').trim());
      if (number == null) {
        _showMessage('Please enter height as a number.');
        return;
      }
      updated = updated.copyWith(heightCm: number);
    } else if (label == 'Weight') {
      final number = double.tryParse(value.replaceAll('kg', '').trim());
      if (number == null) {
        _showMessage('Please enter weight as a number.');
        return;
      }
      updated = updated.copyWith(weightKg: number);
    } else if (label == 'Activity level') {
      updated = updated.copyWith(activityLevel: value);
    } else if (label == 'Health Goal') {
      updated = updated.copyWith(
        healthGoal: value,
        clearTargetWeight: value.toLowerCase() != 'lose weight',
      );
    } else if (label == 'Country') {
      updated = updated.copyWith(country: value);
    } else if (label == 'Weight Goal') {
      final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(value);
      final target = match == null ? null : double.tryParse(match.group(1)!);
      updated = updated.copyWith(targetWeightKg: target);
    } else {
      setState(() => _values[label] = value);
      _showMessage('$label updated locally.');
      return;
    }

    await _saveProfile(
      updated,
      successMessage: '$label saved. Recommendations updated.',
      errorMessage: 'Unable to save $label right now.',
    );
  }

  Future<void> _saveProfile(
    AppUserProfile updated, {
    required String successMessage,
    String errorMessage = 'Unable to save profile right now.',
  }) async {
    try {
      await UserProfileService.instance.saveProfile(updated);
      final freshProfile =
          await UserProfileService.instance.getCurrentProfile() ?? updated;
      if (!mounted) {
        return;
      }
      setState(() => _applyProfile(freshProfile));
      _showMessage(successMessage);
    } catch (_) {
      if (mounted) {
        _showMessage(errorMessage);
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_isUploadingPhoto) {
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 82,
      );
      if (picked == null) {
        return;
      }
      setState(() => _isUploadingPhoto = true);
      final bytes = await picked.readAsBytes();
      final url = await UserProfileService.instance.uploadProfilePhoto(
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      setState(() => _values['Photo Url'] = url);
      _showMessage('Profile picture updated.');
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to upload profile picture right now.');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _openNav(int index) {
    if (index == 4) {
      return;
    }
    Widget screen;
    if (index == 0) {
      screen = const DashboardScreen();
    } else if (index == 1) {
      screen = const MealPlanScreen();
    } else if (index == 2) {
      screen = const ProgressScreen();
    } else {
      screen = const RemindersScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content:
              const Text('You can sign in with another account after logout.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await AuthService.instance.signOut();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProfileGoalItem(
        'Weight Goal',
        _values['Weight Goal']!,
        Icons.calendar_today_rounded,
      ),
      _ProfileGoalItem(
        'Activity level',
        _values['Activity level']!,
        Icons.directions_walk_rounded,
      ),
      _ProfileGoalItem('Your Height', _values['Height']!, Icons.trending_up),
      _ProfileGoalItem(
        'Health Goal',
        _values['Health Goal']!,
        Icons.health_and_safety_rounded,
      ),
      _ProfileGoalItem(
        'Country',
        _values['Country']!,
        Icons.public_rounded,
      ),
      _ProfileGoalItem('Gender', _values['Gender']!, Icons.person_rounded),
      _ProfileGoalItem(
        'Date of birth',
        _values['Date of birth']!,
        Icons.calendar_month_rounded,
      ),
      _ProfileGoalItem(
          'Full Name', _values['Full Name']!, Icons.person_rounded),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(onLogout: _logout),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _ProfileColors.green,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                      children: [
                        _PersonalInfoCard(
                          values: _values,
                          onPhotoTap: _uploadPhoto,
                          isUploading: _isUploadingPhoto,
                        ),
                        const SizedBox(height: 14),
                        const _PrivacyNote(),
                        const SizedBox(height: 16),
                        const Text(
                          'Goals and Details',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final item in items)
                          _ProfileGoalRow(
                            item: item,
                            onEdit: () {
                              final label = item.title == 'Your Height'
                                  ? 'Height'
                                  : item.title;
                              _editValue(label);
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ProfileNavBar(onItemTap: _openNav),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileHeader({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile and Goal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Log out',
                onPressed: onLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: _ProfileColors.green,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'Update your information and set your goal',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _ProfileColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  final Map<String, String> values;
  final VoidCallback onPhotoTap;
  final bool isUploading;

  const _PersonalInfoCard({
    required this.values,
    required this.onPhotoTap,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ProfileColors.softGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ProfileColors.green.withValues(alpha: .18)),
      ),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onPhotoTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 43,
                        backgroundColor: _ProfileColors.softGreen,
                        backgroundImage: values['Photo Url']!.isEmpty
                            ? null
                            : NetworkImage(values['Photo Url']!),
                        child: values['Photo Url']!.isEmpty
                            ? const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF202020),
                                size: 58,
                              )
                            : null,
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _ProfileColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: isUploading
                            ? const Padding(
                                padding: EdgeInsets.all(5),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _ProfileColors.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        values['Full Name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        values['Email']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ProfileColors.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoPill(
                    icon: Icons.cake_rounded,
                    label: 'Birth',
                    value: values['Date of birth']!,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoPill(
                    icon: Icons.person_rounded,
                    label: 'Gender',
                    value: values['Gender']!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _InfoPill(
                    icon: Icons.height_rounded,
                    label: 'Height',
                    value: values['Height']!,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoPill(
                    icon: Icons.monitor_weight_rounded,
                    label: 'Weight',
                    value: values['Weight']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Icon(icon, color: _ProfileColors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ProfileColors.textGrey,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: const Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: _ProfileColors.green,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your data is private and secure',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _ProfileColors.textGrey,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? _ProfileColors.softGreen : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _ProfileColors.green : _ProfileColors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color:
                      selected ? _ProfileColors.green : _ProfileColors.textGrey,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;

  const _ProfileNumberField({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ProfileSaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ProfileSaveButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _ProfileColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ProfileGoalRow extends StatelessWidget {
  final _ProfileGoalItem item;
  final VoidCallback onEdit;

  const _ProfileGoalRow({
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ProfileColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _ProfileColors.softGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: _ProfileColors.green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ProfileColors.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 12),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ProfileColors.green,
                side: const BorderSide(color: _ProfileColors.green),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNavBar extends StatelessWidget {
  final ValueChanged<int> onItemTap;

  const _ProfileNavBar({required this.onItemTap});

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
            _ProfileNavItem(
              icon: Icons.home_rounded,
              label: 'Dashboard',
              onTap: () => onItemTap(0),
            ),
            _ProfileNavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Meal Plan',
              onTap: () => onItemTap(1),
            ),
            _ProfileNavItem(
              icon: Icons.auto_awesome_rounded,
              label: 'Food Help',
              onTap: () => onItemTap(2),
            ),
            _ProfileNavItem(
              icon: Icons.notifications_none_rounded,
              label: 'Reminders',
              hasDot: true,
              onTap: () => onItemTap(3),
            ),
            _ProfileNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: true,
              onTap: () => onItemTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasDot;
  final VoidCallback onTap;

  const _ProfileNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _ProfileColors.green : _ProfileColors.navGrey;

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
                        color: _ProfileColors.green,
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

class _ProfileGoalItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ProfileGoalItem(this.title, this.subtitle, this.icon);
}

class _ProfileColors {
  static const green = Color(0xFF008A08);
  static const softGreen = Color(0xFFDDFBDD);
  static const textGrey = Color(0xFF777777);
  static const navGrey = Color(0xFFC4C4CA);
  static const border = Color(0xFFE1E1E1);

  const _ProfileColors._();
}
