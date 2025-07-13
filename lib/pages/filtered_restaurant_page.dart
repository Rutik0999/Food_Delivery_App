import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../API/api_constants.dart';
import 'menu_page.dart';

class FilteredRestaurantPage extends StatefulWidget {
  final String foodType;
  const FilteredRestaurantPage({
    super.key,
    required this.foodType,
    required String filter,
  });

  @override
  State<FilteredRestaurantPage> createState() => _FilteredRestaurantPageState();
}

class _FilteredRestaurantPageState extends State<FilteredRestaurantPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<dynamic> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    fetchFilteredRestaurants();
  }

  Future<void> fetchFilteredRestaurants() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetRestaurantsByFoodType/${widget.foodType}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurants = data['data'];
          isLoading = false;
          _controller.forward();
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchRestaurantById(String restaurantId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetRestaurantById/$restaurantId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception("Failed to load restaurant details");
      }
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception("Failed to load restaurant details");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildAnimatedRestaurantCard(Map<String, dynamic> restaurant, int index) {
    final Animation<double> fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval((1 / restaurants.length) * index, 1.0, curve: Curves.easeIn),
    );

    final Animation<Offset> slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(fadeAnimation);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: GestureDetector(
          onTap: () async {
            try {
              Map<String, dynamic> restaurantDetails = await fetchRestaurantById(restaurant['restaurantId'].toString());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPage(
                    restaurantId: restaurantDetails['restaurantId'],
                    restaurantName: restaurantDetails['name'],
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch restaurant details")));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    restaurant["imageUrl"],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant["name"],
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${restaurant["address"]}, ${restaurant["cityName"]}",
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant["rating"]}",
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE5B4), Color(0xFFFFDAB9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "${widget.foodType} Restaurants",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.deepOrange,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.deepOrange),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : restaurants.isEmpty
            ? Center(
          child: Text(
            "No ${widget.foodType} restaurants found.",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return buildAnimatedRestaurantCard(restaurants[index], index);
          },
        ),
      ),
    );
  }
}
