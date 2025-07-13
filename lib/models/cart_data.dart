class CartItem {
  final int menuId;
  final String name;
  final double price;
  final List<Map<String, dynamic>> selectedAddons;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.menuId,
    required this.name,
    required this.price,
    required this.selectedAddons,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice {
    double addonTotal = selectedAddons.fold(0.0, (sum, addon) => sum + (addon['price'] as num).toDouble());
    return (price + addonTotal) * quantity;
  }
}
