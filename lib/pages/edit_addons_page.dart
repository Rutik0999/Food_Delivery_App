import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_data.dart';
import '../providers/cart_provider.dart';

class EditAddonsPage extends StatefulWidget {
  final CartItem cartItem;

  const EditAddonsPage({super.key, required this.cartItem});

  @override
  State<EditAddonsPage> createState() => _EditAddonsPageState();
}

class _EditAddonsPageState extends State<EditAddonsPage> {
  late List<Map<String, dynamic>> _availableAddons;
  late List<Map<String, dynamic>> _selectedAddons;

  @override
  void initState() {
    super.initState();
    // Load available add-ons (example hardcoded; ideally from API)
    _availableAddons = [
      {'addonId': 1, 'name': 'Cheese', 'price': 20.0},
      {'addonId': 2, 'name': 'Extra Sauce', 'price': 15.0},
      {'addonId': 3, 'name': 'Spicy', 'price': 10.0},
    ];

    _selectedAddons = List<Map<String, dynamic>>.from(widget.cartItem.selectedAddons);
  }

  void _toggleAddon(Map<String, dynamic> addon) {
    setState(() {
      final exists = _selectedAddons.any((a) => a['addonId'] == addon['addonId']);
      if (exists) {
        _selectedAddons.removeWhere((a) => a['addonId'] == addon['addonId']);
      } else {
        _selectedAddons.add(addon);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Add-ons"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: _availableAddons.map((addon) {
          final isSelected = _selectedAddons.any((a) => a['addonId'] == addon['addonId']);
          return CheckboxListTile(
            value: isSelected,
            title: Text('${addon['name']} (₹${addon['price']})'),
            onChanged: (_) => _toggleAddon(addon),
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          onPressed: () {
            // Update the cart item with new add-ons
            setState(() {
              widget.cartItem.selectedAddons
                ..clear()
                ..addAll(_selectedAddons);
            });
            cartProvider.notifyListeners(); // to refresh cart
            Navigator.pop(context);
          },
          child: const Text("Save Changes"),
        ),
      ),
    );
  }
}
