import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _purple = Color(0xFF7C348D);
  static const _lightPurple = Color(0xFFF3E8F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy & Policy',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _lightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: _purple,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Privacy Matters',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Last updated: January 22, 2024',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Intro ─────────────────────────────────────────────
            Text(
              "We're committed to protecting your privacy. This policy explains how we handle your information.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 20),

            // ── Section 1 ─────────────────────────────────────────
            _buildSectionTitle('1. Information We Collect'),
            _buildBulletPoints([
              'Personal Info: Name, email when you provide it',
              'Usage Data: Stories read, time spent, preferences',
              'Device Info: Device type, OS version, identifiers',
            ]),

            const SizedBox(height: 16),

            // ── Section 2 ─────────────────────────────────────────
            _buildSectionTitle('2. How We Use Your Data'),
            _buildBulletPoints([
              'Provide and improve our services',
              'Personalize content recommendations',
              'Track reading history and progress',
              'Send notifications (with permission)',
              'Analyze usage to improve the app',
            ]),

            const SizedBox(height: 16),

            // ── Section 3 ─────────────────────────────────────────
            _buildSectionTitle('3. Data Security'),
            _buildParagraph(
              'We use industry-standard encryption (SSL/TLS) to protect your data. Your information is stored securely on our servers. While we can\'t guarantee 100% security, we take protection seriously.',
            ),

            const SizedBox(height: 16),

            // ── Section 4 ─────────────────────────────────────────
            _buildSectionTitle('4. Sharing & Your Rights'),
            _buildParagraph(
              "We keep your data as long as you use our service. Delete your account and we'll remove your data within 30 days (except where legally required). You can request data export anytime.",
            ),

            const SizedBox(height: 16),

            // ── Section 5 ─────────────────────────────────────────
            _buildSectionTitle('5. Contact Us'),
            _buildParagraph(
              'Questions about privacy? Contact us at privacy@truestory.com. We aim to respond within 48 hours.',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: _purple,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points
            .map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
