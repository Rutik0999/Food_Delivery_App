import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../API/api_constants.dart'; // Import your API constants
import 'package:food_app_new/pages/delivery_progress_page.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> groupedOrders = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchOrders();
  }

  Future<void> loadUserIdAndFetchOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      await fetchGroupedOrders(userId!);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchGroupedOrders(String userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetGroupedOrders?userId=$userId'); // Use baseUrl from ApiConstants

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Response Data: $jsonData");  // Log the response to debug

        if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
          setState(() {
            groupedOrders = jsonData['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            groupedOrders = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : groupedOrders.isEmpty
          ? Center(
          child: Text("No orders found", style: GoogleFonts.poppins(fontSize: 18)))
          : ListView.builder(
        itemCount: groupedOrders.length,
        itemBuilder: (context, index) {
          final group = groupedOrders[index];
          return buildOrderCard(group);
        },
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> group) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.shade100, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: ExpansionTile(
        iconColor: Colors.deepPurple,
        collapsedIconColor: Colors.deepPurple,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("Status: ${group['paymentStatus']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 6),
                Text("Status:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                SizedBox(width: 6),
                Text("Order Placed", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.green)),
              ],
            ),
            Row(
              children: [
                Icon(Icons.payment, size: 16, color: Colors.black87),
                SizedBox(width: 4),
                Text("${group['paymentMode']} • ₹${group['amount']}", style: GoogleFonts.poppins(color: Colors.black87)),
              ],
            ),
          ],
        ),
        children: group['orders'].map<Widget>((order) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    order['imageUrl'],
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(order['menuName'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Restaurant: ${order['restaurantName']}",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                    Text("Add-On: ${order['addonName'] ?? 'None'}",
                        style: GoogleFonts.poppins(fontSize: 13)),
                    if (order['notes'] != null)
                      Text("Note: ${order['notes']}",
                          style: GoogleFonts.poppins(fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
