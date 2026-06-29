import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
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
                      Icons.balance,
                      color: _purple,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legal Agreement',
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
              'By using True Story, you agree to these terms. Please read them carefully.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 20),

            // ── Sections ──────────────────────────────────────────
            _buildSection(
              number: '1.',
              title: 'Use of Service',
              body:
                  'We grant you a personal, non-commercial license to use True Story. You may not reproduce, distribute, or modify our content without permission. You\'re responsible for maintaining account security.',
            ),
            _buildSection(
              number: '2.',
              title: 'Content Ownership',
              body:
                  'All content is owned by True Story and protected by copyright. Stories are based on real journeys but may be modified for educational purposes.',
            ),
            _buildSection(
              number: '3.',
              title: 'Disclaimer',
              body:
                  'Stories are for educational purposes only. Results vary and we don\'t guarantee business success or financial outcomes. Use our app "as is" without warranties.',
            ),
            _buildSection(
              number: '4.',
              title: 'Changes & Termination',
              body:
                  'We may update these terms anytime. We can terminate access for terms violations. Continued use means you accept changes.',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numbered title
          Text(
            '$number $title',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _purple,
            ),
          ),
          const SizedBox(height: 6),
          // Body
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              body,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
