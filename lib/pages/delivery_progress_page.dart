import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_app_new/pages/advertisement_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:food_app_new/pages/MyOrdersPage.dart';
import '../API/api_constants.dart'; // ✅ Importing baseUrl

class DeliveryProgressPage extends StatefulWidget {
  final int paymentId;
  const DeliveryProgressPage({Key? key, required this.paymentId}) : super(key: key);

  @override
  _DeliveryProgressPageState createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  late Future<DeliveryPartner> futureDeliveryPartner;
  late Future<PaymentDetails> futurePaymentDetails;

  @override
  void initState() {
    super.initState();
    futureDeliveryPartner = fetchDeliveryPartner();
    futurePaymentDetails = fetchPaymentDetails(widget.paymentId);
  }

  Future<DeliveryPartner> fetchDeliveryPartner() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetRandomDeliveryPartner');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return DeliveryPartner.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load delivery partner');
    }
  }

  Future<PaymentDetails> fetchPaymentDetails(int paymentId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetPaymentDetails/$paymentId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return PaymentDetails.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load payment details');
    }
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdvertisementPage(
          showSuccessMessage: true,
          message: "Order Placed Successfully",
        ),
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
          title: const Text("Order Confirmed"),
          backgroundColor: Colors.deepOrange.shade400,
        ),
        body: FutureBuilder<PaymentDetails>(
          future: futurePaymentDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              return _buildReceiptUI(snapshot.data!);
            } else {
              return const Center(child: Text("No Payment Details Found"));
            }
          },
        ),
        bottomNavigationBar: FutureBuilder<DeliveryPartner>(
          future: futureDeliveryPartner,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return SizedBox(height: 100, child: Center(child: Text('Error: ${snapshot.error}')));
            } else if (snapshot.hasData) {
              return _buildBottomNavBar(context, snapshot.data!);
            } else {
              return const SizedBox(height: 100, child: Center(child: Text('No delivery partner found')));
            }
          },
        ),
      ),
    );
  }

  Widget _buildReceiptUI(PaymentDetails details) {
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(details.paymentDateTime);
    final estimatedDeliveryTime = details.paymentDateTime.add(const Duration(minutes: 30));
    final formattedEstimate = DateFormat('hh:mm a').format(estimatedDeliveryTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Lottie.asset('assets/Lottie/Success.json', width: 150, repeat: false),
          const SizedBox(height: 10),
          Text("Order Successfully Placed!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
          const SizedBox(height: 15),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('RECEIPT',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900)),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow("Name", details.fullName),
                  _buildInfoRow("Receipt No", details.receiptNumber),
                  _buildInfoRow("Date & Time", formattedDate),
                  _buildInfoRow("Amount", "₹ ${details.amount.toStringAsFixed(2)}"),
                  _buildInfoRow("Delivery Address", details.address),
                  _buildInfoRow("Estimate Delivery Time", formattedEstimate),
                  const SizedBox(height: 25),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MyOrdersPage()),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade400,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.shade100,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          "View My Orders",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, DeliveryPartner partner) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade100,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(Icons.delivery_dining, size: 30, color: Colors.deepOrange),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(partner.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("📞 ${partner.contactNumber}", style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Row(
            children: [
              _buildIconButton(Icons.message, Colors.deepOrange, () => _sendMessage(partner.contactNumber)),
              const SizedBox(width: 10),
              _buildIconButton(Icons.call, Colors.green, () => _makePhoneCall(partner.contactNumber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: color,
        splashRadius: 28,
      ),
    );
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $number';
    }
  }

  Future<void> _sendMessage(String number) async {
    final Uri smsUri = Uri(scheme: 'sms', path: number);
    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else {
      throw 'Could not send message to $number';
    }
  }
}

class PaymentDetails {
  final String fullName;
  final String receiptNumber;
  final DateTime paymentDateTime;
  final double amount;
  final String address;

  PaymentDetails({
    required this.fullName,
    required this.receiptNumber,
    required this.paymentDateTime,
    required this.amount,
    required this.address,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      fullName: json['fullName'],
      receiptNumber: json['receiptNumber'],
      paymentDateTime: DateTime.parse(json['paymentDateTime']),
      amount: json['amount'],
      address: json['address'],
    );
  }
}

class DeliveryPartner {
  final String fullName;
  final String contactNumber;

  DeliveryPartner({required this.fullName, required this.contactNumber});

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      fullName: json['fullName'],
      contactNumber: json['contactNumber'],
    );
  }
}
