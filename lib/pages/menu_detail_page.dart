import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/cart_data.dart';
import '../providers/cart_provider.dart';
import '../API/api_constants.dart'; // ✅ Import your API base URL

class MenuDetailPage extends StatefulWidget {
  final dynamic menuItem;

  const MenuDetailPage({super.key, required this.menuItem});

  @override
  _MenuDetailPageState createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage>
    with SingleTickerProviderStateMixin {
  final Map<String, bool> selectedAddons = {};
  List<dynamic> addons = [];
  bool isLoadingAddons = true;
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    fetchAddons();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchAddons() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/FoodApp/GetAddOnsByMenuId/${widget.menuItem['menuId']}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          addons = data['data'];
          for (var addon in addons) {
            selectedAddons[addon['name']] = false;
          }
          isLoadingAddons = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching addons: $e');
      setState(() => isLoadingAddons = false);
    }
  }

  List<Map<String, dynamic>> getSelectedAddons() {
    return addons
        .where((addon) => selectedAddons[addon['name']] == true)
        .map((addon) => {
      'addonId': addon['addOnId'],
      'name': addon['name'],
      'price': (addon['price'] as num).toDouble(),
    })
        .toList();
  }

  double calculateTotalPrice() {
    double basePrice = (widget.menuItem['price'] as num).toDouble();
    double addonsTotal =
    getSelectedAddons().fold(0, (sum, addon) => sum + addon['price']);
    return basePrice + addonsTotal;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(widget.menuItem['name']),
        backgroundColor: Colors.deepOrange,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        widget.menuItem['imageUrl'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.menuItem['name'],
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text("₹${widget.menuItem['price']}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Text(widget.menuItem['description'] ?? "",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
                          const SizedBox(height: 20),
                          if (isLoadingAddons)
                            const Center(child: CircularProgressIndicator())
                          else if (addons.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Choose Add-ons",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                ...List.generate(addons.length, (index) {
                                  final addon = addons[index];
                                  return AnimatedContainer(
                                    duration: Duration(
                                        milliseconds: 300 + (index * 50)),
                                    curve: Curves.easeInOut,
                                    margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2))
                                      ],
                                    ),
                                    child: CheckboxListTile(
                                      activeColor: Colors.blue,
                                      checkColor: Colors.white,
                                      value: selectedAddons[addon['name']],
                                      title: Text(addon['name'],
                                          style: GoogleFonts.poppins()),
                                      subtitle: Text("₹${addon['price']}",
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedAddons[addon['name']] = val!;
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          const SizedBox(height: 20),
                          Text(
                              "Total: ₹${calculateTotalPrice().toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),
                          MouseRegion(
                            onEnter: (_) => setState(() => isHovered = true),
                            onExit: (_) => setState(() => isHovered = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: isHovered
                                      ? [Colors.orangeAccent, Colors.deepOrange]
                                      : [Colors.deepOrange, Colors.orange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  if (isHovered)
                                    BoxShadow(
                                      color: Colors.orangeAccent
                                          .withOpacity(0.6),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    final selectedItem = CartItem(
                                      menuId: widget.menuItem['menuId'],
                                      name: widget.menuItem['name'],
                                      imageUrl: widget.menuItem['imageUrl'],
                                      price: (widget.menuItem['price'] as num)
                                          .toDouble(),
                                      selectedAddons: getSelectedAddons(),
                                    );

                                    cartProvider.addToCart(selectedItem);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "${widget.menuItem['name']} added to cart!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Center(
                                      child: Text("Add to Cart",
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
