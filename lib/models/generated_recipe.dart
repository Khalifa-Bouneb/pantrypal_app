class GeneratedRecipe {
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookTimeMinutes;
  final Map<String, double> matchedIngredients; // item name -> quantity used

  GeneratedRecipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cookTimeMinutes,
    required this.matchedIngredients,
  });

  factory GeneratedRecipe.fromJson(Map<String, dynamic> json) {
    Map<String, double> matches = {};
    if (json['usedIngredients'] != null) {
      for (var item in json['usedIngredients']) {
        if (item['name'] != null) {
          matches[item['name']] = (item['amountUsed'] ?? 0).toDouble();
        }
      }
    }

    return GeneratedRecipe(
      title: json['recipeName'] ?? 'Untitled Recipe',
      ingredients: List<String>.from(json['ingredientsList'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      cookTimeMinutes: int.tryParse(json['cookTime']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '30') ?? 30,
      matchedIngredients: matches,
    );
  }
}
