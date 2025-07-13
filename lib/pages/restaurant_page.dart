import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api_constants.dart'; // Import your API constants
import 'menu_page.dart';

class RestaurantsPage extends StatefulWidget {
  final int? restaurantId; // Accept optional restaurantId for redirection

  const RestaurantsPage({Key? key, this.restaurantId}) : super(key: key);

  @override
  _RestaurantsPageState createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  List<dynamic> restaurants = [];
  List<dynamic> cities = [];
  String selectedCity = "All Cities";
  int? selectedCityId;

  @override
  void initState() {
    super.initState();
    fetchCities();

    if (widget.restaurantId != null) {
      fetchRestaurantById(widget.restaurantId!);
    } else {
      _loadSelectedCity();
    }
  }

  Future<void> fetchAllRestaurants() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetAllRestaurants');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        restaurants = json.decode(response.body)['data'];
      });
    }
  }

  Future<void> fetchCities() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetAllCities');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        cities = json.decode(response.body)['data'];
        cities.insert(0, {"cityId": null, "cityName": "All Cities"});
      });
    }
  }

  Future<void> fetchRestaurantsByCity(int cityId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetRestaurantsByCity/$cityId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        restaurants = json.decode(response.body)['data'];
      });
    }
  }

  Future<void> fetchRestaurantById(int restaurantId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetRestaurantById/$restaurantId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        restaurants = [data]; // Wrap in a list for ListView
      });
    }
  }

  void onCitySelected(String cityName, int? cityId) {
    setState(() {
      selectedCity = cityName;
      selectedCityId = cityId;
    });

    if (cityId == null) {
      fetchAllRestaurants();
    } else {
      fetchRestaurantsByCity(cityId);
    }

    _saveSelectedCity(cityId);
  }

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedCityId = prefs.getInt('selectedCityId');

    if (savedCityId != null) {
      setState(() {
        selectedCityId = savedCityId;
      });
      fetchRestaurantsByCity(savedCityId);
    } else {
      fetchAllRestaurants();
    }
  }

  Future<void> _saveSelectedCity(int? cityId) async {
    final prefs = await SharedPreferences.getInstance();
    if (cityId != null) {
      prefs.setInt('selectedCityId', cityId);
    } else {
      prefs.remove('selectedCityId');
    }
  }

  Future<void> _saveSelectedRestaurant(int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedRestaurantId', restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurants 🍽️"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.redAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<int>(
                  value: cities.any((c) => c["cityId"] == selectedCityId)
                      ? selectedCityId
                      : null,
                  dropdownColor: Colors.white,
                  items: cities.map<DropdownMenuItem<int>>((city) {
                    return DropdownMenuItem<int>(
                      value: city["cityId"],
                      child: Text(
                        city["cityName"],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (cityId) {
                    String cityName = cities
                        .firstWhere((c) => c["cityId"] == cityId)["cityName"];
                    onCitySelected(cityName, cityId);
                  },
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    border: InputBorder.none,
                    prefixIcon:
                    Icon(Icons.location_city, color: Colors.deepOrange),
                  ),
                ),
              ),
            ),
            Expanded(
              child: restaurants.isEmpty
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  var restaurant = restaurants[index];
                  return GestureDetector(
                    onTap: () {
                      _saveSelectedRestaurant(
                          restaurant['restaurantId']);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuPage(
                            restaurantId: restaurant['restaurantId'],
                            restaurantName: restaurant['name'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black38,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(15)),
                            child: Image.network(
                              restaurant['imageUrl'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    restaurant['address'],
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54),
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
            ),
          ],
        ),
      ),
    );
  }
}
