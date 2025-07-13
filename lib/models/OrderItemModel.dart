class OrderItemModel {
  final String name;
  final String imageUrl;
  final int quantity;
  final double totalPrice;
  final List<Map<String, dynamic>> selectedAddons;

  OrderItemModel({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.totalPrice,
    required this.selectedAddons,
  });
}
