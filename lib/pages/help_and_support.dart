import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportPage extends StatefulWidget {
  @override
  _HelpAndSupportPageState createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ));

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.forward();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $callUri';
    }
  }

  Future<void> _startLiveChat() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '9948542555',
      queryParameters: <String, String>{
        'body': Uri.encodeComponent("Hello, I need help with my order.")
      },
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'Could not open chat';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Card(
      color: Colors.white.withOpacity(0.95),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        iconColor: Colors.indigo,
        collapsedIconColor: Colors.indigo,
        title: Text(
          question,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.95),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Help & Support',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1FA2FF), Color(0xFF12D8FA), Color(0xFFA6FFCB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help you?',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Find answers to common questions or contact our support team.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '🧠 Frequently Asked Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // FAQ Tiles
                  _buildFaqTile(
                    question: 'How can I track my order?',
                    answer:
                    'Once your order is placed, you can track it in real-time under the "My Orders" section.',
                  ),
                  _buildFaqTile(
                    question: 'What should I do if my order is delayed?',
                    answer:
                    'You can contact our support team through the app to inquire about delays.',
                  ),
                  _buildFaqTile(
                    question: 'How do I cancel an order?',
                    answer:
                    'Go to the "My Orders" section, select the order, and click on "Cancel Order."',
                  ),

                  const SizedBox(height: 30),
                  Text(
                    '📞 Contact Support',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Contact Cards
                  _buildSupportTile(
                    icon: Icons.email,
                    iconColor: Colors.orange,
                    title: 'Email Us',
                    subtitle: 'support@fooddeliveryapp.com',
                    onTap: () {
                      // Launch email logic
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'support@fooddeliveryapp.com',
                        query:
                        'subject=Support Request&body=Hello, I need help with...',
                      );
                      launchUrl(emailUri);
                    },
                  ),
                  _buildSupportTile(
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    title: 'Call Us',
                    subtitle: '9948542555',
                    onTap: () => _makePhoneCall('9948542555'),
                  ),
                  _buildSupportTile(
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.purple,
                    title: 'Chat with Us',
                    subtitle: 'Start a live chat with our support team',
                    onTap: _startLiveChat,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
