import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/like_button.dart';
import '../../widgets/story_options_sheet.dart';
import '../../utils/share_helper.dart';
import '../setting/followers_following_screen.dart';

class AuthorProfileScreen extends StatelessWidget {
  final String authorName;
  const AuthorProfileScreen({super.key, required this.authorName});

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
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
            const SizedBox(height: 20),
            // ── Profile Header ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 85 * scale,
                        height: 85 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/ratan_tata.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        authorName,
                        style: GoogleFonts.poppins(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowersFollowingScreen(title: 'Followers', isReadOnly: true),
                        ),
                      );
                    },
                    child: _buildStatItem('Followers', '50k', scale),
                  ),
                  SizedBox(width: 25 * scale),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowersFollowingScreen(title: 'Following', isReadOnly: true),
                        ),
                      );
                    },
                    child: _buildStatItem('Following', '15k', scale),
                  ),
                  SizedBox(width: 25 * scale),
                  _buildStatItem('Story', '10', scale),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(height: 25 * scale),

            // ── Action Buttons ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton('Follow', const Color(0xFF008BC1), Colors.white, scale),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ShareHelper.shareProfile(authorName, '@${authorName.toLowerCase()}');
                      },
                      child: _buildActionButton('Share Profile', Colors.grey.shade600, Colors.white, scale),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30 * scale),

            // ── Stories List ──
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              itemCount: 2, // Mock count
              itemBuilder: (context, index) {
                return _buildStoryCard(context, scale);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, double scale) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14 * scale,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, double scale) {
    return Container(
      margin: EdgeInsets.only(bottom: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image on the Left
              Image.asset(
                'assets/images/ratan_tata.png',
                width: 110 * scale,
                height: 110 * scale,
                fit: BoxFit.cover,
              ),
              // Content in the Middle
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '"Ratan Tata – A Great Life Shaped by Values."',
                        style: GoogleFonts.poppins(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 12 * scale, color: Colors.grey.shade400),
                          SizedBox(width: 4 * scale),
                          Text(
                            '3M',
                            style: GoogleFonts.poppins(
                              fontSize: 10 * scale,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Icon(Icons.favorite_border, size: 12 * scale, color: Colors.grey.shade400),
                          SizedBox(width: 4 * scale),
                          Text(
                            '1M',
                            style: GoogleFonts.poppins(
                              fontSize: 10 * scale,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Icons on the Right
              Padding(
                padding: EdgeInsets.all(8 * scale),
                child: Column(
                  children: [
                    LikeButton(
                      id: '"Ratan Tata – A Great Life Shaped by Values."', // Should be dynamic in real app
                      scale: scale,
                      showLabel: false,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => showStoryOptions(
                        context,
                        '"Ratan Tata – A Great Life Shaped by Values."',
                      ),
                      child: Icon(Icons.more_vert, color: Colors.black, size: 20 * scale),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
