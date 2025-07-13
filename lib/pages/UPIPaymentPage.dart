import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:food_app_new/pages/advertisement_page.dart';

class UPIPaymentPage extends StatelessWidget {
  const UPIPaymentPage({super.key, required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Attractive gradient background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEEE9FF),
              Color(0xFFD1C4E9),
              Color(0xFFB39DDB),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Lottie animation
                Center(
                  child: Lottie.asset(
                    'assets/Lottie/upi payment.json',
                    height: 250,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  "Scan to Pay",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),

                const SizedBox(height: 20),

                // QR Code Card
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/Rutik_QR.jpg',
                            height: 250,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "UPI ID: foodiezone@okhdfcbank",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 30),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 24),
                          label: Text(
                            "Mark as Paid",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                title: Text(
                                  "✅ Payment Success",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  "Your UPI payment of ₹${amount.toStringAsFixed(2)} has been received.",
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close dialog
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => AdvertisementPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "OK",
                                      style: GoogleFonts.poppins(color: Colors.deepPurple),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
