import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import 'home_screen.dart' show AppTheme;

/// Screen for manually adding items to inventory
class ManualAddScreen extends StatefulWidget {
  final Function(List<InventoryItem>) onItemsAdded;

  const ManualAddScreen({super.key, required this.onItemsAdded});

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

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

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        addedDate: DateTime.now(),
        expiryDate: _expiryDate,
      );

      widget.onItemsAdded([newItem]);

      // Pop handled by parent usually, but consistent with pattern
      // Parent callback might not navigate, so we pop here or let parent handle?
      // In AddItemScreen logic, we passed the callback but didn't handle pop there inside the callback wrapper fully if we want close THIS screen first.
      // Actually AddItemScreen callback pops itself effectively.
      // Let's just pop this screen to return to AddItemScreen which then might finish.
      // Wait, AddItemScreen passed: (items) => _handleItemsAdded(context, items).
      // _handleItemsAdded pops the context. So calling the callback pops ONCE.
      // We are at ManualAddScreen -> AddItemScreen.
      // If we want to fully close Manual AND AddItem, we need care.
      // Actually `onItemsAdded` in AddItemScreen pops context (ManualAddScreen).
      // Then shows snackbar in AddItemScreen.

      widget.onItemsAdded([newItem]);
      // NOTE: Logic in AddItemScreen calls Navigator.pop(context).
      // That context is ManualAddScreen's context if passed correctly?
      // No, it handles the logic.
      // Let's assume the callback handles navigation or we should pop here.
      // The previous implementation popped here. Let's keep it consistent.
      // The updated AddItemScreen uses `Navigator.pop(context)` which closes ManualScreen.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Add Manually',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
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
                _buildSectionLabel('Item Details'),
                const SizedBox(height: 16),

                // Item Name field
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    'Item Name',
                    Icons.shopping_bag_outlined,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration(
                    'Category',
                    Icons.category_outlined,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 24),

                _buildSectionLabel('Quantity & Expiry'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Qty',
                          Icons.numbers_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: _inputDecoration('Unit', null),
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
                      'Expiry Date',
                      Icons.calendar_today_rounded,
                    ),
                    child: Text(
                      _expiryDate == null
                          ? 'Select Date'
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
                    onPressed: _addItem,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add to Pantry',
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
      labelStyle: const TextStyle(color: AppTheme.textLight),
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
        letterSpacing: 0.5,
      ),
    );
  }
}
