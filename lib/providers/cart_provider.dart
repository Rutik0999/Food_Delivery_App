import 'package:flutter/material.dart';
import '../models/cart_data.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(CartItem newItem) {
    final existingIndex = _items.indexWhere((item) =>
    item.menuId == newItem.menuId &&
        _compareAddons(item.selectedAddons, newItem.selectedAddons));

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity += 1;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool _compareAddons(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    a.sort((x, y) => x['addonId'].compareTo(y['addonId']));
    b.sort((x, y) => x['addonId'].compareTo(y['addonId']));
    for (int i = 0; i < a.length; i++) {
      if (a[i]['addonId'] != b[i]['addonId']) return false;
    }
    return true;
  }
}
