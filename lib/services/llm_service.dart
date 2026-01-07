import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/inventory_item.dart';
import '../models/generated_recipe.dart';
import '../models/meal_plan.dart';
import '../models/grocery_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LLMService {
  static const String _defaultBaseUrl = 'https://api.groq.com/openai/v1';
  // Keep this as a sensible default, but always be ready to auto-fallback if
  // Groq deprecates/renames models.
  static const String _defaultModel = 'llama-3.1-8b-instant';
  
  // Storage keys
  static const String _prefsKeyApiKey = 'llm_api_key';
  static const String _prefsKeyBaseUrl = 'llm_base_url';
  static const String _prefsKeyModel = 'llm_model';

  String? _apiKey;
  String _baseUrl = _defaultBaseUrl;
  String _model = _defaultModel;

  late final Future<void> _configLoaded;

  static final LLMService instance = LLMService._init();

  factory LLMService() => instance;

  LLMService._init() {
    _configLoaded = _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_prefsKeyApiKey);
    _baseUrl = prefs.getString(_prefsKeyBaseUrl) ?? _defaultBaseUrl;
    _model = prefs.getString(_prefsKeyModel) ?? _defaultModel;
  }

  Future<void> _ensureLoaded() => _configLoaded;

  Future<void> saveConfig(String apiKey, {String? baseUrl, String? model}) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyApiKey, apiKey);
    if (baseUrl != null) await prefs.setString(_prefsKeyBaseUrl, baseUrl);
    if (model != null) await prefs.setString(_prefsKeyModel, model);
    
    _apiKey = apiKey;
    if (baseUrl != null) _baseUrl = baseUrl;
    if (model != null) _model = model;
  }

  String get baseUrl => _baseUrl;
  String get model => _model;
  String get apiKey => _apiKey ?? '';

  bool get _isLocalhost {
    final lower = _baseUrl.toLowerCase();
    return lower.contains('localhost') || lower.contains('127.0.0.1');
  }

  bool get _isOllamaLikely {
    if (!_isLocalhost) return false;
    // Default Ollama port.
    return _baseUrl.contains(':11434');
  }

  /// OpenAI-compatible base URL.
  ///
  /// - Groq default already includes `/openai/v1`.
  /// - Ollama OpenAI-compat expects `/v1` (e.g. `http://localhost:11434/v1`).
  String get _openAiBaseUrl {
    final trimmed = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    if (_isOllamaLikely) {
      if (trimmed.endsWith('/v1')) return trimmed;
      if (trimmed.endsWith('/openai/v1')) return trimmed;
      return '$trimmed/v1';
    }
    return trimmed;
  }

  /// Root Ollama URL without `/v1` or `/openai/v1`.
  String get _ollamaRootBaseUrl {
    final trimmed = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    if (trimmed.endsWith('/v1')) return trimmed.substring(0, trimmed.length - 3);
    if (trimmed.endsWith('/openai/v1')) return trimmed.substring(0, trimmed.length - 10);
    return trimmed;
  }

  bool get isConfigured {
    // Ollama local installs typically do not require an API key.
    if (_isOllamaLikely) return true;
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  Future<Map<String, String>> _getHeaders() async {
    await _ensureLoaded();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Only attach Authorization when provided.
    final key = _apiKey;
    if (key != null && key.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${key.trim()}';
    }

    return headers;
  }

  Future<List<String>> listModels() async {
    await _ensureLoaded();
    if (!isConfigured) return const [];

    // 1) Try OpenAI-compatible listing.
    try {
      final uri = Uri.parse('$_openAiBaseUrl/models');
      final response = await http.get(uri, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
        if (data is List) {
          final models = <String>[];
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final id = item['id'];
              if (id is String && id.isNotEmpty) models.add(id);
            }
          }
          return models;
        }
      }
    } catch (_) {
      // continue to Ollama native
    }

    // 2) Ollama native listing.
    if (_isOllamaLikely) {
      try {
        final uri = Uri.parse('$_ollamaRootBaseUrl/api/tags');
        final response = await http.get(uri, headers: await _getHeaders());
        if (response.statusCode != 200) return const [];
        final decoded = jsonDecode(response.body);
        final modelsRaw = decoded is Map<String, dynamic> ? decoded['models'] : null;
        if (modelsRaw is! List) return const [];
        final models = <String>[];
        for (final item in modelsRaw) {
          if (item is Map<String, dynamic>) {
            final name = item['name'];
            if (name is String && name.isNotEmpty) models.add(name);
          }
        }
        return models;
      } catch (_) {
        return const [];
      }
    }

    return const [];
  }

  Future<List<String>> listModelsForConfig({
    required String baseUrl,
    String? apiKey,
  }) async {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return const [];

    final normalized = trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    final lower = normalized.toLowerCase();
    final isLocalhost = lower.contains('localhost') || lower.contains('127.0.0.1');
    final isOllamaLikely = isLocalhost && normalized.contains(':11434');

    String openAiBaseUrl;
    if (isOllamaLikely) {
      if (normalized.endsWith('/v1') || normalized.endsWith('/openai/v1')) {
        openAiBaseUrl = normalized;
      } else {
        openAiBaseUrl = '$normalized/v1';
      }
    } else {
      openAiBaseUrl = normalized;
    }

    String ollamaRootBaseUrl;
    if (normalized.endsWith('/v1')) {
      ollamaRootBaseUrl = normalized.substring(0, normalized.length - 3);
    } else if (normalized.endsWith('/openai/v1')) {
      ollamaRootBaseUrl = normalized.substring(0, normalized.length - 10);
    } else {
      ollamaRootBaseUrl = normalized;
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final key = apiKey?.trim();
    if (key != null && key.isNotEmpty) {
      headers['Authorization'] = 'Bearer $key';
    }

    // 1) OpenAI-compatible listing.
    try {
      final uri = Uri.parse('$openAiBaseUrl/models');
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
        if (data is List) {
          final models = <String>[];
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final id = item['id'];
              if (id is String && id.isNotEmpty) models.add(id);
            }
          }
          return models;
        }
      }
    } catch (_) {
      // continue to Ollama native
    }

    // 2) Ollama native listing.
    if (isOllamaLikely) {
      try {
        final uri = Uri.parse('$ollamaRootBaseUrl/api/tags');
        final response = await http.get(uri, headers: headers);
        if (response.statusCode != 200) return const [];
        final decoded = jsonDecode(response.body);
        final modelsRaw = decoded is Map<String, dynamic> ? decoded['models'] : null;
        if (modelsRaw is! List) return const [];
        final models = <String>[];
        for (final item in modelsRaw) {
          if (item is Map<String, dynamic>) {
            final name = item['name'];
            if (name is String && name.isNotEmpty) models.add(name);
          }
        }
        return models;
      } catch (_) {
        return const [];
      }
    }

    return const [];
  }

  Future<String> _pickFallbackModel() async {
    final models = await listModels();
    if (models.isEmpty) return _defaultModel;

    // Prefer Llama family first, then anything.
    final llama = models.firstWhere(
      (m) => m.toLowerCase().contains('llama'),
      orElse: () => models.first,
    );
    return llama;
  }

  Future<void> _persistModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyModel, model);
    _model = model;
  }

  String _parseOpenAiChatContent(String responseBody) {
    final data = jsonDecode(responseBody);
    final content = data['choices'][0]['message']['content'];
    if (content is String) return content;
    return content?.toString() ?? '';
  }

  Future<http.Response> _ollamaChat({
    required List<Map<String, String>> messages,
    required double temperature,
  }) async {
    final uri = Uri.parse('$_ollamaRootBaseUrl/api/chat');
    return http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'stream': false,
        'options': {
          'temperature': temperature,
        },
      }),
    );
  }

  String _parseOllamaChatContent(String responseBody) {
    final data = jsonDecode(responseBody);
    final message = data is Map<String, dynamic> ? data['message'] : null;
    final content = message is Map<String, dynamic> ? message['content'] : null;
    if (content is String) return content;
    return content?.toString() ?? '';
  }

  bool _looksLikeModelNotFound(String body) {
    final lower = body.toLowerCase();
    return lower.contains('model') &&
        (lower.contains('not found') ||
            lower.contains('does not exist') ||
            lower.contains('model_not_found'));
  }

  bool _looksLikeUnsupportedParam(String body, String paramName) {
    final lower = body.toLowerCase();
    return lower.contains('unsupported') && lower.contains(paramName.toLowerCase());
  }

  bool _looksLikeImageNotSupported(String body) {
    final lower = body.toLowerCase();
    // Best-effort heuristics across OpenAI-compatible providers.
    return lower.contains('image') &&
        (lower.contains('not supported') ||
            lower.contains('unsupported') ||
            lower.contains('invalid') ||
            lower.contains('only text'));
  }

  Future<String> _pickVisionModel() async {
    final models = await listModels();
    if (models.isEmpty) return _model;

    final lower = models.map((m) => m.toLowerCase()).toList();

    int idx = lower.indexWhere((m) => m.contains('vision'));
    if (idx != -1) return models[idx];

    idx = lower.indexWhere((m) => m.contains('llava'));
    if (idx != -1) return models[idx];

    // Fallback to a llama model if no vision-specific ones are listed.
    idx = lower.indexWhere((m) => m.contains('llama'));
    if (idx != -1) return models[idx];

    return models.first;
  }

  DateTime? _estimateExpiryForCategory(String category) {
    final lower = category.toLowerCase();
    final now = DateTime.now();
    if (lower.contains('meat')) return now.add(const Duration(days: 3));
    if (lower.contains('dairy')) return now.add(const Duration(days: 7));
    if (lower.contains('produce')) return now.add(const Duration(days: 5));
    if (lower.contains('bakery')) return now.add(const Duration(days: 4));
    if (lower.contains('frozen')) return now.add(const Duration(days: 180));
    if (lower.contains('beverage')) return now.add(const Duration(days: 60));
    if (lower.contains('snack')) return now.add(const Duration(days: 90));
    if (lower.contains('pantry')) return now.add(const Duration(days: 365));
    return now.add(const Duration(days: 30));
  }

  /// Parse a grocery receipt photo into a list of GroceryItem.
  ///
  /// This uses OpenAI-compatible *vision* chat-completions (message content with image_url).
  /// If the configured model doesn't support images, it will try to auto-switch to a vision model.
  Future<List<GroceryItem>> parseReceiptImageToItems(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    await _ensureLoaded();
    if (!isConfigured) throw Exception('API Key not configured');
    if (imageBytes.isEmpty) throw Exception('Receipt image is empty');

    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';

    const allowedCategories = [
      'Produce',
      'Dairy',
      'Meat',
      'Bakery',
      'Pantry Staples',
      'Frozen',
      'Beverages',
      'Snacks',
      'Other',
    ];

    final prompt = '''
You are an expert grocery receipt parser.

Given a photo of a grocery receipt, extract the purchased items.
- Ignore totals, taxes, discounts, loyalty lines, and payment lines.
- Merge duplicates of the same item when obvious.
- If quantity is missing, use 1.
- If unit is missing, use "pcs".
- category MUST be one of: ${allowedCategories.join(', ')}.
- price is optional.

Return ONLY valid JSON with this schema:
{
  "items": [
    {
      "name": "string",
      "category": "Produce|Dairy|Meat|Bakery|Pantry Staples|Frozen|Beverages|Snacks|Other",
      "quantity": number,
      "unit": "string",
      "price": number|null
    }
  ]
}
''';

    Future<http.Response> doRequest({
      required String model,
      required bool includeResponseFormat,
    }) async {
      final body = <String, dynamic>{
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'You output only JSON. No markdown, no extra text.',
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': dataUrl},
              },
            ],
          },
        ],
        'temperature': 0.1,
      };
      if (includeResponseFormat) {
        body['response_format'] = {'type': 'json_object'};
      }

      return http.post(
        Uri.parse('$_openAiBaseUrl/chat/completions'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
    }

    // Try configured model first, then auto-select a vision model.
    var chosenModel = _model;
    http.Response response = await doRequest(model: chosenModel, includeResponseFormat: true);

    if (response.statusCode != 200 && _looksLikeUnsupportedParam(response.body, 'response_format')) {
      response = await doRequest(model: chosenModel, includeResponseFormat: false);
    }

    if (response.statusCode != 200 && (_looksLikeImageNotSupported(response.body) || _looksLikeModelNotFound(response.body))) {
      final visionModel = await _pickVisionModel();
      chosenModel = visionModel;
      await _persistModel(chosenModel);
      response = await doRequest(model: chosenModel, includeResponseFormat: true);
      if (response.statusCode != 200 && _looksLikeUnsupportedParam(response.body, 'response_format')) {
        response = await doRequest(model: chosenModel, includeResponseFormat: false);
      }
    }

    if (response.statusCode != 200) {
      throw Exception('Receipt parsing failed: ${response.statusCode} ${response.body}');
    }

    final content = _parseOpenAiChatContent(response.body);
    final jsonText = _extractJsonObject(content);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Receipt parser returned non-object JSON');
    }

    final itemsRaw = decoded['items'];
    if (itemsRaw is! List) {
      throw Exception('Receipt parser JSON missing "items" list');
    }

    final now = DateTime.now();
    final results = <GroceryItem>[];

    for (final entry in itemsRaw) {
      if (entry is! Map) continue;
      final name = (entry['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      final category = (entry['category'] as String?)?.trim() ?? 'Other';
      final normalizedCategory = allowedCategories.contains(category) ? category : 'Other';

      final qRaw = entry['quantity'];
      final quantity = (qRaw is num) ? qRaw.toDouble() : double.tryParse('${qRaw ?? ''}') ?? 1.0;
      final unit = (entry['unit'] as String?)?.trim().isNotEmpty == true
          ? (entry['unit'] as String).trim()
          : 'pcs';

      final pRaw = entry['price'];
      final price = (pRaw is num) ? pRaw.toDouble() : double.tryParse('${pRaw ?? ''}');

      results.add(
        GroceryItem(
          id: '${now.millisecondsSinceEpoch}_${results.length}',
          name: name,
          category: normalizedCategory,
          quantity: quantity <= 0 ? 1.0 : quantity,
          unit: unit,
          price: price,
          estimatedExpiryDate: _estimateExpiryForCategory(normalizedCategory),
        ),
      );
    }

    return results;
  }

  String _extractJsonObject(String text) {
    final trimmed = text.trim();
    // If it's already valid JSON, return it.
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return trimmed;
    } catch (_) {
      // continue
    }

    // Strip fenced code blocks if present.
    var candidate = trimmed;
    if (candidate.startsWith('```')) {
      final firstNewline = candidate.indexOf('\n');
      if (firstNewline != -1) {
        candidate = candidate.substring(firstNewline + 1);
      }
      final fenceEnd = candidate.lastIndexOf('```');
      if (fenceEnd != -1) {
        candidate = candidate.substring(0, fenceEnd);
      }
      candidate = candidate.trim();
    }

    // Best-effort: take substring between first '{' and last '}'
    final start = candidate.indexOf('{');
    final end = candidate.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw FormatException('No JSON object found in model output');
    }
    final jsonText = candidate.substring(start, end + 1);
    // Validate
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Model output JSON was not an object');
    }
    return jsonText;
  }

  /// Generate a recipe based on pantry items
  Future<GeneratedRecipe> generateRecipe(
    List<InventoryItem> items, 
    List<String> dietaryPreferences,
    String mealType,
    String customRequest,
  ) async {
    await _ensureLoaded();
    if (!isConfigured) throw Exception('API Key not configured');

    final ingredientsList = items
        .map((i) => "${i.quantity} ${i.unit} ${i.name} (expires: ${i.expiryDate?.toIso8601String().split('T')[0] ?? 'N/A'})")
        .join(', ');

    final prompt = '''
    You are a professional chef. Create a recipe using these available ingredients: $ingredientsList.
    Focus on using items that are expiring soon.
    Dietary preferences: ${dietaryPreferences.join(', ')}.
    Meal type: $mealType.
    Additional notes: $customRequest.
    
    Respond ONLY with valid JSON matching this structure:
    {
      "title": "Recipe Name",
      "description": "Brief description",
      "ingredients": ["1 cup rice", "200g chicken"],
      "instructions": ["Step 1", "Step 2"],
      "cookTimeMinutes": 30,
      "matchedIngredients": ["rice", "chicken"]
    }
    ''';

    Future<http.Response> doRequest({required bool includeResponseFormat}) async {
      final body = <String, dynamic>{
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful culinary assistant that outputs only JSON.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      };
      if (includeResponseFormat) {
        body['response_format'] = {'type': 'json_object'};
      }
      return http.post(
        Uri.parse('$_openAiBaseUrl/chat/completions'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
    }

    try {
      // First attempt (OpenAI-compatible servers support this endpoint).
      var response = await doRequest(includeResponseFormat: true);

      // If using Ollama and OpenAI-compat isn't available, fall back to native.
      if (_isOllamaLikely && response.statusCode == 404) {
        final native = await _ollamaChat(
          messages: [
            {
              'role': 'system',
              'content': 'You are a helpful culinary assistant that outputs only JSON.',
            },
            {'role': 'user', 'content': prompt},
          ],
          temperature: 0.7,
        );
        if (native.statusCode != 200) {
          throw Exception('Failed to generate recipe: ${native.statusCode} ${native.body}');
        }
        final content = _parseOllamaChatContent(native.body);
        final jsonText = _extractJsonObject(content);
        final jsonContent = jsonDecode(jsonText);
        return GeneratedRecipe.fromJson(jsonContent);
      }

      // If Groq rejects response_format, retry without it.
      if (response.statusCode != 200 && _looksLikeUnsupportedParam(response.body, 'response_format')) {
        response = await doRequest(includeResponseFormat: false);
      }

      // If model was deprecated, resolve a fallback model and retry once.
      if (response.statusCode != 200 && _looksLikeModelNotFound(response.body)) {
        final fallback = await _pickFallbackModel();
        await _persistModel(fallback);
        response = await doRequest(includeResponseFormat: true);
        if (response.statusCode != 200 && _looksLikeUnsupportedParam(response.body, 'response_format')) {
          response = await doRequest(includeResponseFormat: false);
        }
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to generate recipe: ${response.statusCode} ${response.body}');
      }

      final content = _parseOpenAiChatContent(response.body);
      final jsonText = _extractJsonObject(content);
      final jsonContent = jsonDecode(jsonText);
      return GeneratedRecipe.fromJson(jsonContent);
    } catch (e) {
      throw Exception('Error generating recipe: $e');
    }
  }

  /// Generate a multi-day meal plan based on pantry items.
  ///
  /// This is designed to work with Groq (OpenAI-compatible) and local Ollama.
  Future<MealPlan> generateMealPlan(
    List<InventoryItem> items, {
    required int days,
    List<String> dietaryPreferences = const [],
    String notes = '',
  }) async {
    await _ensureLoaded();
    if (!isConfigured) throw Exception('API Key not configured');
    if (days <= 0) throw Exception('Days must be > 0');

    final ingredientsList = items
        .map(
          (i) =>
              "${i.quantity} ${i.unit} ${i.name} (expires: ${i.expiryDate?.toIso8601String().split('T')[0] ?? 'N/A'})",
        )
        .join(', ');

    final prompt = '''
You are PantryPal's meal planner.

Create a $days-day meal plan that prioritizes using items expiring soon.
Available pantry: $ingredientsList.
Dietary preferences: ${dietaryPreferences.join(', ')}.
Notes: $notes.

Respond ONLY with valid JSON matching this structure:
{
  "days": [
    {
      "date": "YYYY-MM-DD",
      "meals": [
        {
          "name": "Breakfast|Lunch|Dinner|Snack",
          "title": "Meal title",
          "uses": ["ingredient1", "ingredient2"],
          "missing": ["missing1", "missing2"]
        }
      ]
    }
  ],
  "shoppingList": ["item1", "item2"]
}
''';

    Future<http.Response> doRequest({required bool includeResponseFormat}) async {
      final body = <String, dynamic>{
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You output only JSON. Do not include markdown.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.5,
      };
      if (includeResponseFormat) {
        body['response_format'] = {'type': 'json_object'};
      }
      return http.post(
        Uri.parse('$_openAiBaseUrl/chat/completions'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
    }

    try {
      var response = await doRequest(includeResponseFormat: true);

      if (_isOllamaLikely && response.statusCode == 404) {
        final native = await _ollamaChat(
          messages: [
            {
              'role': 'system',
              'content': 'You output only JSON. Do not include markdown.',
            },
            {'role': 'user', 'content': prompt},
          ],
          temperature: 0.5,
        );
        if (native.statusCode != 200) {
          throw Exception('Failed to generate meal plan: ${native.statusCode} ${native.body}');
        }
        final content = _parseOllamaChatContent(native.body);
        final jsonText = _extractJsonObject(content);
        final jsonContent = jsonDecode(jsonText);
        return MealPlan.fromJson(jsonContent);
      }

      if (response.statusCode != 200 && _looksLikeUnsupportedParam(response.body, 'response_format')) {
        response = await doRequest(includeResponseFormat: false);
      }

      if (response.statusCode != 200 && _looksLikeModelNotFound(response.body)) {
        final fallback = await _pickFallbackModel();
        await _persistModel(fallback);
        response = await doRequest(includeResponseFormat: true);
        if (response.statusCode != 200 && _looksLikeUnsupportedParam(response.body, 'response_format')) {
          response = await doRequest(includeResponseFormat: false);
        }
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to generate meal plan: ${response.statusCode} ${response.body}');
      }

      final content = _parseOpenAiChatContent(response.body);
      final jsonText = _extractJsonObject(content);
      final jsonContent = jsonDecode(jsonText);
      return MealPlan.fromJson(jsonContent);
    } catch (e) {
      throw Exception('Error generating meal plan: $e');
    }
  }

  // --- Chatbot Functionality ---

  // Simple history management for this demo
  final List<Map<String, String>> _chatHistory = [];

  Future<String> sendChatMessage(String message, List<InventoryItem> pantryItems) async {
    await _ensureLoaded();
    if (!isConfigured) return "Please configure your API Key in Settings first.";

    try {
      if (_chatHistory.isEmpty) {
        // Initialize with system prompt
        final pantryContext = pantryItems.isEmpty 
            ? "The user's pantry is currently empty."
            : "Current pantry inventory: ${pantryItems.map((i) => "${i.quantity} ${i.unit} ${i.name} (expires in ${i.daysUntilExpiry} days)").join(', ')}.";

        _chatHistory.add({
          'role': 'system', 
          'content': 'You are PantryPal, a witty kitchen assistant. $pantryContext'
        });
      }

      _chatHistory.add({'role': 'user', 'content': message});

      Future<http.Response> doRequest() async {
        return http.post(
          Uri.parse('$_openAiBaseUrl/chat/completions'),
          headers: await _getHeaders(),
          body: jsonEncode({
            'model': _model,
            'messages': _chatHistory,
            'temperature': 0.7,
          }),
        );
      }

      var response = await doRequest();

      // Ollama fallback to native endpoint if OpenAI-compat isn't enabled.
      if (_isOllamaLikely && response.statusCode == 404) {
        final native = await _ollamaChat(messages: _chatHistory, temperature: 0.7);
        if (native.statusCode == 200) {
          final content = _parseOllamaChatContent(native.body);
          _chatHistory.add({'role': 'assistant', 'content': content});
          return content;
        }
        return "Error from API: ${native.statusCode} ${native.body}";
      }

      if (response.statusCode != 200 && _looksLikeModelNotFound(response.body)) {
        final fallback = await _pickFallbackModel();
        await _persistModel(fallback);
        response = await doRequest();
      }

      if (response.statusCode == 200) {
        final content = _parseOpenAiChatContent(response.body);
        _chatHistory.add({'role': 'assistant', 'content': content});
        return content;
      }

      return "Error from API: ${response.statusCode} ${response.body}";
    } catch (e) {
      return "Sorry, I had trouble connecting. ($e)";
    }
  }
  
  void clearChat() {
    _chatHistory.clear();
  }
}
