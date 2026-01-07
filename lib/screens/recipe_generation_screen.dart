import 'package:flutter/material.dart';
import '../models/generated_recipe.dart';
import '../services/llm_service.dart';
import '../services/pantry_service.dart';
import 'home_screen.dart' show AppTheme;
import '../l10n/app_localizations.dart';

class RecipeGenerationScreen extends StatefulWidget {
  const RecipeGenerationScreen({super.key});

  @override
  State<RecipeGenerationScreen> createState() => _RecipeGenerationScreenState();
}

class _RecipeGenerationScreenState extends State<RecipeGenerationScreen> {
  final _llmService = LLMService();
  bool _isLoading = false;
  GeneratedRecipe? _generatedRecipe;
  String? _error;

  // Filters
  // Keep canonical values for LLM, localize display labels separately.
  final List<String> _dietOptions = ['None', 'Vegan', 'Vegetarian', 'Gluten-Free', 'Keto'];
  String _selectedDiet = 'None';
  
  final List<String> _mealTypes = ['Any', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];
  String _selectedMealType = 'Any';
  
  final TextEditingController _preferencesController = TextEditingController();

  static const Map<String, String> _dietLabelKeys = {
    'None': 'diet_none',
    'Vegan': 'diet_vegan',
    'Vegetarian': 'diet_vegetarian',
    'Gluten-Free': 'diet_gluten_free',
    'Keto': 'diet_keto',
  };

  static const Map<String, String> _mealTypeLabelKeys = {
    'Any': 'meal_any',
    'Breakfast': 'meal_breakfast',
    'Lunch': 'meal_lunch',
    'Dinner': 'meal_dinner',
    'Snack': 'meal_snack',
  };

  @override
  void dispose() {
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _generateRecipe() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _generatedRecipe = null;
    });

    try {
      final pantryItems = PantryService.instance.items;
      if (pantryItems.isEmpty) {
        throw Exception(AppLocalizations.of(context).tr('pantry_empty_add_ingredients'));
      }

      final recipe = await _llmService.generateRecipe(
        pantryItems,
        _selectedDiet == 'None' ? [] : [_selectedDiet],
        _selectedMealType,
        _preferencesController.text,
      );

      if (!mounted) return;
      setState(() {
        _generatedRecipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _cookNow() async {
    if (_generatedRecipe == null) return;

    final t = AppLocalizations.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.tr('cook_this_recipe')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.tr('deduct_ingredients_notice')),
            const SizedBox(height: 12),
            ..._generatedRecipe!.matchedIngredients.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('• ${e.key}'),
                  Text('-${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.tr('cook_and_deduct')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Deduct items
      final pantryItems = PantryService.instance.items;
      
      for (var entry in _generatedRecipe!.matchedIngredients.entries) {
        final itemName = entry.key;
        final deductedAmount = entry.value;

        try {
          // Find item (case insensitive)
          final item = pantryItems.firstWhere(
            (i) => i.name.toLowerCase() == itemName.toLowerCase(),
          );
          
          final newQuantity = (item.quantity - deductedAmount).clamp(0.0, 9999.0);
          
          if (newQuantity <= 0) {
            // Remove item if used up
            await PantryService.instance.removeItem(item.id);
          } else {
            // Update quantity
            final updatedItem = item.updateQuantity(newQuantity);
            await PantryService.instance.updateItem(updatedItem);
          }
        } catch (e) {
          print('Item not found or error deducting: $itemName');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.tr('bon_appetit_updated'))),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(t.tr('ai_chef'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
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
            if (_generatedRecipe == null && !_isLoading) ...[
              _buildInputSection(),
            ] else if (_isLoading) ...[
              _buildLoadingState(),
            ] else if (_generatedRecipe != null) ...[
              _buildRecipeCard(),
            ],
            
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.tr('lets_cook'),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          t.tr('recipe_preferences_subtitle'),
          style: TextStyle(color: AppTheme.textLight),
        ),
        const SizedBox(height: 24),

        Text(t.tr('dietary_preference'), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _dietOptions.map((diet) {
            final isSelected = _selectedDiet == diet;
            return FilterChip(
              label: Text(t.tr(_dietLabelKeys[diet] ?? diet)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedDiet = diet);
              },
              backgroundColor: AppTheme.surface,
              selectedColor: AppTheme.primaryLight,
              checkmarkColor: AppTheme.primaryDark,
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        Text(t.tr('meal_type'), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _mealTypes.map((type) {
            final isSelected = _selectedMealType == type;
            return FilterChip(
              label: Text(t.tr(_mealTypeLabelKeys[type] ?? type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedMealType = type);
              },
              backgroundColor: AppTheme.surface,
              selectedColor: AppTheme.primaryLight,
              checkmarkColor: AppTheme.primaryDark,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),
        Text(t.tr('other_requests'), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _preferencesController,
          decoration: InputDecoration(
            hintText: t.tr('other_requests_hint'),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _generateRecipe,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.auto_awesome),
            label: Text(t.tr('generate_recipe')),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    final t = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 24),
          Text(
            t.tr('creating_masterpiece'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            t.tr('analyzing_ingredients'),
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard() {
    final t = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _generatedRecipe!.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, size: 16, color: AppTheme.primaryDark),
                        const SizedBox(width: 4),
                        Text(
                          '${_generatedRecipe!.cookTimeMinutes} min',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Text(t.tr('ingredients'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._generatedRecipe!.ingredients.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 20, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(i)),
                  ],
                ),
              )),

              const Divider(height: 48),

              Text(t.tr('instructions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._generatedRecipe!.instructions.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.value, style: const TextStyle(height: 1.5))),
                  ],
                ),
              )),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _generatedRecipe = null);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                  child: Text(t.tr('try_again')),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: _cookNow,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.restaurant_menu),
                  label: Text(t.tr('i_cooked_this')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
