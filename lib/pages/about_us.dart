import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOut,
    ));

    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(IconData icon, String valueTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent),
          const SizedBox(width: 10),
          Text(
            valueTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon(String assetPath, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage(assetPath),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _fadeAnimation == null || _slideAnimation == null
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
            opacity: _fadeAnimation!,
            child: SlideTransition(
              position: _slideAnimation!,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Text(
                          'About Us',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Image.asset('assets/images/logo.png', height: 100),
                    const SizedBox(height: 16),
                    const Text(
                      'Foodie Delivery',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Delivering delicious meals at your doorstep, quickly and reliably.',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'At Foodie Delivery, we strive to bring a variety of meals from the best local restaurants straight to your door. With a user-friendly app and quick service, we aim to provide an exceptional dining experience from the comfort of your home.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'To make dining convenient and enjoyable by connecting people to their favorite restaurants through fast and efficient delivery service.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Our Values',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildValueRow(Icons.fastfood, 'Quality'),
                    _buildValueRow(Icons.delivery_dining, 'Fast Delivery'),
                    _buildValueRow(Icons.thumb_up, 'Customer Satisfaction'),
                    _buildValueRow(Icons.local_dining, 'Supporting Local Businesses'),
                    const SizedBox(height: 20),
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildContactRow(Icons.email, 'support@foodiedelivery.com'),
                    _buildContactRow(Icons.phone, '+1 800 123 4567'),
                    const SizedBox(height: 20),
                    const Text(
                      'Follow Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialMediaIcon(
                            'assets/images/facebook.png', 'https://www.facebook.com/'),
                        const SizedBox(width: 16),
                        _buildSocialMediaIcon('assets/images/twitter.png',
                            'https://www.twitter.com/foodiedelivery'),
                        const SizedBox(width: 16),
                        _buildSocialMediaIcon('assets/images/instagram.png',
                            'https://www.instagram.com/foodiedelivery'),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
