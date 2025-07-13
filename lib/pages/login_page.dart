import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_app_new/pages/advertisement_page.dart';
import 'signup_page.dart';
import 'package:food_app_new/pages/EmailOtpPage.dart';
import '../API/api_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isHovered = false;
  bool _obscurePassword = true;
  String _loginMessage = '📝 Please enter details above to Login.';


  final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  Future<void> saveUserData(String name, String email, String userId, String phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userId', userId);
    await prefs.setString('userPhone', phoneNumber);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loginMessage = '';
    });

    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/Login');
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> requestBody = {
      "email": _loginController.text.trim(),
      "passwordHash": _passwordController.text.trim(),
    };

    try {
      final httpClient = IOClient(_httpClient);
      final response = await httpClient.post(
        url, // ✅ Use this instead of loginUrl
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var userData = responseData['data'];
        await saveUserData(
          userData['fullName'],
          userData['email'],
          userData['userId'].toString(),
          userData['phoneNumber'],
        );

        setState(() {
          _loginMessage = "✅ ${responseData['message'] ?? 'Login Successful'}";
        });

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdvertisementPage()),
                (route) => false,
          );
        });
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? "Invalid credentials";
        } catch (e) {
          errorMessage = "Server error: Unable to parse response";
        }

        _showErrorDialog(errorMessage);
      }
    } catch (error) {
      _showErrorDialog("Unexpected error: $error");
    }

    setState(() => _isLoading = false);
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Failed"),
        content: Text(message),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepOrange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', height: 80),
                        const SizedBox(height: 10),

                        Text(
                          "Welcome Back!",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          "Login to continue",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _loginController,
                          decoration: InputDecoration(
                            labelText: 'Email or Mobile Number',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.person, color: Colors.deepOrange),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email or mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.lock, color: Colors.deepOrange),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        MouseRegion(
                          onEnter: (_) => setState(() => _isHovered = true),
                          onExit: (_) => setState(() => _isHovered = false),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHovered
                                  ? Colors.deepOrange.shade700
                                  : Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 80),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: _isHovered ? 10 : 4,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ✅ Forgot Password Link (no underline, but functional)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmailOtpPage()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.deepOrange,
                              decoration: TextDecoration.none, // Removed underline
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_loginMessage.isNotEmpty)
                          Text(
                            _loginMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _loginMessage.startsWith("✅") ? Colors.green : Colors.red,
                            ),
                          ),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          ),
                          child: Text(
                            "Don't have an account? Sign up",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
