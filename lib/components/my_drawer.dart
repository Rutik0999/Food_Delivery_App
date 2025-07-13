import 'package:flutter/material.dart';
import 'package:food_app_new/pages/MyOrdersPage.dart';
import 'package:food_app_new/pages/advertisement_page.dart';
import 'package:food_app_new/pages/cart.dart';
import 'package:food_app_new/pages/help_and_support.dart';
import 'package:food_app_new/pages/login_page.dart';
import 'package:food_app_new/pages/about_us.dart';
import 'package:food_app_new/pages/setting_page.dart';
import 'package:food_app_new/pages/profile_page.dart';
import 'package:food_app_new/pages/user_address_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:io';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  File? _profileImage;
  String _userName = "Guest";
  String _userEmail = "guest@example.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Guest";
      _userEmail = prefs.getString('userEmail') ?? "guest@example.com";
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ✅ Stylish Logout Popup using AwesomeDialog
  void _showLogoutPopup() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: "Logout",
      desc: "Are you sure you want to logout?",
      btnCancelText: "Cancel",
      btnCancelColor: Colors.grey,
      btnOkText: "Logout",
      btnOkColor: Colors.red,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged out successfully!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.deepOrange,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              image: DecorationImage(
                image: AssetImage('assets/images/Baground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/Profile.jpg')
                    as ImageProvider,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home, color: Colors.deepOrange),
            title: const Text(
              'Home',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdvertisementPage(
                        showSuccessMessage: true,
                        message: "Hello $_userName, place your order!",
                      )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.deepOrange),
            title: const Text(
              'Profile',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.deepOrange),
            title: const Text(
              'My Orders',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyOrdersPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.deepOrange),
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.deepOrange), // Use a valid icon
            title: const Text(
              'Add User Address',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAddressPage()), // Corrected page name
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.deepOrange),
            title: const Text(
              'Help & Support',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpAndSupportPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.deepOrange),
            title: const Text(
              'About',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()));
            },
          ),
          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
                fontFamily: 'Poppins',
              ),
            ),
            onTap: _showLogoutPopup, // ✅ Trigger stylish popup
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
