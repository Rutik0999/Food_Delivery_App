import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class NetBankingPage extends StatefulWidget {
  const NetBankingPage({super.key, required double amount});

  @override
  State<NetBankingPage> createState() => _NetBankingPageState();
}

class _NetBankingPageState extends State<NetBankingPage> {
  String? selectedBank;

  final List<String> banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text('Net Banking', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Lottie.asset('assets/Lottie/bank transaction.json', height: 200),
          const SizedBox(height: 20),
          Text("Select Your Bank", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: banks.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: RadioListTile<String>(
                    value: banks[index],
                    groupValue: selectedBank,
                    title: Text(banks[index], style: GoogleFonts.poppins(fontSize: 16)),
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: selectedBank == null
                ? null
                : () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Payment Successful"),
                  content: Text("Your payment through $selectedBank is confirmed."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.popUntil(context, ModalRoute.withName("/")),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.payment),
            label: Text("Pay with Bank", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
