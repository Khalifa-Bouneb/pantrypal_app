class Recipe {
  final String title;
  final String time;
  final String difficulty;
  final List<String> ingredients;

  Recipe({
    required this.title,
    required this.time,
    required this.difficulty,
    required this.ingredients,
  });
}

// Predefined database of recipes
final List<Recipe> allRecipes = [
  Recipe(
    title: 'Tunisian Chakchouka',
    time: '25min',
    difficulty: 'Easy',
    ingredients: ['Eggs', 'Tomatoes', 'Peppers', 'Onion', 'Spices'],
  ),
  Recipe(
    title: 'Mediterranean Salad',
    time: '15min',
    difficulty: 'Easy',
    ingredients: ['Cucumber', 'Tomatoes', 'Olives', 'Feta Cheese'],
  ),
  Recipe(
    title: 'Veggie Stir Fry',
    time: '20min',
    difficulty: 'Medium',
    ingredients: ['Broccoli', 'Carrots', 'Soy Sauce', 'Ginger', 'Rice'],
  ),
  Recipe(
    title: 'Morning Omelette',
    time: '10min',
    difficulty: 'Easy',
    ingredients: ['Eggs', 'Cheese', 'Spinach', 'Butter'],
  ),
  Recipe(
    title: 'Grilled Cheese Sandwich',
    time: '10min',
    difficulty: 'Easy',
    ingredients: ['Bread', 'Cheese', 'Butter'],
  ),
  Recipe(
    title: 'Fruit Salad',
    time: '10min',
    difficulty: 'Easy',
    ingredients: ['Apple', 'Banana', 'Orange', 'Berries'],
  ),
  Recipe(
    title: 'Simple Pasta',
    time: '20min',
    difficulty: 'Easy',
    ingredients: ['Pasta', 'Tomato Sauce', 'Cheese'],
  ),
  Recipe(
    title: 'Chicken Curry',
    time: '45min',
    difficulty: 'Medium',
    ingredients: ['Chicken', 'Curry Paste', 'Coconut Milk', 'Rice'],
  ),
  Recipe(
    title: 'Avocado Toast',
    time: '5min',
    difficulty: 'Easy',
    ingredients: ['Bread', 'Avocado', 'Salt', 'Lemon'],
  ),
  Recipe(
    title: 'Smoothie',
    time: '5min',
    difficulty: 'Easy',
    ingredients: ['Milk', 'Banana', 'Berries', 'Yogurt'],
  ),
];
