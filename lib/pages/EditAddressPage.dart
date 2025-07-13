import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api_constants.dart'; // ✅ your custom API constants

class EditAddressPage extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressPage({super.key, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedAddressType = 'Home';
  bool _isDefault = true;
  late AnimationController _animController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.address['address'] ?? '';
    _cityController.text = widget.address['city'] ?? '';
    _stateController.text = widget.address['state'] ?? '';
    _pincodeController.text = widget.address['pincode'] ?? '';
    _selectedAddressType = widget.address['addressType'] ?? 'Home';
    _isDefault = widget.address['isDefault'] ?? true;

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeInAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    final prefs = await SharedPreferences.getInstance();

    int? userId;
    final dynamic storedUserId = prefs.get('userId');
    if (storedUserId is int) {
      userId = storedUserId;
    } else if (storedUserId is String) {
      userId = int.tryParse(storedUserId);
    }

    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User ID not found")));
      return;
    }

    final Map<String, dynamic> updatedAddress = {
      "addressId": widget.address['addressId'],
      "userId": userId,
      "address": _addressController.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "pincode": _pincodeController.text,
      "addressType": _selectedAddressType,
      "isDefault": _isDefault,
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/EditUserAddress'); // ✅ Updated URL

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedAddress),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Success!",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              content: Text(
                "Address updated successfully.",
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return to previous page
                  },
                  child: Text("OK",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange)),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update address")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildAnimatedField(
      {required Widget child, required int delayInMs}) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + delayInMs),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        child: child,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orangeAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedAddressType,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category, color: Colors.deepOrange),
        labelText: "Address Type",
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orangeAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      style: GoogleFonts.poppins(color: Colors.black),
      items: ['Home', 'Work', 'Other'].map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type, style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedAddressType = value ?? 'Home';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      appBar: AppBar(
        title: Text("Edit Address",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        elevation: 5,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildAnimatedField(
                child: _buildTextField(_addressController, 'Address', Icons.home),
                delayInMs: 100,
              ),
              _buildAnimatedField(
                child: _buildTextField(_cityController, 'City', Icons.location_city),
                delayInMs: 200,
              ),
              _buildAnimatedField(
                child: _buildTextField(_stateController, 'State', Icons.map),
                delayInMs: 300,
              ),
              _buildAnimatedField(
                child: _buildTextField(_pincodeController, 'Pincode', Icons.pin),
                delayInMs: 400,
              ),
              _buildAnimatedField(
                child: _buildDropdownField(),
                delayInMs: 500,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? true;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                  Text("Set as default address",
                      style: GoogleFonts.poppins(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _updateAddress,
                icon: const Icon(Icons.save, color: Colors.deepOrange),
                label: Text("Save Changes",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
