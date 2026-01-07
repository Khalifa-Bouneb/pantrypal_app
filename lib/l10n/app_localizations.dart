import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  static const supportedLocales = <Locale>[Locale('en'), Locale('fr')];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String tr(String key) {
    final lang = locale.languageCode;
    return (_localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key).toString();
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'home': 'Home',
      'pantry': 'Pantry',
      'scan': 'Scan',
      'cooking': 'Cooking',
      'profile': 'Profile',

      // Common actions
      'save': 'Save',
      'cancel': 'Cancel',
      'sign_out': 'Sign Out',
      'loading': 'Loading...',

      // Home / dashboard
      'sign_out_title': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to end your session?',
      'good_morning': 'Good Morning,',
      'good_evening': 'Good Evening,',
      'search_pantry_hint': 'Search your pantry...',
      'at_a_glance': 'At a Glance',
      'quick_actions': 'Quick Actions',
      'my_pantry': 'My Pantry',
      'manage_inventory': 'Manage inventory',
      'add_items': 'Add Items',
      'scan_or_type': 'Scan or type',
      'shopping_list': 'Shopping List',
      'plan_purchases': 'Plan purchases',
      'recipes': 'Recipes',
      'what_to_cook': 'What to cook?',
      'action_needed': 'Action Needed',
      'items_expiring_soon': 'You have {count} item{plural} expiring soon.',
      'ai_chef': 'AI Chef',
      'ask': 'Ask',
      'waste_saver': 'Waste Saver',
      'waste_saver_subtitle': '{count} item{plural} expiring in the next 7 days',
      'total_items': 'Total Items',
      'expiring': 'Expiring',
      'low_stock': 'Low Stock',

      // Pantry
      'all_items': 'All Items',
      'vegetables': 'Vegetables',
      'fruits': 'Fruits',
      'protein': 'Protein',
      'pantry_empty': 'Your pantry is empty',
      'pantry_empty_add_ingredients': 'Pantry is empty! Add ingredients first.',
      'no_items_category': 'No items in this category',
      'removed': 'removed',
      'expired': 'Expired',
      'expires_today': 'Expires today',
      'expires_in_days': 'Expires in {days} days',

      // Add items
      'add_items_title': 'Add Items',
      'how_add_items': 'How would you like to add items?',
      'choose_method': 'Choose the method that works best for you.',
      'scan_receipt': 'Scan Receipt',
      'ai_powered_inventory': 'AI-powered instant inventory update',
      'ai_powered_tag': 'AI Powered',
      'receipt_scanning_soon': 'Receipt Scanning coming soon!',
      'scan_barcode': 'Scan Barcode',
      'quick_product_id': 'Quick product identification',
      'add_manually': 'Add Manually',
      'type_one_by_one': 'Type items one by one',
      'added_items_to_pantry': 'Added {count} item{plural} to pantry!',
      'pro_tip': 'Pro tip: Scan your receipt right after shopping to automatically update your pantry!',

      // Shopping list
      'add_to_shopping_list': 'Add to Shopping List',
      'shopping_list_empty': 'Your list is empty',
      'to_buy': 'To Buy',
      'completed': 'Completed',
      'add_item': 'Add Item',
      'example_milk_bread': 'e.g., Milk, Bread',
      'moved_items_to_pantry': 'Moved items to Pantry!',
      'done_shopping': 'Done Shopping ({count})',

      // Recipes
      'smart_suggestions': 'Smart Suggestions',
      'meal_plan': 'Meal Plan',
      'add_items_for_recipes': 'Add items to get personalized recipe suggestions!',
      'no_matching_recipes': 'No matching recipes found',
      'try_adding_more': 'Try adding more diverse ingredients like eggs, vegetables, or pasta.',
      'make_recipe': 'Make {title}?',
      'add_ingredients_question': 'Add {count} ingredients to your shopping list?',
      'ingredients_added': 'Ingredients added to shopping list!',
      'add_to_list': 'Add to List',

      // Profile / settings
      'account_settings': 'Account Settings',
      'personal_information': 'Personal Information',
      'security_password': 'Security & Password',
      'ai_model_settings': 'AI Model Settings',
      'notifications': 'Notifications',
      'preferences': 'Preferences',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full Name',
      'phone': 'Phone',
      'country': 'Country',
      'city': 'City',
      'address': 'Address',
      'household_size': 'Household Size',
      'dietary_preferences': 'Dietary Preferences',
      'allergies': 'Allergies',
      'email': 'Email',
      'security': 'Security',
      'reset_password': 'Reset Password',
      'change_password': 'Change Password',
      'verify_email': 'Verify Email',
      'send_link': 'Send Link',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'update_password': 'Update Password',
      'notification_settings': 'Notification Settings',
      'expiry_alerts': 'Expiry Alerts',
      'low_stock_alerts': 'Low Stock Alerts',
      'lead_time_days': 'Lead time (days)',

      // Auth
      'sign_in': 'Sign In',
      'welcome_to_pantrypal': 'Welcome to PantryPal',
      'sign_in_subtitle': 'Sign in to manage your pantry',
      'create_new_account': 'Create New Account',
      'must_create_account': 'You must create an account and sign in\nto access PantryPal',
      'email_required': 'Email is required',
      'enter_valid_email': 'Enter a valid email address',
      'enter_email': 'Enter your email',
      'password': 'Password',
      'password_required': 'Password is required',
      'password_min_6': 'Password must be at least 6 characters',
      'enter_password': 'Enter your password',
      'sign_in_failed': 'Sign in failed. Please try again.',
      'signed_in_success': '✓ Signed in successfully!',
      'account_created_success': '✓ Account created successfully! Please sign in.',
      'create_account': 'Create Account',
      'join_pantrypal': 'Join PantryPal',
      'create_account_subtitle': 'Create an account to get started',
      'enter_name': 'Enter your name',
      'name_required': 'Name is required',
      'name_min_2': 'Name must be at least 2 characters',
      'password_letter_required': 'Password must contain at least one letter',
      'confirm_password': 'Confirm Password',
      'confirm_password_required': 'Please confirm your password',
      'confirm_password_hint': 'Confirm your password',
      'passwords_do_not_match': 'Passwords do not match',
      'password_requirements': 'Password Requirements:',
      'requirement_at_least_6': 'At least 6 characters',
      'requirement_contains_letters': 'Contains letters',
      'requirement_passwords_match': 'Passwords must match',
      'account_creation_failed': 'Account creation failed. Please try again.',

      // Meal plan screen
      'meal_plan_title': 'Meal Plan',
      'meal_plan_generate_subtitle': 'Generate a meal plan using your pantry',
      'days': 'Days',
      'x_days': '{count} days',
      'generate': 'Generate',
      'notes_optional': 'Notes (optional)',
      'notes_hint': 'e.g., quick meals, high-protein, kid friendly',
      'day': 'Day',
      'uses': 'Uses',
      'missing': 'Missing',
      'add_shopping_list': 'Add Shopping List',
      'meal_plan_added_to_shopping': 'Meal plan items added to shopping list!',

      // Recipe generation (AI Chef)
      'lets_cook': "Let's cook something!",
      'recipe_preferences_subtitle': "Tell me your preferences and I'll create a recipe using your pantry items.",
      'dietary_preference': 'Dietary Preference',
      'meal_type': 'Meal Type',
      'other_requests': 'Other Requests (e.g., "Make it spicy", "Kids friendly")',
      'other_requests_hint': 'Any special requests...',
      'generate_recipe': 'Generate Recipe',
      'creating_masterpiece': 'Creating your masterpiece...',
      'analyzing_ingredients': 'Analyzing ingredients and preferences',
      'ingredients': 'Ingredients',
      'instructions': 'Instructions',
      'try_again': 'Try Again',
      'i_cooked_this': 'I Cooked This!',
      'cook_this_recipe': 'Cook this recipe?',
      'deduct_ingredients_notice': 'The following ingredients will be deducted from your pantry:',
      'cook_and_deduct': 'Cook & Deduct',
      'bon_appetit_updated': 'Bon Appétit! Pantry updated.',

      // Diet options (display)
      'diet_none': 'None',
      'diet_vegan': 'Vegan',
      'diet_vegetarian': 'Vegetarian',
      'diet_gluten_free': 'Gluten-Free',
      'diet_keto': 'Keto',

      // Meal types (display)
      'meal_any': 'Any',
      'meal_breakfast': 'Breakfast',
      'meal_lunch': 'Lunch',
      'meal_dinner': 'Dinner',
      'meal_snack': 'Snack',

      // Receipt scanning
      'scan_receipt_title': 'Scan Receipt',
      'receipt_error_accessing_camera': 'Error accessing camera: {error}',
      'receipt_processing': 'Processing receipt...\n🤖 AI is analyzing your items',
      'receipt_web_preview_note': '(Web preview - using demo data)',
      'receipt_error_processing': 'Error processing receipt',
      'receipt_ai_requires_mobile': 'AI scanning requires mobile or desktop app.',
      'receipt_web_preview_uses_demo': 'Web preview uses demo data.',
      'receipt_run_on_mobile_for_real': 'Run on Android/iOS for real AI scanning!',
      'receipt_error_generic': 'Error: {error}',

      // Receipt review
      'review_items': 'Review Items',
      'found_x_items': 'Found {count} item{plural}',
      'no_items_to_add': 'No items to add',
      'add_x_items': 'Add {count} Item{plural}',
      'added_x_items_to_pantry': 'Added {count} item{plural} to your pantry!',
      'expires': 'Expires',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'in_x_days': 'in {days} days',

      // Barcode scanner
      'product_not_found': 'Product not found: {code}',
      'error_with_details': 'Error: {error}',
      'looking_up_product': 'Looking up product...',
      'point_camera_at_barcode': 'Point camera at barcode or QR code',

      // Manual add
      'manual_add_title': 'Add Manually',
      'item_details': 'Item Details',
      'item_name': 'Item Name',
      'required': 'Required',
      'invalid': 'Invalid',
      'category': 'Category',
      'quantity_and_expiry': 'Quantity & Expiry',
      'qty': 'Qty',
      'unit': 'Unit',
      'expiry_date': 'Expiry Date',
      'select_date': 'Select Date',
      'add_to_pantry': 'Add to Pantry',
      'category_produce': 'Produce',
      'category_dairy': 'Dairy',
      'category_meat': 'Meat',
      'category_bakery': 'Bakery',
      'category_pantry_staples': 'Pantry Staples',
      'category_frozen': 'Frozen',
      'category_beverages': 'Beverages',
      'category_snacks': 'Snacks',
      'category_other': 'Other',

      // Chat
      'assistant_title': 'PantryPal Assistant',
      'assistant_greeting': "Hello! I'm PantryPal. How can I help you with your kitchen today?",
      'assistant_error': 'Sorry, I encountered an error. Please try again.',
      'assistant_hint': 'Ask about recipes, tips...',
    },
    'fr': {
      // Navigation
      'home': 'Accueil',
      'pantry': 'Garde-manger',
      'scan': 'Scanner',
      'cooking': 'Cuisine',
      'profile': 'Profil',

      // Common actions
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'sign_out': 'Déconnexion',
      'loading': 'Chargement...',

      // Home / dashboard
      'sign_out_title': 'Déconnexion',
      'sign_out_confirm': 'Voulez-vous vraiment terminer votre session ?',
      'good_morning': 'Bonjour,',
      'good_evening': 'Bonsoir,',
      'search_pantry_hint': 'Rechercher dans votre garde-manger...',
      'at_a_glance': "En un coup d'œil",
      'quick_actions': 'Actions rapides',
      'my_pantry': 'Mon garde-manger',
      'manage_inventory': "Gérer l'inventaire",
      'add_items': 'Ajouter des articles',
      'scan_or_type': 'Scanner ou saisir',
      'shopping_list': 'Liste de courses',
      'plan_purchases': 'Planifier les achats',
      'recipes': 'Recettes',
      'what_to_cook': 'Que cuisiner ?',
      'action_needed': 'Action requise',
      'items_expiring_soon': 'Vous avez {count} article{plural} qui expire bientôt.',
      'ai_chef': 'Chef IA',
      'ask': 'Demander',
      'waste_saver': 'Anti-gaspillage',
      'waste_saver_subtitle': '{count} article{plural} expirant dans les 7 prochains jours',
      'total_items': 'Articles',
      'expiring': 'Expire',
      'low_stock': 'Stock bas',

      // Pantry
      'all_items': 'Tous',
      'vegetables': 'Légumes',
      'fruits': 'Fruits',
      'protein': 'Protéines',
      'pantry_empty': 'Votre garde-manger est vide',
      'pantry_empty_add_ingredients': "Votre garde-manger est vide ! Ajoutez d'abord des ingrédients.",
      'no_items_category': 'Aucun article dans cette catégorie',
      'removed': 'supprimé',
      'expired': 'Expiré',
      'expires_today': "Expire aujourd'hui",
      'expires_in_days': 'Expire dans {days} jours',

      // Add items
      'add_items_title': 'Ajouter des articles',
      'how_add_items': 'Comment souhaitez-vous ajouter des articles ?',
      'choose_method': 'Choisissez la méthode qui vous convient.',
      'scan_receipt': 'Scanner le reçu',
      'ai_powered_inventory': "Mise à jour instantanée de l'inventaire par IA",
      'ai_powered_tag': 'IA',
      'receipt_scanning_soon': 'Le scan de reçu arrive bientôt !',
      'scan_barcode': 'Scanner le code-barres',
      'quick_product_id': 'Identification rapide du produit',
      'add_manually': 'Ajouter manuellement',
      'type_one_by_one': 'Saisir les articles un par un',
      'added_items_to_pantry': '{count} article{plural} ajouté au garde-manger !',
      'pro_tip': "Astuce : scannez votre reçu juste après les courses pour mettre à jour automatiquement votre garde-manger !",

      // Shopping list
      'add_to_shopping_list': 'Ajouter à la liste de courses',
      'shopping_list_empty': 'Votre liste est vide',
      'to_buy': 'À acheter',
      'completed': 'Terminé',
      'add_item': 'Ajouter',
      'example_milk_bread': 'ex : lait, pain',
      'moved_items_to_pantry': 'Articles déplacés vers le garde-manger !',
      'done_shopping': 'Courses terminées ({count})',

      // Recipes
      'smart_suggestions': 'Suggestions intelligentes',
      'meal_plan': 'Plan de repas',
      'add_items_for_recipes': "Ajoutez des articles pour obtenir des suggestions de recettes personnalisées !",
      'no_matching_recipes': 'Aucune recette correspondante',
      'try_adding_more': "Essayez d'ajouter des ingrédients plus variés comme des œufs, des légumes ou des pâtes.",
      'make_recipe': 'Préparer {title} ?',
      'add_ingredients_question': 'Ajouter {count} ingrédients à votre liste de courses ?',
      'ingredients_added': 'Ingrédients ajoutés à la liste de courses !',
      'add_to_list': 'Ajouter à la liste',

      // Profile / settings
      'account_settings': 'Paramètres du compte',
      'personal_information': 'Informations personnelles',
      'security_password': 'Sécurité & mot de passe',
      'ai_model_settings': 'Paramètres du modèle IA',
      'notifications': 'Notifications',
      'preferences': 'Préférences',
      'language': 'Langue',
      'dark_mode': 'Mode sombre',
      'edit_profile': 'Modifier le profil',
      'full_name': 'Nom complet',
      'phone': 'Téléphone',
      'country': 'Pays',
      'city': 'Ville',
      'address': 'Adresse',
      'household_size': 'Taille du foyer',
      'dietary_preferences': 'Préférences alimentaires',
      'allergies': 'Allergies',
      'email': 'E-mail',
      'security': 'Sécurité',
      'reset_password': 'Réinitialiser le mot de passe',
      'change_password': 'Changer le mot de passe',
      'verify_email': "Vérifier l'e-mail",
      'send_link': 'Envoyer le lien',
      'current_password': 'Mot de passe actuel',
      'new_password': 'Nouveau mot de passe',
      'confirm_new_password': 'Confirmer le nouveau mot de passe',
      'update_password': 'Mettre à jour',
      'notification_settings': 'Paramètres de notification',
      'expiry_alerts': "Alertes d'expiration",
      'low_stock_alerts': 'Alertes de stock bas',
      'lead_time_days': 'Délai (jours)',

      // Auth
      'sign_in': 'Connexion',
      'welcome_to_pantrypal': 'Bienvenue sur PantryPal',
      'sign_in_subtitle': 'Connectez-vous pour gérer votre garde-manger',
      'create_new_account': 'Créer un nouveau compte',
      'must_create_account': 'Vous devez créer un compte et vous connecter\npour accéder à PantryPal',
      'email_required': "L'e-mail est requis",
      'enter_valid_email': 'Saisissez une adresse e-mail valide',
      'enter_email': 'Saisissez votre e-mail',
      'password': 'Mot de passe',
      'password_required': 'Le mot de passe est requis',
      'password_min_6': 'Le mot de passe doit contenir au moins 6 caractères',
      'enter_password': 'Saisissez votre mot de passe',
      'sign_in_failed': 'Échec de la connexion. Veuillez réessayer.',
      'signed_in_success': '✓ Connexion réussie !',
      'account_created_success': '✓ Compte créé avec succès ! Connectez-vous.',
      'create_account': 'Créer un compte',
      'join_pantrypal': 'Rejoindre PantryPal',
      'create_account_subtitle': 'Créez un compte pour commencer',
      'enter_name': 'Saisissez votre nom',
      'name_required': 'Le nom est requis',
      'name_min_2': 'Le nom doit contenir au moins 2 caractères',
      'password_letter_required': 'Le mot de passe doit contenir au moins une lettre',
      'confirm_password': 'Confirmer le mot de passe',
      'confirm_password_required': 'Veuillez confirmer votre mot de passe',
      'confirm_password_hint': 'Confirmez votre mot de passe',
      'passwords_do_not_match': 'Les mots de passe ne correspondent pas',
      'password_requirements': 'Exigences du mot de passe :',
      'requirement_at_least_6': 'Au moins 6 caractères',
      'requirement_contains_letters': 'Contient des lettres',
      'requirement_passwords_match': 'Les mots de passe doivent correspondre',
      'account_creation_failed': 'Échec de la création du compte. Veuillez réessayer.',

      // Meal plan screen
      'meal_plan_title': 'Plan de repas',
      'meal_plan_generate_subtitle': 'Générez un plan de repas avec votre garde-manger',
      'days': 'Jours',
      'x_days': '{count} jours',
      'generate': 'Générer',
      'notes_optional': 'Notes (optionnel)',
      'notes_hint': 'ex : repas rapides, riche en protéines, adapté aux enfants',
      'day': 'Jour',
      'uses': 'Utilise',
      'missing': 'Manque',
      'add_shopping_list': 'Ajouter la liste de courses',
      'meal_plan_added_to_shopping': 'Articles du plan de repas ajoutés à la liste de courses !',

      // Recipe generation (AI Chef)
      'lets_cook': 'On cuisine quelque chose !',
      'recipe_preferences_subtitle': "Dites-moi vos préférences et je créerai une recette avec les articles de votre garde-manger.",
      'dietary_preference': 'Préférence alimentaire',
      'meal_type': 'Type de repas',
      'other_requests': 'Autres demandes (ex : "Épicé", "Pour les enfants")',
      'other_requests_hint': 'Des demandes particulières...',
      'generate_recipe': 'Générer une recette',
      'creating_masterpiece': "Création de votre chef-d'œuvre...",
      'analyzing_ingredients': 'Analyse des ingrédients et des préférences',
      'ingredients': 'Ingrédients',
      'instructions': 'Instructions',
      'try_again': 'Réessayer',
      'i_cooked_this': "Je l'ai cuisinée !",
      'cook_this_recipe': 'Cuisiner cette recette ?',
      'deduct_ingredients_notice': 'Les ingrédients suivants seront déduits de votre garde-manger :',
      'cook_and_deduct': 'Cuisiner et déduire',
      'bon_appetit_updated': 'Bon appétit ! Garde-manger mis à jour.',

      // Diet options (display)
      'diet_none': 'Aucune',
      'diet_vegan': 'Végane',
      'diet_vegetarian': 'Végétarienne',
      'diet_gluten_free': 'Sans gluten',
      'diet_keto': 'Keto',

      // Meal types (display)
      'meal_any': 'Tout',
      'meal_breakfast': 'Petit-déjeuner',
      'meal_lunch': 'Déjeuner',
      'meal_dinner': 'Dîner',
      'meal_snack': 'Collation',

      // Receipt scanning
      'scan_receipt_title': 'Scanner le reçu',
      'receipt_error_accessing_camera': "Erreur d'accès à la caméra : {error}",
      'receipt_processing': "Traitement du reçu...\n🤖 L'IA analyse vos articles",
      'receipt_web_preview_note': '(Aperçu Web — données de démonstration)',
      'receipt_error_processing': 'Erreur lors du traitement du reçu',
      'receipt_ai_requires_mobile': 'Le scan IA nécessite une application mobile ou desktop.',
      'receipt_web_preview_uses_demo': "L'aperçu Web utilise des données de démonstration.",
      'receipt_run_on_mobile_for_real': 'Exécutez sur Android/iOS pour un vrai scan IA !',
      'receipt_error_generic': 'Erreur : {error}',

      // Receipt review
      'review_items': 'Vérifier les articles',
      'found_x_items': '{count} article{plural} trouvé{plural}',
      'no_items_to_add': 'Aucun article à ajouter',
      'add_x_items': 'Ajouter {count} article{plural}',
      'added_x_items_to_pantry': '{count} article{plural} ajouté au garde-manger !',
      'expires': 'Expire',
      'today': "Aujourd'hui",
      'tomorrow': 'Demain',
      'in_x_days': 'dans {days} jours',

      // Barcode scanner
      'product_not_found': 'Produit introuvable : {code}',
      'error_with_details': 'Erreur : {error}',
      'looking_up_product': 'Recherche du produit...',
      'point_camera_at_barcode': 'Placez la caméra sur le code-barres ou le QR code',

      // Manual add
      'manual_add_title': 'Ajouter manuellement',
      'item_details': "Détails de l'article",
      'item_name': "Nom de l'article",
      'required': 'Requis',
      'invalid': 'Invalide',
      'category': 'Catégorie',
      'quantity_and_expiry': 'Quantité et expiration',
      'qty': 'Qté',
      'unit': 'Unité',
      'expiry_date': "Date d'expiration",
      'select_date': 'Sélectionner une date',
      'add_to_pantry': 'Ajouter au garde-manger',
      'category_produce': 'Produits frais',
      'category_dairy': 'Produits laitiers',
      'category_meat': 'Viande',
      'category_bakery': 'Boulangerie',
      'category_pantry_staples': 'Épicerie',
      'category_frozen': 'Surgelés',
      'category_beverages': 'Boissons',
      'category_snacks': 'Snacks',
      'category_other': 'Autre',

      // Chat
      'assistant_title': 'Assistant PantryPal',
      'assistant_greeting': "Bonjour ! Je suis PantryPal. Comment puis-je vous aider dans votre cuisine aujourd'hui ?",
      'assistant_error': 'Désolé, une erreur est survenue. Veuillez réessayer.',
      'assistant_hint': 'Demandez des recettes, des conseils...',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
