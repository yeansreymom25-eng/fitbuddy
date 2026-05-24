import 'package:flutter/material.dart';

import '../../models/app_reminder.dart';
import '../../services/reminder_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../meal/meal_plan_screen.dart';
import '../profile/profile_goal_screen.dart';
import '../progress/progress_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  int _selectedFilter = 0;
  late final Stream<List<AppReminder>> _reminderStream;

  static const _filters = [
    _ReminderFilter('All', Icons.notifications_active_rounded),
    _ReminderFilter('Nutrition', Icons.restaurant_rounded),
    _ReminderFilter('Activity', Icons.favorite_rounded),
    _ReminderFilter('Sleep', Icons.bedtime_rounded),
    _ReminderFilter('Water', Icons.water_drop_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _reminderStream = ReminderService.instance.watchReminders();
    _seedDefaultReminders();
  }

  Future<void> _seedDefaultReminders() async {
    try {
      await ReminderService.instance.ensureDefaultReminders();
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to prepare reminders right now.');
      }
    }
  }

  List<AppReminder> _visibleReminders(List<AppReminder> reminders) {
    final filter = _filters[_selectedFilter].label;
    if (filter == 'All') {
      return reminders;
    }
    return reminders.where((item) => item.category == filter).toList();
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

  Future<void> _addReminder() async {
    await _openReminderEditor();
  }

  Future<void> _editReminder(AppReminder reminder) async {
    await _openReminderEditor(reminder: reminder);
  }

  Future<void> _openReminderEditor({AppReminder? reminder}) async {
    final titleController = TextEditingController(text: reminder?.title ?? '');
    final noteController = TextEditingController(text: reminder?.note ?? '');
    final timeController =
        TextEditingController(text: reminder?.time ?? '7 AM');
    var category = reminder?.category ?? 'Water';
    final isEditing = reminder != null;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      isEditing ? 'Edit Reminder' : 'Add Reminder',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReminderTextField(
                      controller: titleController,
                      label: 'Title',
                      hint: 'Drink Water',
                    ),
                    const SizedBox(height: 10),
                    _ReminderTextField(
                      controller: noteController,
                      label: 'Note',
                      hint: 'Drink a glass of water',
                    ),
                    const SizedBox(height: 10),
                    _ReminderTextField(
                      controller: timeController,
                      label: 'Time',
                      hint: '8 AM',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final value in [
                          'Water',
                          'Nutrition',
                          'Activity',
                          'Sleep'
                        ])
                          ChoiceChip(
                            label: Text(value),
                            selected: category == value,
                            onSelected: (_) =>
                                setSheetState(() => category = value),
                            selectedColor: _ReminderColors.softGreen,
                            labelStyle: TextStyle(
                              color: category == value
                                  ? _ReminderColors.green
                                  : _ReminderColors.textGrey,
                              fontWeight: FontWeight.w800,
                            ),
                            side: BorderSide.none,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _ReminderColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Reminder',
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
      },
    );

    if (saved == true) {
      final title = titleController.text.trim().isEmpty
          ? 'New Reminder'
          : titleController.text.trim();
      final note = noteController.text.trim().isEmpty
          ? 'Stay on track with your goal'
          : noteController.text.trim();
      try {
        final updated = AppReminder(
          id: '',
          title: title,
          note: note,
          time: timeController.text.trim().isEmpty
              ? '7 AM'
              : timeController.text.trim(),
          category: category,
          enabled: reminder?.enabled ?? true,
          repeat: reminder?.repeat ?? 'Daily',
        );
        if (isEditing) {
          await ReminderService.instance.updateReminder(
            updated.copyWith(id: reminder.id),
          );
        } else {
          await ReminderService.instance.createReminder(updated);
        }
        if (mounted) {
          _showMessage(isEditing ? 'Reminder updated.' : 'Reminder saved.');
        }
      } catch (_) {
        if (mounted) {
          _showMessage('Unable to save reminder right now.');
        }
      }
    }

    titleController.dispose();
    noteController.dispose();
    timeController.dispose();
  }

  Future<void> _toggleReminder(AppReminder reminder, bool value) async {
    try {
      await ReminderService.instance.setEnabled(reminder.id, value);
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to update reminder right now.');
      }
    }
  }

  Future<void> _deleteReminder(AppReminder reminder) async {
    try {
      await ReminderService.instance.deleteReminder(reminder.id);
      if (mounted) {
        _showMessage('Reminder deleted.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to delete reminder right now.');
      }
    }
  }

  void _openNav(int index) {
    if (index == 3) {
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
      screen = const ProfileGoalScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ReminderHeader(onAdd: _addReminder),
            _FilterBar(
              filters: _filters,
              selectedIndex: _selectedFilter,
              onChanged: (index) => setState(() => _selectedFilter = index),
            ),
            Expanded(
              child: StreamBuilder<List<AppReminder>>(
                stream: _reminderStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _ReminderColors.green,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const _ReminderStateMessage(
                      icon: Icons.cloud_off_rounded,
                      title: 'Unable to load reminders',
                      message: 'Check Firebase rules and your connection.',
                    );
                  }

                  final reminders = _visibleReminders(snapshot.data ?? []);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
                    children: [
                      const Text(
                        'Upcoming Reminders',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (reminders.isEmpty)
                        const _ReminderStateMessage(
                          icon: Icons.notifications_none_rounded,
                          title: 'No reminders yet',
                          message: 'Add one to keep your routine on track.',
                        )
                      else
                        for (final reminder in reminders)
                          _ReminderRow(
                            reminder: reminder,
                            onChanged: (value) =>
                                _toggleReminder(reminder, value),
                            onDelete: () => _deleteReminder(reminder),
                            onEdit: () => _editReminder(reminder),
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ReminderNavBar(onItemTap: _openNav),
    );
  }
}

class _ReminderHeader extends StatelessWidget {
  final VoidCallback onAdd;

  const _ReminderHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 22, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminders',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Stay on track with timely reminders',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ReminderColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Reminder'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _ReminderColors.green,
              side: const BorderSide(color: _ReminderColors.green),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              minimumSize: const Size(0, 36),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<_ReminderFilter> filters;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _FilterBar({
    required this.filters,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ReminderColors.border),
      ),
      padding: const EdgeInsets.all(7),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? _ReminderColors.softGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filters[i].icon,
                        color: i == selectedIndex
                            ? _ReminderColors.green
                            : _ReminderColors.iconGrey,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          filters[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: i == selectedIndex
                                ? _ReminderColors.green
                                : _ReminderColors.iconGrey,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final AppReminder reminder;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReminderRow({
    required this.reminder,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleForCategory(reminder.category);

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E5),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(right: 18),
        child: const Icon(
          Icons.delete_rounded,
          color: Color(0xFFD62828),
          size: 24,
        ),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete reminder?'),
              content: Text('Delete "${reminder.title}" from your reminders?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: style.color.withValues(alpha: .18),
                child: Icon(style.icon, color: style.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reminder.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ReminderColors.textGrey,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 66,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ReminderColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.repeat,
                      style: const TextStyle(
                        color: _ReminderColors.textGrey,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Reminder actions',
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert_rounded, size: 20),
              ),
              Switch(
                value: reminder.enabled,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: _ReminderColors.green,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD7D7D7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ReminderStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(icon, color: _ReminderColors.green, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ReminderColors.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _ReminderTextField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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

class _ReminderNavBar extends StatelessWidget {
  final ValueChanged<int> onItemTap;

  const _ReminderNavBar({required this.onItemTap});

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
            _ReminderNavItem(
              icon: Icons.home_rounded,
              label: 'Dashboard',
              onTap: () => onItemTap(0),
            ),
            _ReminderNavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Meal Plan',
              onTap: () => onItemTap(1),
            ),
            _ReminderNavItem(
              icon: Icons.auto_awesome_rounded,
              label: 'Food Help',
              onTap: () => onItemTap(2),
            ),
            _ReminderNavItem(
              icon: Icons.notifications_none_rounded,
              label: 'Reminders',
              isActive: true,
              onTap: () => onItemTap(3),
            ),
            _ReminderNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => onItemTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ReminderNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _ReminderColors.green : _ReminderColors.navGrey;

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

_ReminderStyle _styleForCategory(String category) {
  if (category == 'Nutrition') {
    return const _ReminderStyle(
      Icons.restaurant_rounded,
      _ReminderColors.green,
    );
  }
  if (category == 'Activity') {
    return const _ReminderStyle(
      Icons.favorite_rounded,
      _ReminderColors.orange,
    );
  }
  if (category == 'Sleep') {
    return const _ReminderStyle(
      Icons.nightlight_round,
      _ReminderColors.purple,
    );
  }
  return const _ReminderStyle(
    Icons.water_drop_rounded,
    _ReminderColors.blue,
  );
}

class _ReminderFilter {
  final String label;
  final IconData icon;

  const _ReminderFilter(this.label, this.icon);
}

class _ReminderStyle {
  final IconData icon;
  final Color color;

  const _ReminderStyle(this.icon, this.color);
}

class _ReminderColors {
  static const green = Color(0xFF008A08);
  static const softGreen = Color(0xFFDDFBDD);
  static const blue = Color(0xFF149BFF);
  static const orange = Color(0xFFFF8724);
  static const purple = Color(0xFF9C1BA6);
  static const textGrey = Color(0xFF777777);
  static const iconGrey = Color(0xFF808080);
  static const navGrey = Color(0xFFC4C4CA);
  static const border = Color(0xFFE1E1E1);

  const _ReminderColors._();
}
