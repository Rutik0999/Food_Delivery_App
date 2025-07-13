import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api_constants.dart'; // Import the api_constants.dart file

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedAddressType = "Home";
  bool _isDefault = false;
  bool _isLoading = false;
  String? _userId;

  final List<String> addressTypes = ["Home", "Work", "Other"];

  // Updated API URL using ApiConstants.baseUrl
  final String apiUrl = '${ApiConstants.baseUrl}/api/FoodApp/AddUserAddress';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  bool _isFormValid() {
    return _userId != null &&
        _userId!.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _pincodeController.text.isNotEmpty;
  }

  Future<void> _saveAddress() async {
    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> requestBody = {
      "addressId": 0,
      "userId": _userId,
      "address": _addressController.text.trim(),
      "city": _cityController.text.trim(),
      "state": _stateController.text.trim(),
      "pincode": _pincodeController.text.trim(),
      "addressType": _selectedAddressType,
      "isDefault": _isDefault,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        _showSuccessDialog(responseData["message"]);
      } else {
        _showErrorDialog("Failed to add address. ${response.body}");
      }
    } catch (error) {
      _showErrorDialog("Network error: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            const Text("Success", style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return success flag
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(color: Colors.red)),
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Add Address", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// 🌈 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ✅ Prevent overflow using SingleChildScrollView
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(_addressController, "Address", Icons.location_on),
                      const SizedBox(height: 15),
                      _buildTextField(_cityController, "City", Icons.location_city),
                      const SizedBox(height: 15),
                      _buildTextField(_stateController, "State", Icons.map),
                      const SizedBox(height: 15),
                      _buildTextField(_pincodeController, "Pincode", Icons.pin, TextInputType.number),
                      const SizedBox(height: 20),
                      _buildDropdown(),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: Text("Set as Default Address", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                        value: _isDefault,
                        activeColor: Colors.lightBlueAccent,
                        onChanged: (bool value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAddressType,
      dropdownColor: Colors.black87,
      items: addressTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedAddressType = value!;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: _isFormValid() ? _saveAddress : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyan]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Save Address", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
