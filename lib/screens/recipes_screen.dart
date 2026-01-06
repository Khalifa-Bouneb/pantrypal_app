import 'package:flutter/material.dart';
import 'home_screen.dart' show AppTheme;
import '../services/pantry_service.dart';
import '../models/inventory_item.dart';
import '../models/shopping_item.dart';
import '../models/recipe.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  void _addIngredientsToShoppingList(
    BuildContext context,
    String title,
    List<String> ingredients,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Make $title?'),
        content: Text(
          'Add ${ingredients.length} ingredients to your shopping list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          FilledButton(
            onPressed: () {
              final newItems = ingredients
                  .map(
                    (name) => ShoppingItem(
                      id:
                          DateTime.now().millisecondsSinceEpoch.toString() +
                          name,
                      name: name,
                      quantity: '1',
                    ),
                  )
                  .toList();

              PantryService.instance.addMultipleToShoppingList(newItems);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ingredients added to shopping list!'),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Add to List'),
          ),
        ],
      ),
    );
  }

  // Helper to find matching ingredients
  List<String> _getMatchingIngredients(
    Recipe recipe,
    List<InventoryItem> pantryItems,
  ) {
    final matching = <String>[];
    for (var ingredient in recipe.ingredients) {
      // Simple contains check (case insensitive)
      // Real app would need better fuzzy matching
      final hasItem = pantryItems.any(
        (item) =>
            item.name.toLowerCase().contains(ingredient.toLowerCase()) ||
            ingredient.toLowerCase().contains(item.name.toLowerCase()),
      );
      if (hasItem) {
        matching.add(ingredient);
      }
    }
    return matching;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Smart Suggestions',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<List<InventoryItem>>(
        valueListenable: PantryService.instance.itemsNotifier,
        builder: (context, pantryItems, child) {
          if (pantryItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.kitchen_rounded,
                      size: 64,
                      color: AppTheme.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your pantry is empty',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add items to get personalized recipe suggestions!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter recipes
          final suggestedRecipes = allRecipes.where((recipe) {
            final matching = _getMatchingIngredients(recipe, pantryItems);
            // Show if at least 1 ingredient matches
            return matching.isNotEmpty;
          }).toList();

          // Sort by number of matches (descending)
          suggestedRecipes.sort((a, b) {
            final matchA = _getMatchingIngredients(a, pantryItems).length;
            final matchB = _getMatchingIngredients(b, pantryItems).length;
            return matchB.compareTo(matchA);
          });

          if (suggestedRecipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No matching recipes found',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try adding more diverse ingredients like eggs, vegetables, or pasta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found ${suggestedRecipes.length} recipes',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                            const Text(
                              'Based on what you have in stock.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Recommended for You',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75, // Taller for ingredient stats
                  ),
                  itemCount: suggestedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = suggestedRecipes[index];
                    final matching = _getMatchingIngredients(
                      recipe,
                      pantryItems,
                    );
                    return _buildRecipeCard(context, recipe, matching.length);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, int matchCount) {
    final totalIngredients = recipe.ingredients.length;
    final isFullMatch = matchCount == totalIngredients;

    return GestureDetector(
      onTap: () => _addIngredientsToShoppingList(
        context,
        recipe.title,
        recipe.ingredients,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                    if (isFullMatch)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Cook Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.bar_chart,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have $matchCount/$totalIngredients',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isFullMatch ? AppTheme.primary : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Shop Missing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
