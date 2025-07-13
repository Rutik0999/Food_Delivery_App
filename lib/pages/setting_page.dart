import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_app_new/pages/about_us.dart';
import 'package:food_app_new/components/my_drawer.dart';
import 'package:food_app_new/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the theme provider instance
    final themeProvider = Provider.of<ThemeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // Show success message before navigating
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Setting Updated Successfully"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Delay navigation until the SnackBar is shown completely
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyDrawer()),
        );


        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                title: "Dark Mode",
                isSwitch: true,
                switchValue: themeProvider.isDarkMode,
                onToggle: (value) => themeProvider.toggleTheme(),
              ),
              _buildSettingItem(
                context,
                title: "Notifications",
                isSwitch: true,
                switchValue: true,
                onToggle: (value) {
                  // Add logic for toggling notifications
                },
              ),
              _buildSettingItem(
                context,
                title: "Language",
                isSwitch: false,
                onTap: () {
                  // Add navigation to language selection screen
                },
              ),
              _buildSettingItem(
                context,
                title: "Location Services",
                isSwitch: true,
                switchValue: true,
                onToggle: (value) {
                  // Add logic for toggling location services
                },
              ),
              _buildSettingItem(
                context,
                title: "About Us",
                isSwitch: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required String title,
        bool isSwitch = false,
        bool switchValue = false,
        Function(bool)? onToggle,
        Function()? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            if (isSwitch)
              CupertinoSwitch(
                value: switchValue,
                onChanged: onToggle,
              ),
            if (!isSwitch)
              Icon(Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.inversePrimary),
          ],
        ),
      ),
    );
  }
}
