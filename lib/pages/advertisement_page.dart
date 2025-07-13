import 'package:flutter/material.dart';
import 'package:food_app_new/pages/cart.dart';
import 'package:food_app_new/pages/restaurant_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:food_app_new/pages/cart.dart';
import 'package:food_app_new/components/my_drawer.dart';
import 'package:food_app_new/pages/filtered_restaurant_page.dart';

class AdvertisementPage extends StatefulWidget {
  final bool showSuccessMessage;
  final String message;

  AdvertisementPage({
    super.key,
    this.showSuccessMessage = true,
    this.message = "Welcome",
  });

  @override
  State<AdvertisementPage> createState() => _AdvertisementPageState();
}

class _AdvertisementPageState extends State<AdvertisementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  final List<String> ads = [
    "https://img.freepik.com/free-vector/safe-food-delivery-order-receive_23-2148549716.jpg?t=st=1744087424~exp=1744091024~hmac=fe68ad0aa86a11b529050574e6dff70078c6fee29267e9d298441b6902769734&w=1380",
    "https://img.freepik.com/premium-psd/social-media-feijoada-food_450139-2638.jpg?w=740",
    "https://wallpapers.com/images/featured/uzm1ss89qzgz2qtu.jpg",
    "https://img.freepik.com/free-photo/smartphone-with-hand-holding-noodles_23-2149834254.jpg?t=st=1743346496~exp=1743350096~hmac=ac74b9836bf24c7878af534d01a6d4657eb2594db7b5ada7f24888830bde0c99&w=826",
  ];

  final List<Map<String, String>> offers = [
    {
      "image": "https://cdn.grabon.in/gograbon/images/web-images/uploads/1618575517942/food-coupons.jpg",
      "title": "Flat 50% Off!",
      "description": "On your first order. Use code: FIRST50",
    },
    {
      "image": "https://img.freepik.com/vetores-premium/3d-entrega-rapida-para-telefone-via-scooter_420121-274.jpg",
      "title": "Free Delivery!",
      "description": "Get free delivery on orders above ₹199.",
    },
    {
      "image": "https://i.pinimg.com/736x/a5/77/a1/a577a1d30853d67ff3810a00d5d83dfa.jpg",
      "title": "Buy 1 Get 1 Free",
      "description": "Limited time offer on selected restaurants.",
    },
  ];

  final List<Map<String, String>> dishes = [
    {
      "image": "https://d2lswn7b0fl4u2.cloudfront.net/photos/pg-margherita-pizza-1611491820.jpg",
      "name": "Margherita Pizza",
      "restaurant": "Pizza Hut",
      "rating": "4.5",
      "type": "Veg",
    },
    {
      "image": "https://brookrest.com/wp-content/uploads/2020/05/AdobeStock_282247995-scaled.jpeg",
      "name": "Cheese Burger",
      "restaurant": "Burger King",
      "rating": "4.2",
      "type": "Non-Veg",
    },
    {
      "image": "https://dinnerthendessert.com/wp-content/uploads/2021/05/Chicken-Alfredo-Pasta-1x1-1.jpg",
      "name": "Creamy Alfredo Pasta",
      "restaurant": "Italiano Cafe",
      "rating": "4.7",
      "type": "Veg",
    },
    {
      "image": "https://www.eatloveeats.com/wp-content/uploads/2021/11/Sticky-Spicy-Baked-Chicken-Wings-Featured-Image.jpg",
      "name": "Spicy Chicken Wings",
      "restaurant": "KFC",
      "rating": "4.3",
      "type": "Non-Veg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: Text(
          "Home",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CartPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: Column(
                      children: [
                        Text(
                          "FoodiXpress",
                          style: GoogleFonts.lobster(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Delicious food at your doorstep",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
              ),
              items: ads.map((ad) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(ad,
                      fit: BoxFit.cover, width: double.infinity),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "🔥 Exclusive Offers",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(offers.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantsPage(
                            restaurantId: int.tryParse(offers[index]["restaurantId"].toString()),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              offers[index]["image"]!,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offers[index]["title"]!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  offers[index]["description"]!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🍕 Popular Dishes",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {},
                    itemBuilder: (context) {
                      String tempFilter = selectedFilter;
                      return [
                        PopupMenuItem(
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<String>(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.restaurant, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text("Both"),
                                      ],
                                    ),
                                    value: "Both",
                                    groupValue: tempFilter,
                                    onChanged: (value) {
                                      setState(() => tempFilter = value!);
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.eco, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text("Veg Restaurants"),
                                      ],
                                    ),
                                    value: "Veg",
                                    groupValue: tempFilter,
                                    onChanged: (value) {
                                      setState(() => tempFilter = value!);
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.local_dining, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text("Non-Veg Restaurants"),
                                      ],
                                    ),
                                    value: "Non-Veg",
                                    groupValue: tempFilter,
                                    onChanged: (value) {
                                      setState(() => tempFilter = value!);
                                    },
                                  ),
                                  const Divider(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        selectedFilter = tempFilter;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FilteredRestaurantPage(
                                            filter: tempFilter,
                                            foodType: tempFilter,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: const Text(
                                      "Apply",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            "Filter",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                if (selectedFilter != "All" &&
                    dishes[index]["type"] != selectedFilter) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () {
                      // Navigate to RestaurantPage with restaurant ID or data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantsPage(
                            restaurantId: int.tryParse(dishes[index]["restaurantId"].toString()),
                          ),
                        ),
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        dishes[index]["image"]!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      dishes[index]["name"]!,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        "⭐ ${dishes[index]["rating"]!} | ${dishes[index]["restaurant"]!}"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  RestaurantsPage()),
                  );
                },
                child: Text(
                  "Visit Nearest Restaurant",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
