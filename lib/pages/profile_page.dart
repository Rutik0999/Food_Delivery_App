import 'package:flutter/material.dart';
import 'package:food_app_new/components/my_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'edit_profile_page.dart';
import '../API/api_constants.dart'; // Import ApiConstants

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String _userName = '';
  String _userEmail = '';
  String? _userId;
  String _userPhone = ''; // ✅ Added phone number

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Guest User';
      _userEmail = prefs.getString('userEmail') ?? 'guest@example.com';
      _userId = prefs.getString('userId');
      _userPhone = prefs.getString('userPhone') ?? 'Not available'; // ✅ Load phone number
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _editProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User ID not found. Please log in again."),
            backgroundColor: Colors.red),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: _userName,
          email: _userEmail,
          userId: _userId!,
          phoneNumber: _userPhone, // ✅ Pass phone number to EditProfilePage
        ),
      ),
    );

    if (result != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', result['name']);
      await prefs.setString('userEmail', result['email']);
      await prefs.setString(
          'userPhone', result['phoneNumber']); // ✅ Save updated phone number

      setState(() {
        _userName = result['name'];
        _userEmail = result['email'];
        _userPhone = result['phoneNumber']; // ✅ Update UI with new phone number
      });

      // ✅ Show success message for profile update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not open URL"), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?',
            textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final SharedPreferences prefs =
              await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyDrawer()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ✅ Delete User Profile API Integration
  void _deleteUserProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User ID not found. Please log in again."),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Use the base URL from ApiConstants and append the endpoint
    final Uri url = Uri.parse('${ApiConstants.baseUrl}/api/FoodApp/DeleteUserProfile/$_userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Account deleted successfully"),
              backgroundColor: Colors.green),
        );

        // ✅ Wait for 2 seconds, then navigate
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyDrawer()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${response.body}"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to delete account: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text(
          '⚠️ Are you sure you want to delete your account? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUserProfile(); // ✅ Call delete API function
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) as ImageProvider
                      : const AssetImage('assets/images/Profile_png.1.png'),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.indigo,
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _userName,
                style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_userEmail,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text("📞 $_userPhone",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.edit, color: Colors.indigo),
                  title: const Text('Edit Profile'),
                  onTap: _editProfile,
                ),
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Account'),
                  onTap: _showDeleteConfirmation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
