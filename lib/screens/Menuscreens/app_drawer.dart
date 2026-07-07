import 'package:flutter/material.dart';
import '../OnboardingScreen/login_screen.dart' show LoginScreen;
import 'terms_screen.dart';
import 'privacy_screen.dart';
import 'feedback_screen.dart';
import 'history_screen.dart';
import 'notification_screen.dart';
import '../setting/downloads_screen.dart';
import '../../shared_preference.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _purple = Color(0xFF7C348D);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // ── Purple Header ────────────────────────────────────────
          Container(
            width: double.infinity,
            color: _purple,
            padding: const EdgeInsets.fromLTRB(20, 50, 12, 20),
            child: Row(
              children: [
                // Logo
                Expanded(
                  child: Image.asset(
                    'assets/images/Trustory logo horizontal home screen.png',
                    height: 38,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                // Close (X) button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _purple, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: _purple,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Items ───────────────────────────────────────────
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Notifications
                  _buildItem(
                    context: context,
                    iconPath: 'assets/images/bell.png',
                    label: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),

                  // Terms and Conditions
                  _buildItem(
                    context: context,
                    iconPath: 'assets/images/term.png',
                    label: 'Terms and Conditions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),

                  // Privacy and Policy
                  _buildItem(
                    context: context,
                    iconPath: 'assets/images/privacy.png',
                    label: 'Privacy and Policy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),

                  // History
                  _buildItem(
                    context: context,
                    iconPath: 'assets/images/history.png',
                    label: 'History',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),

                  // Downloads
                  _buildItem(
                    context: context,
                    iconPath: 'assets/images/bell.png', // Using bell as fallback or check for download icon
                    label: 'Downloads',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DownloadsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),

                  // Feedback
                  _buildItem(
                    context: context,
                    iconPath: 'assets/images/feedback.png',
                    label: 'Feedback',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedbackScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Logout Button ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Drawer Item ─────────────────────────────────────────────────────────
  static Widget _buildItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF7C348D).withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.circle_outlined,
                size: 24,
                color: Color(0xFF7C348D),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Divider ──────────────────────────────────────────────────────────────
  static Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Color(0xFFEEEEEE),
    );
  }
  // ── Logout Dialog ────────────────────────────────────────────────────────
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
              // Title
              const Text(
                'Logout Account ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              // Subtitle
              const Text(
                'Are you sure want to logout your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons Row
              Row(
                children: [
                  // No Button
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
                  // Yes Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Close dialog and drawer, clear session, then navigate to login
                        await SessionManager.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                        backgroundColor: const Color(0xFFE52D27), // Red color
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
}
