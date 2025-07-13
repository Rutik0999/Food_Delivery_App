import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:food_app_new/pages/login_page.dart';
import '../API/api_constants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Allow self-signed SSL
  final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  // Function to show alert with icon
  void _showAlertDialog({required String title, required String message, required IconData icon, required Color iconColor}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontFamily: 'Poppins')),
          ],
        ),
        content: Text(message, style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/SignUp');
    final Map<String, String> headers = {"Content-Type": "application/json"};

    final Map<String, dynamic> requestBody = {
      "fullName": _nameController.text.trim(),
      "profileImage": "",
      "email": _emailController.text.trim(),
      "phoneNumber": _mobileController.text.trim(),
      "passwordHash": _passwordController.text.trim(),
    };

    try {
      IOClient ioClient = IOClient(_httpClient);
      final response = await ioClient.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showAlertDialog(
          title: "Success",
          message: "Account Created Successfully",
          icon: Icons.check_circle,
          iconColor: Colors.green,
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      } else {
        _showAlertDialog(
          title: "Error",
          message: responseData["message"] ?? "Sign Up Failed",
          icon: Icons.warning,
          iconColor: Colors.red,
        );
      }
    } catch (error) {
      // Check if error is a FormatException and display custom message
      if (error is FormatException) {
        _showAlertDialog(
          title: "Error",
          message: "Email already exists",
          icon: Icons.warning,
          iconColor: Colors.red,
        );
      } else {
        _showAlertDialog(
          title: "Error",
          message: "Something went wrong: ${error.toString()}",
          icon: Icons.warning,
          iconColor: Colors.red,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) => value!.trim().isEmpty
                            ? 'Please enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) return 'Please enter your email';
                          if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim())) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) return 'Please enter your mobile number';
                          if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) return 'Please enter a valid 10-digit mobile number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage())),
                  child: const Text('Already have an account? Log in',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
