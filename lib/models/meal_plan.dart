class MealPlan {
  final List<MealPlanDay> days;
  final List<String> shoppingList;

  MealPlan({required this.days, required this.shoppingList});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'];
    final shoppingRaw = json['shoppingList'];

    final days = <MealPlanDay>[];
    if (daysRaw is List) {
      for (final d in daysRaw) {
        if (d is Map<String, dynamic>) {
          days.add(MealPlanDay.fromJson(d));
        }
      }
    }

    final shoppingList = <String>[];
    if (shoppingRaw is List) {
      for (final s in shoppingRaw) {
        if (s is String && s.trim().isNotEmpty) {
          shoppingList.add(s.trim());
        }
      }
    }

    return MealPlan(days: days, shoppingList: shoppingList);
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((d) => d.toJson()).toList(),
      'shoppingList': shoppingList,
    };
  }
}

class MealPlanDay {
  final String date;
  final List<MealPlanMeal> meals;

  MealPlanDay({required this.date, required this.meals});

  factory MealPlanDay.fromJson(Map<String, dynamic> json) {
    final date = (json['date'] as String?)?.trim() ?? '';
    final mealsRaw = json['meals'];

    final meals = <MealPlanMeal>[];
    if (mealsRaw is List) {
      for (final m in mealsRaw) {
        if (m is Map<String, dynamic>) {
          meals.add(MealPlanMeal.fromJson(m));
        }
      }
    }

    return MealPlanDay(date: date, meals: meals);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }
}

class MealPlanMeal {
  final String name;
  final String title;
  final List<String> uses;
  final List<String> missing;

  MealPlanMeal({
    required this.name,
    required this.title,
    required this.uses,
    required this.missing,
  });

  factory MealPlanMeal.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';

    final uses = <String>[];
    final usesRaw = json['uses'];
    if (usesRaw is List) {
      for (final u in usesRaw) {
        if (u is String && u.trim().isNotEmpty) uses.add(u.trim());
      }
    }

    final missing = <String>[];
    final missingRaw = json['missing'];
    if (missingRaw is List) {
      for (final m in missingRaw) {
        if (m is String && m.trim().isNotEmpty) missing.add(m.trim());
      }
    }

    return MealPlanMeal(name: name, title: title, uses: uses, missing: missing);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'uses': uses,
      'missing': missing,
    };
  }
}
