import 'OrderItemModel.dart';

class OrderModel {
  final DateTime dateTime;
  final List<OrderItemModel> items;
  final double total;

  OrderModel({
    required this.dateTime,
    required this.items,
    required this.total,
  });
}
