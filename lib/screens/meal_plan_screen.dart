import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../models/shopping_item.dart';
import '../services/llm_service.dart';
import '../services/pantry_service.dart';
import 'home_screen.dart' show AppTheme;
import '../l10n/app_localizations.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _llm = LLMService();
  MealPlan? _plan;
  bool _loading = false;
  String? _error;

  int _days = 3;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plan = PantryService.instance.mealPlan;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
      _plan = null;
    });

    try {
      final pantryItems = PantryService.instance.items;
      if (pantryItems.isEmpty) {
        throw Exception(AppLocalizations.of(context).tr('pantry_empty_add_ingredients'));
      }

      final plan = await _llm.generateMealPlan(
        pantryItems,
        days: _days,
        notes: _notesController.text.trim(),
      );

      await PantryService.instance.saveMealPlan(plan);

      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _addShoppingList(List<String> items) {
    final trimmed = items.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (trimmed.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final newItems = trimmed
        .map(
          (name) => ShoppingItem(
            id: '${now}_$name',
            name: name,
            quantity: '1',
          ),
        )
        .toList();

    PantryService.instance.addMultipleToShoppingList(newItems);
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.tr('meal_plan_added_to_shopping')),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          t.tr('meal_plan_title'),
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(color: AppTheme.primary),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            if (_plan != null) ...[
              const SizedBox(height: 16),
              _buildPlan(_plan!),
              if (_plan!.shoppingList.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _addShoppingList(_plan!.shoppingList),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                    icon: const Icon(Icons.shopping_cart_checkout_rounded),
                    label: Text(t.tr('add_shopping_list')),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.tr('meal_plan_generate_subtitle'),
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _days,
                  decoration: InputDecoration(
                    labelText: t.tr('days'),
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem(value: 3, child: Text(t.tr('x_days').replaceAll('{count}', '3'))),
                    DropdownMenuItem(value: 5, child: Text(t.tr('x_days').replaceAll('{count}', '5'))),
                    DropdownMenuItem(value: 7, child: Text(t.tr('x_days').replaceAll('{count}', '7'))),
                  ],
                  onChanged: (v) => setState(() => _days = v ?? 3),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _generate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t.tr('generate')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: t.tr('notes_optional'),
              hintText: t.tr('notes_hint'),
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(MealPlan plan) {
    final t = AppLocalizations.of(context);

    return Column(
      children: plan.days.map((day) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day.date.isEmpty ? t.tr('day') : day.date,
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...day.meals.map((meal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${meal.name}: ${meal.title}',
                        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600),
                      ),
                      if (meal.uses.isNotEmpty)
                        Text(
                          '${t.tr('uses')}: ${meal.uses.join(', ')}',
                          style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                        ),
                      if (meal.missing.isNotEmpty)
                        Text(
                          '${t.tr('missing')}: ${meal.missing.join(', ')}',
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}
