import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_screen.dart';
import 'like_screen.dart';
import 'downloads_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../Category/category_screen.dart';
import '../For_You/for_you_screen.dart';
import '../OnboardingScreen/login_screen.dart';
import '../../utils/share_helper.dart';

import '../../widgets/language_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;

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
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile Banner Card ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Container(
                width: double.infinity,
                height: 120 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/Rectangle.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Row(
                    children: [
                      // Profile Image
                      Container(
                        width: 70 * scale,
                        height: 70 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?u=sowmiya'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 15 * scale),
                      // User Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sowmiya',
                              style: GoogleFonts.poppins(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '9488566544',
                              style: GoogleFonts.poppins(
                                fontSize: 13 * scale,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Icon
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: Padding(
                      //     padding: EdgeInsets.only(top: 15 * scale),
                      //     child: Icon(
                      //       Icons.edit_outlined,
                      //       color: Colors.white,
                      //       size: 20 * scale,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Settings List ──────────────────────────────────────────────
            _buildToggleItem(
              Icons.dark_mode_outlined,
              'Dark Mode',
              _isDarkMode,
              (val) => setState(() => _isDarkMode = val),
              scale,
            ),
            _buildToggleItem(
              Icons.notifications_none_outlined,
              'Notification',
              _isNotificationEnabled,
              (val) => setState(() => _isNotificationEnabled = val),
              scale,
            ),
            GestureDetector(
              onTap: () => LanguageDialog.show(context, scale),
              child: _buildListItem(Icons.language, 'Change App Language', scale, showChevron: false),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LikeScreen()),
                );
              },
              child: _buildListItem(Icons.favorite_border, 'Like', scale),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DownloadsScreen()),
                );
              },
              child: _buildListItem(Icons.download_for_offline_outlined, 'Downloads', scale),
            ),
            // _buildListItem(Icons.settings_outlined, 'Settings', scale),
            GestureDetector(
              onTap: () {
                ShareHelper.shareStory(
                  'True Story App',
                  'Checkout this amazing "True Story" app to read real-life stories!',
                );
              },
              child: _buildListItem(Icons.share_outlined, 'Share App', scale, showChevron: false),
            ),
            
            // Premium Item
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                );
              },
              child: _buildListItem(
                Icons.stars_outlined, 
                'GET PREMIUM', 
                scale,
                textColor: const Color(0xFFFFD700),
                iconColor: const Color(0xFFFFD700),
              ),
            ),

            SizedBox(height: 30 * scale),

            // ── Logout Button ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40 * scale),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C348D),
                  minimumSize: Size(double.infinity, 45 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30 * scale),
                  ),
                ),
                child: Text(
                  'LOG OUT',
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
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3, // Highlight "Settings"
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: const CategoryScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: const ForYouScreen()),
            );
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Logout Account ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Are you sure want to logout your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52D27),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String label, bool value, Function(bool) onChanged, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22 * scale, color: Colors.black87),
          SizedBox(width: 15 * scale),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14 * scale,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C348D),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String label, double scale, {bool showChevron = true, Color? textColor, Color? iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 15 * scale),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22 * scale, color: iconColor ?? Colors.black87),
          SizedBox(width: 15 * scale),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14 * scale,
              color: textColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (showChevron)
            Icon(Icons.chevron_right, size: 20 * scale, color: Colors.grey),
        ],
      ),
    );
  }
}
