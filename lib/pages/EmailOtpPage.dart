import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

import '../API/api_constants.dart';
import 'ForgotPasswordPage.dart';

class EmailOtpPage extends StatefulWidget {
  const EmailOtpPage({super.key});

  @override
  State<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends State<EmailOtpPage>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isOtpSent = false;
  bool isTimerRunning = false;
  bool showResendButton = false;
  int remainingTime = 120;

  Timer? countdownTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  void _startTimer() {
    setState(() {
      remainingTime = 120;
      showResendButton = false;
      isTimerRunning = true;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          isTimerRunning = false;
          showResendButton = true;
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showDialog('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/SendOtp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['result'] == true) {
        setState(() {
          isOtpSent = true;
        });
        _fadeController.forward();
        _startTimer();
        _showDialog("OTP Sent", "OTP has been successfully sent to $email.");
      } else {
        _showDialog("Error", responseBody['message'] ?? "Failed to send OTP.");
      }
    } else {
      _showDialog("Error", "Failed to send OTP. Try again.");
    }
  }

  Future<void> _verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/VerifyOtp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['result'] == true) {
        _showSuccessAnimation();
      } else {
        _showDialog("Error", responseBody['message'] ?? "Invalid OTP.");
      }
    } else {
      _showDialog("Error", "Server error. Try again later.");
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/Lottie/Success.json', height: 150),
            const SizedBox(height: 10),
            Text(
              "OTP Verified!",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordPage(email: emailController.text),
        ),
      );
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.deepPurple),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    countdownTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Lottie.asset('assets/Lottie/Otp.json', height: 220),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        "Email OTP Verification",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 500),
                        crossFadeState: isOtpSent
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _buildSendOtpSection(),
                        secondChild: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildVerifyOtpSection(),
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
    );
  }

  Widget _buildSendOtpSection() {
    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: "Enter your email",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _sendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text("Send OTP",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildVerifyOtpSection() {
    return Column(
      children: [
        Text("OTP sent to:", style: GoogleFonts.poppins(fontSize: 16)),
        Text(
          emailController.text,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: otpController,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 50,
            fieldWidth: 40,
            activeColor: Colors.deepPurple,
            selectedColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.deepPurple.shade100,
          ),
          animationDuration: const Duration(milliseconds: 300),
          onChanged: (value) {},
        ),
        const SizedBox(height: 10),

        if (isTimerRunning)
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            duration: Duration(seconds: remainingTime),
            builder: (context, value, child) {
              int totalSec = (remainingTime * value).ceil();
              final minutes = (totalSec ~/ 60).toString().padLeft(2, '0');
              final seconds = (totalSec % 60).toString().padLeft(2, '0');
              final color = Color.lerp(Colors.black, Colors.red, 1 - value);

              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOut,
                style: GoogleFonts.poppins(
                  fontSize: 15 + (5 * value),
                  fontWeight: FontWeight.w600,
                  color: color!,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: color.withOpacity(0.5),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Text("Resend available in $minutes:$seconds"),
              );
            },
          ),

        if (showResendButton)
          TextButton(
            onPressed: _sendOtp,
            child: Text(
              "Resend OTP",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text("Verify OTP",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }
}
