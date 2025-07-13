import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:food_app_new/components/my_button.dart';
import 'package:food_app_new/pages/delivery_progress_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../API/api_constants.dart'; // Import the API constants

class PaymentPage extends StatefulWidget {
  final double amount;
  final int userId;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.userId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<int?> savePayment() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/SavePayment'); // Use the base URL from ApiConstants

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'amount': widget.amount,
          'paymentMethod': 'Card',
          'paymentStatus': 'Success',
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final paymentId = jsonData['paymentId'];
        print('✅ Payment saved, ID: $paymentId');
        return paymentId;
      } else {
        print('❌ Failed to save payment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving payment: $e');
    }

    return null;
  }

  void userTappedPay() async {
    print("🟡 Pay button tapped");

    if (formKey.currentState!.validate()) {
      print("🟢 Form validated");

      final paymentId = await savePayment();

      if (paymentId != null && mounted) {
        print('🚀 Redirecting to DeliveryProgressPage with paymentId: $paymentId');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DeliveryProgressPage(paymentId: paymentId),
          ),
        );
      } else {
        print('🔴 Payment failed or paymentId is null');
      }
    } else {
      print("🔴 Credit card form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEAFB), // Pleasant background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
        title: const Text("Card Payment"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌈 Animation with smooth rounded transparent background
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius:  BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
                child: Lottie.asset(
                  'assets/Lottie/card payment.json',
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 💳 Card Input Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CreditCardWidget(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                    cardBgColor: Colors.deepPurple.shade400,
                    textStyle: const TextStyle(color: Colors.white),
                    onCreditCardWidgetChange: (CreditCardBrand brand) {},
                  ),
                  CreditCardForm(
                    formKey: formKey,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    obscureCvv: true,
                    obscureNumber: true,
                    onCreditCardModelChange: (data) {
                      setState(() {
                        cardNumber = data.cardNumber;
                        expiryDate = data.expiryDate;
                        cardHolderName = data.cardHolderName;
                        cvvCode = data.cvvCode;
                        isCvvFocused = data.isCvvFocused;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🎨 Gradient Payment Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                child: MyButton(
                  text: "Pay ₹${widget.amount.toStringAsFixed(2)}",
                  onTap: userTappedPay,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
