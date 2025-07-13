import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'package:food_app_new/pages/user_address_page.dart';
import 'package:food_app_new/pages/EditAddressPage.dart';
import 'package:food_app_new/pages/UPIPaymentPage.dart';
import 'package:food_app_new/pages/NetBankingPage.dart';
import 'package:food_app_new/pages/CashOnDeliveryPage.dart';
import 'package:food_app_new/pages/payment_page.dart';

// API Constants
import '../API/api_constants.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final double cartTotal;

  const PaymentConfirmationPage({super.key, required this.cartTotal});

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> with SingleTickerProviderStateMixin {
  String selectedPayment = 'UPI';
  Map<String, dynamic>? userAddress;
  int? userId;

  double get gst => widget.cartTotal * 0.05;
  double get deliveryCharge => 50.0;
  double get finalAmount => widget.cartTotal + gst + deliveryCharge;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _loadUserIdAndFetchAddress();
  }

  Future<void> _loadUserIdAndFetchAddress() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userId')) {
      final dynamic storedUserId = prefs.get('userId');
      if (storedUserId is int) {
        userId = storedUserId;
      } else if (storedUserId is String) {
        userId = int.tryParse(storedUserId);
      }
    }
    if (userId != null) {
      await _fetchUserAddresses(userId!);
    }
  }

  Future<void> _fetchUserAddresses(int userId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/GetUserAddresses/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] as List<dynamic>;

        if (data.isNotEmpty) {
          setState(() {
            userAddress = data.firstWhere(
                  (addr) => addr['isDefault'] == true,
              orElse: () => data[0],
            );
          });
        }
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
  }

  void _navigateToAddressPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => userAddress != null
            ? EditAddressPage(address: userAddress!)
            : const AddAddressPage(),
      ),
    );

    if (result == true && userId != null) {
      await _fetchUserAddresses(userId!);
    }
  }

  void _confirmPayment() {
    if (userAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add an address first")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Payment", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          "Do you want to confirm and proceed with the payment?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _proceedToPayment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: Text("Confirm", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    switch (selectedPayment) {
      case 'UPI':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => UPIPaymentPage(amount: finalAmount),
        ));
        break;
      case 'Card':
        if (userId != null) {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                amount: finalAmount,
                userId: userId!, // ✅ Pass the userId here
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found. Please log in again.")),
          );
        }
        break;

      case 'Net Banking':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => NetBankingPage(amount: finalAmount),
        ));
        break;
      case 'Cash on Delivery':
        if (userId != null) {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => CashOnDeliveryPage(
                amount: finalAmount,
                userId: userId!, // ✅ Pass the userId here
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found. Please log in again.")),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF9F4),
        appBar: AppBar(
          title: Text("Confirm & Pay", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepOrange,
          elevation: 5,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildAnimatedCard(
                title: "Delivery Address",
                icon: Icons.location_on,
                gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                child: userAddress != null
                    ? Text(
                  "${userAddress!['address']}, ${userAddress!['city']} - ${userAddress!['pincode']}\nType: ${userAddress!['addressType']}",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                )
                    : Text("No address found", style: GoogleFonts.poppins(color: Colors.white)),
                buttonLabel: userAddress != null ? "Edit Address" : "Add Address",
                onPressed: _navigateToAddressPage,
                buttonColor: userAddress != null ? Colors.green : Colors.blue,
              ),
              _buildAnimatedCard(
                title: "Select Payment Mode",
                icon: Icons.payment,
                gradient: const LinearGradient(colors: [Colors.tealAccent, Colors.teal]),
                child: Column(
                  children: [
                    _buildPaymentRadio("UPI", Icons.qr_code),
                    _buildPaymentRadio("Card", Icons.credit_card),
                    _buildPaymentRadio("Net Banking", Icons.account_balance),
                    _buildPaymentRadio("Cash on Delivery", Icons.money),
                  ],
                ),
              ),
              _buildAnimatedCard(
                title: "Bill Summary",
                icon: Icons.receipt_long,
                gradient: const LinearGradient(colors: [Colors.indigoAccent, Colors.indigo]),
                child: Column(
                  children: [
                    _buildAmountRow("Cart Total", widget.cartTotal),
                    _buildAmountRow("GST (5%)", gst),
                    _buildAmountRow("Delivery Charge", deliveryCharge),
                    const Divider(thickness: 1, color: Colors.white),
                    _buildAmountRow("Final Total", finalAmount, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _confirmPayment,
                icon: const Icon(Icons.check_circle_outline),
                label: Text("Confirm Payment",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required String title,
    required Widget child,
    required IconData icon,
    required Gradient gradient,
    String? buttonLabel,
    VoidCallback? onPressed,
    Color? buttonColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          child,
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonLabel, style: GoogleFonts.poppins(color: Colors.white)),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPaymentRadio(String label, IconData icon) {
    return RadioListTile<String>(
      value: label,
      groupValue: selectedPayment,
      onChanged: (value) {
        setState(() {
          selectedPayment = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
        ],
      ),
      activeColor: Colors.white,
    );
  }

  Widget _buildAmountRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("₹${amount.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
