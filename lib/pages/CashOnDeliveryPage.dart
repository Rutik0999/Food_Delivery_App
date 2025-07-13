import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'delivery_progress_page.dart';
import 'package:animate_do/animate_do.dart';
import '../API/api_constants.dart';

class CashOnDeliveryPage extends StatefulWidget {
  final double amount;
  final int userId;

  const CashOnDeliveryPage({
    Key? key,
    required this.amount,
    required this.userId,
  }) : super(key: key);

  @override
  State<CashOnDeliveryPage> createState() => _CashOnDeliveryPageState();
}

class _CashOnDeliveryPageState extends State<CashOnDeliveryPage> {
  bool isPlacingOrder = false;

  Future<int?> savePayment() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/SavePayment');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'amount': widget.amount,
          'paymentMethod': 'Cash on Delivery',
          'paymentStatus': 'Success',
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final paymentId = jsonData['paymentId'];
        return paymentId;
      } else {
        final message = json.decode(response.body);
        if (message['message'] == 'Email already exists') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email already exists.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong.")),
          );
        }
      }
    } catch (e) {
      print('❌ Error saving payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong.")),
      );
    }

    return null;
  }

  void confirmCashOrder() async {
    setState(() {
      isPlacingOrder = true;
    });

    final paymentId = await savePayment();

    if (paymentId != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryProgressPage(paymentId: paymentId),
        ),
      );
    } else {
      setState(() {
        isPlacingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                FadeInDown(
                  child: Lottie.asset(
                    'assets/Lottie/Cash.json',
                    height: 200,
                  ),
                ),
                const SizedBox(height: 20),
                FadeIn(
                  duration: const Duration(milliseconds: 600),
                  child: GlassContainer(
                    child: Column(
                      children: [
                        Text(
                          "Confirm Cash on Delivery",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Amount Payable: ₹${widget.amount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        isPlacingOrder
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                          onPressed: confirmCashOrder,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Confirm Order"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
