import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/inventory_item.dart';
import '../models/grocery_item.dart';
import '../services/api_service.dart';
import 'receipt_review_screen.dart';
import '../l10n/app_localizations.dart';

/// Screen for scanning grocery receipts using the camera
class ReceiptScannerScreen extends StatefulWidget {
  final Future<void> Function(List<InventoryItem>) onItemsAdded;

  const ReceiptScannerScreen({
    super.key,
    required this.onItemsAdded,
  });

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Automatically open camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureReceipt();
    });
  }

  /// Open camera to take photo of receipt
  Future<void> _captureReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        // User cancelled
        if (mounted) Navigator.pop(context);
        return;
      }

      await _processReceipt(File(image.path));
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.tr('receipt_error_accessing_camera').replaceAll('{error}', '$e'),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// Send receipt image to backend for OCR processing
  Future<void> _processReceipt(File imageFile) async {
    setState(() => _isProcessing = true);

    try {
      // Call API service (currently mocked)
      final List<GroceryItem> parsedItems = await _apiService.processReceiptImage(imageFile);

      if (!mounted) return;

      // Navigate to review screen with parsed items
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptReviewScreen(
            parsedItems: parsedItems,
            receiptImage: imageFile,
            onItemsAdded: widget.onItemsAdded,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        // Show user-friendly error message
        String errorMessage = t.tr('receipt_error_processing');
        
        if (e.toString().contains('not supported on web')) {
          errorMessage = '${t.tr('receipt_ai_requires_mobile')}\n\n'
              '${t.tr('receipt_web_preview_uses_demo')}\n\n'
              '${t.tr('receipt_run_on_mobile_for_real')}';
        } else {
          errorMessage = t.tr('receipt_error_generic').replaceAll('{error}', e.toString());
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(t.tr('scan_receipt_title')),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 24),
                  Text(
                    t.tr('receipt_processing'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (kIsWeb)
                    Text(
                      t.tr('receipt_web_preview_note'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
