import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_app_new/pages/cart.dart';
import 'package:http/http.dart' as http;
import 'menu_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api_constants.dart'; // ✅ Import your API constants

class MenuPage extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const MenuPage({super.key, required this.restaurantId, required this.restaurantName});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> menuItems = [];
  bool isLoading = true;
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetMenuByRestaurant/${widget.restaurantId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          menuItems = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load menu")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> saveSelectedMenuId(int menuId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedMenuId', menuId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.deepOrange, size: 26),
          ),
        ),
        title: Text(widget.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuItems.isEmpty
          ? const Center(child: Text("No menu available"))
          : ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          var item = menuItems[index];

          return GestureDetector(
            onTap: () async {
              await saveSelectedMenuId(item['menuId']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuDetailPage(menuItem: item),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                    child: Image.network(
                      item['imageUrl'],
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.category, size: 16, color: Colors.deepOrange),
                                    const SizedBox(width: 5),
                                    Text(
                                      item['category'] ?? "Uncategorized",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['description'],
                            style: const TextStyle(color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${item['price']}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange),
                              ),
                              item['isAvailable']
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
