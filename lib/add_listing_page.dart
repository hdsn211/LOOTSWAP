import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'listing.dart';
import 'services/firestore_service.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tradeForController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _rarity = 'Common';
  bool _isAvailable = true;
  bool _isSaving = false;

  static const _backgroundColor = Color(0xFF101116);
  static const _cardColor = Color(0xFF1C1D25);
  static const _primaryTextColor = Color(0xFFF5F5FA);
  static const _secondaryTextColor = Color(0xFF898B99);
  static const _purpleColor = Color(0xFF4338FF);

  @override
  void dispose() {
    _itemNameController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _tradeForController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please sign in before creating a listing.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final userName = user.email?.split('@').first ?? 'User';
    final listing = Listing(
      id: DateTime.now().millisecondsSinceEpoch,
      ownerId: user.uid,
      userName: userName,
      itemName: _itemNameController.text.trim(),
      itemImage: _imageController.text.trim(),
      rarity: _rarity,
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      isAvailable: _isAvailable,
      tradeFor: _tradeForController.text.trim(),
    );

    try {
      await _firestoreService.addListing(listing);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to create listing. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _secondaryTextColor),
      hintStyle: const TextStyle(color: _secondaryTextColor),
      filled: true,
      fillColor: _cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _purpleColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: _primaryTextColor,
        title: Text(
          'Add Listing',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              TextFormField(
                controller: _itemNameController,
                style: const TextStyle(color: _primaryTextColor),
                decoration: _decoration('Item name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an item name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                style: const TextStyle(color: _primaryTextColor),
                decoration: _decoration(
                  'Image URL',
                  hint: 'https://example.com/item.png',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _rarity,
                dropdownColor: _cardColor,
                style: const TextStyle(color: _primaryTextColor),
                decoration: _decoration('Rarity'),
                items: const ['Common', 'Rare', 'Epic', 'Legendary']
                    .map(
                      (rarity) => DropdownMenuItem(
                        value: rarity,
                        child: Text(rarity),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _rarity = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                style: const TextStyle(color: _primaryTextColor),
                decoration: _decoration('Category'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a category'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: _primaryTextColor),
                decoration: _decoration('Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tradeForController,
                style: const TextStyle(color: _primaryTextColor),
                decoration: _decoration('Trade for'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Available for trade',
                  style: TextStyle(color: _primaryTextColor),
                ),
                value: _isAvailable,
                activeColor: _purpleColor,
                onChanged: (value) => setState(() => _isAvailable = value),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveListing,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purpleColor,
                    foregroundColor: _primaryTextColor,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
