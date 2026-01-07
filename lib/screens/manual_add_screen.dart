import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import 'home_screen.dart' show AppTheme;
import '../l10n/app_localizations.dart';

/// Screen for manually adding items to inventory
class ManualAddScreen extends StatefulWidget {
  final Future<void> Function(List<InventoryItem>) onItemsAdded;

  const ManualAddScreen({super.key, required this.onItemsAdded});

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  bool _submitting = false;

  String _selectedCategory = 'Produce';
  String _selectedUnit = 'pcs';
  DateTime? _expiryDate;

  final List<String> _categories = [
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

  final List<String> _units = [
    'pcs',
    'kg',
    'g',
    'L',
    'mL',
    'box',
    'bag',
    'can',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary, // Emerald
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _addItem() async {
    if (_submitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _submitting = true);
      final newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        addedDate: DateTime.now(),
        expiryDate: _expiryDate,
      );

      try {
        await widget.onItemsAdded([newItem]);
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
    }
  }

  String _categoryLabel(AppLocalizations t, String category) {
    switch (category) {
      case 'Produce':
        return t.tr('category_produce');
      case 'Dairy':
        return t.tr('category_dairy');
      case 'Meat':
        return t.tr('category_meat');
      case 'Bakery':
        return t.tr('category_bakery');
      case 'Pantry Staples':
        return t.tr('category_pantry_staples');
      case 'Frozen':
        return t.tr('category_frozen');
      case 'Beverages':
        return t.tr('category_beverages');
      case 'Snacks':
        return t.tr('category_snacks');
      case 'Other':
        return t.tr('category_other');
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          t.tr('manual_add_title'),
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionLabel(t.tr('item_details')),
                const SizedBox(height: 16),

                // Item Name field
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    t.tr('item_name'),
                    Icons.shopping_bag_outlined,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? t.tr('required') : null,
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration(
                    t.tr('category'),
                    Icons.category_outlined,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(_categoryLabel(t, c))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 24),

                _buildSectionLabel(t.tr('quantity_and_expiry')),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          t.tr('qty'),
                          Icons.numbers_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return t.tr('required');
                          if (double.tryParse(value) == null) return t.tr('invalid');
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: _inputDecoration(t.tr('unit'), null),
                        items: _units
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Expiry Date
                InkWell(
                  onTap: _selectExpiryDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      t.tr('expiry_date'),
                      Icons.calendar_today_rounded,
                    ),
                    child: Text(
                      _expiryDate == null
                          ? t.tr('select_date')
                          : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                      style: TextStyle(
                        color: _expiryDate == null
                            ? AppTheme.textLight
                            : AppTheme.textDark,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _submitting ? null : _addItem,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            t.tr('add_to_pantry'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textLight),
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
        letterSpacing: 0.5,
      ),
    );
  }
}
