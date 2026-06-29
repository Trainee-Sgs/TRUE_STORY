import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_access_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C348D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Premium',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Image ─────────────────────────────────────────────
            Image.asset(
              'assets/images/prem_boy.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),

            // ── Subscription Options ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Column(
                children: [
                  // Most Popular Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C348D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8 * scale),
                        topRight: Radius.circular(8 * scale),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Most Popular',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Annual Pack Card
                  Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Annual',
                                style: GoogleFonts.poppins(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 14 * scale,
                                    color: Colors.grey.shade400,
                                  ),
                                  children: [
                                    const TextSpan(text: '3 days Free  trail, then \n'),
                                    TextSpan(
                                      text: '1999.00',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '166 INR/ Mon',
                          style: GoogleFonts.poppins(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16 * scale),

                  // Monthly Pack Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly',
                          style: GoogleFonts.poppins(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '199 INR/ Mon',
                          style: GoogleFonts.poppins(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24 * scale),

            // ── Features List ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get motivated anywhere with',
                    style: GoogleFonts.poppins(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _buildFeatureItem('Access to 500+ True Story', scale),
                  _buildFeatureItem('Unlimited ad-free Stories , videos', scale),
                  _buildFeatureItem('Offline Reading', scale),
                  _buildFeatureItem('Alarm clock & Remainders', scale),
                ],
              ),
            ),

            SizedBox(height: 30 * scale),

            // ── Get Pack Button ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PremiumAccessScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C348D),
                  minimumSize: Size(double.infinity, 50 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
                child: Text(
                  'Get True Story Elite Pack',
                  style: GoogleFonts.poppins(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      child: Row(
        children: [
          Image.asset(
            'assets/images/arrow.png',
            width: 18 * scale,
            height: 18 * scale,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
