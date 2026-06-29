import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumAccessScreen extends StatefulWidget {
  const PremiumAccessScreen({super.key});

  @override
  State<PremiumAccessScreen> createState() => _PremiumAccessScreenState();
}

class _PremiumAccessScreenState extends State<PremiumAccessScreen> {
  int _selectedIndex = 0; // Default to first plan

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
            // ── Hero Image & Card ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16 * scale),
                  child: Image.asset(
                    'assets/images/prem_access.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // ── Features List ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Column(
                children: [
                  _buildFeatureItem('Access to 500+ True Story', scale),
                  _buildFeatureItem('Unlimited ad-free Stories', scale),
                  _buildFeatureItem('Offline Reading', scale),
                  _buildFeatureItem('Alarm clock & Remainders', scale),
                ],
              ),
            ),

            SizedBox(height: 20 * scale),

            // ── Subscription Grid ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15 * scale,
                crossAxisSpacing: 15 * scale,
                childAspectRatio: 0.9,
                children: [
                  _buildPlanCard(0, 'Monthly', '199', 'Billed Monthly', scale, isPopular: true),
                  _buildPlanCard(1, '3 Months', '549', 'Free 1 Week', scale, isPopular: true),
                  _buildPlanCard(2, '6 Months', '1059', 'Free 1 Week', scale),
                  _buildPlanCard(3, '9 Months', '1759', 'Free 1 Week', scale),
                  _buildPlanCard(4, '365 Days', '2299', 'Free 1 Week', scale),
                  _buildPlanCard(5, '24 Months', '4749', 'Free 1 Week', scale),
                ],
              ),
            ),
            SizedBox(height: 30 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scale),
      child: Row(
        children: [
          Icon(Icons.check, color: const Color(0xFF7C348D), size: 18 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index, String title, String price, String subtitle, double scale, {bool isPopular = false}) {
    final bool isSelected = _selectedIndex == index;
    final Color primaryColor = const Color(0xFF7C348D);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        _showPaymentBottomSheet(context, scale);
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? primaryColor.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16 * scale,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? primaryColor : Colors.black,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹ ',
                      style: GoogleFonts.poppins(
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? primaryColor : Colors.black,
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 32 * scale,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? primaryColor : Colors.black,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20 * scale,
                      color: isSelected ? primaryColor : Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(12 * scale)),
                child: SizedBox(
                  width: 70 * scale,
                  height: 70 * scale,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10 * scale,
                        right: -20 * scale,
                        child: Transform.rotate(
                          angle: 0.785, // 45 degrees
                          child: Container(
                            width: 100 * scale,
                            height: 22 * scale,
                            color: primaryColor,
                            alignment: Alignment.center,
                            child: Text(
                              'Popular',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPaymentBottomSheet(BuildContext context, double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35 * scale),
            topRight: Radius.circular(35 * scale),
          ),
        ),
        padding: EdgeInsets.fromLTRB(26 * scale, 36 * scale, 26 * scale, 30 * scale),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Payment Method to your google account',
                style: GoogleFonts.poppins(
                  fontSize: 19 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'tamilarasisgs@gmail.com',
                style: GoogleFonts.poppins(
                  fontSize: 15 * scale,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 18 * scale),
              Text(
                'Add Payment Method to your google account to start your free trail.You Won\'t be charger if you cancel before jan 20,2026',
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.45,
                ),
              ),
              SizedBox(height: 28 * scale),
              
              // Add Card Option
              _buildPaymentOption(
                customIcon: Image.asset(
                  'assets/images/wallet.png',
                  width: 30 * scale,
                  height: 30 * scale,
                  fit: BoxFit.contain,
                ),
                label: 'Add Card',
                logos: [
                  {'image': 'assets/images/visa.png', 'width': 30 * scale},
                  {'image': 'assets/images/mastercard.png', 'width': 22 * scale},
                ],
                scale: scale,
              ),
              
              SizedBox(height: 16 * scale),
              
              // UPI Option
              _buildPaymentOption(
                label: 'Pay With UPI',
                customIcon: Image.asset(
                  'assets/images/upi.png',
                  width: 32 * scale,
                  height: 32 * scale,
                  fit: BoxFit.contain,
                ),
                logos: [
                  {'image': 'assets/images/g_pay.png', 'width': 35 * scale},
                  {'image': 'assets/images/phonepe.png', 'width': 40 * scale},
                ],
                scale: scale,
              ),
              
              SizedBox(height: 16 * scale),
              
              // Redeem Code Option
              _buildPaymentOption(
                label: 'Redeem Code',
                customIcon: Image.asset(
                  'assets/images/play-store.png',
                  width: 28 * scale,
                  height: 28 * scale,
                  fit: BoxFit.contain,
                ),
                scale: scale,
              ),
              SizedBox(height: 12 * scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    Widget? customIcon,
    required String label,
    List<Map<String, dynamic>>? logos,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 38 * scale,
                  child: Center(child: customIcon),
                ),
                SizedBox(width: 14 * scale),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (logos != null) ...[
            SizedBox(width: 8 * scale),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var logo in logos) ...[
                  if (logo['image'] != null)
                    Image.asset(
                      logo['image'],
                      width: (logo['width'] ?? 24.0),
                      fit: BoxFit.contain,
                    )
                  else if (logo['text'] != null)
                    Text(
                      logo['text'],
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: logo['bold'] == true ? FontWeight.bold : FontWeight.w500,
                        fontStyle: logo['italic'] == true ? FontStyle.italic : FontStyle.normal,
                        color: logo['color'] ?? Colors.black54,
                      ),
                    )
                  else if (logo['icon'] != null)
                    Padding(
                      padding: EdgeInsets.only(right: 1 * scale),
                      child: Icon(logo['icon'], size: 7 * scale, color: logo['color']),
                    ),
                  SizedBox(width: 8 * scale),
                ],
                Text(
                  '+ More',
                  style: GoogleFonts.poppins(
                    fontSize: 11 * scale,
                    color: const Color(0xFF1D1B20).withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
