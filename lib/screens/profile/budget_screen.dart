import 'package:flutter/material.dart';

import '../../services/user_settings_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();
  UserBudgetSettings _budget = UserBudgetSettings.defaults();
  bool _saving = false;
  bool _controllerSynced = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save(UserBudgetSettings budget) async {
    setState(() {
      _saving = true;
      _budget = budget;
    });
    try {
      await UserSettingsService.instance.saveBudget(budget);
      if (mounted) {
        _message('Budget saved.');
      }
    } catch (_) {
      if (mounted) {
        _message('Unable to save budget right now.');
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
        backgroundColor: _BudgetColors.green,
        content:
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BudgetColors.page,
      appBar: AppBar(
        backgroundColor: _BudgetColors.page,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Budget',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: StreamBuilder<UserBudgetSettings>(
        stream: UserSettingsService.instance.watchBudget(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _budget;
          if (!_saving && snapshot.hasData) {
            _budget = data;
            if (!_controllerSynced) {
              _budgetController.text = data.weeklyBudget.toString();
              _controllerSynced = true;
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Container(
                decoration: _BudgetColors.surfaceDecoration,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: _BudgetColors.softGreen,
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: _BudgetColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan meals within your budget',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data.weeklyBudget} ${data.currency} per week',
                            style: const TextStyle(
                              color: _BudgetColors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: _BudgetColors.surfaceDecoration,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Weekly food budget'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _budgetController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      decoration: InputDecoration(
                        suffixText: data.currency,
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
                        onPressed: () {
                          final value = int.tryParse(
                            _budgetController.text.trim(),
                          );
                          if (value == null || value <= 0) {
                            _message('Please enter a valid budget.');
                            return;
                          }
                          _save(data.copyWith(weeklyBudget: value));
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Save Budget'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _BudgetColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _Label('Currency'),
              _ChoiceWrap(
                options: const ['USD', 'KHR'],
                selected: data.currency,
                onSelected: (value) => _save(data.copyWith(currency: value)),
              ),
              const SizedBox(height: 16),
              const _Label('Shopping style'),
              _ChoiceWrap(
                options: const ['Low Cost', 'Balanced', 'Flexible'],
                selected: data.shoppingStyle,
                onSelected: (value) =>
                    _save(data.copyWith(shoppingStyle: value)),
              ),
              const SizedBox(height: 16),
              const _Label('Cooking time'),
              _ChoiceWrap(
                options: const ['15 min', '30 min', '45 min'],
                selected: data.cookingTime,
                onSelected: (value) => _save(data.copyWith(cookingTime: value)),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final active = option == selected;
          return ChoiceChip(
            label: Text(option),
            selected: active,
            onSelected: (_) => onSelected(option),
            selectedColor: _BudgetColors.softGreen,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: active ? _BudgetColors.green : _BudgetColors.border,
            ),
            labelStyle: TextStyle(
              color: active ? _BudgetColors.green : Colors.black,
              fontWeight: FontWeight.w800,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
    );
  }
}

class _BudgetColors {
  static const page = Color(0xFFFAFCFB);
  static const green = Color(0xFF1F8A5B);
  static const softGreen = Color(0xFFE7F6EE);
  static const border = Color(0xFFE0E5E0);

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

  const _BudgetColors._();
}
