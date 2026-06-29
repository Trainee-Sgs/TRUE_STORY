import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_detail_screen.dart';
import '../../utils/guest_manager.dart';
import '../OnboardingScreen/login_screen.dart';
import 'popular_view.dart';
import 'recommend_view.dart';
import '../../widgets/story_options_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C348D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Search',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEFFF),
                  borderRadius: BorderRadius.circular(30 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14 * scale,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 15 * scale,
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8 * scale),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C348D),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Recommended For You ──────────────────────────────
            _buildSectionHeader('Recommended For You', scale, showViewAll: true),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPopularCard(
                      image: 'assets/images/ratan_tata.png',
                      title: 'Ratan Tata is a visionary Indian business leader....',
                      rating: 4.8,
                      views: '100 k',
                      isPremium: false,
                      scale: scale,
                    ),
                  ),
                  Expanded(
                    child: _buildPopularCard(
                      image: 'assets/images/sundar.png',
                      title: 'became Google\'s CEO and leads it with vision and....',
                      rating: 4.9,
                      views: '110 k',
                      isPremium: true,
                      scale: scale,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20 * scale),

            // ── Recently Upload ────────────────────────────────────
            _buildSectionHeader('Recently Upload', scale, showViewAll: false),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Row(
                children: [
                  _buildLargeCard(
                    image: 'assets/images/bannar01.png',
                    title: 'Ratan Tata: A Visionary Leader with Inte...',
                    subtitle: 'Ratan Tata built a global Tata Group with integrity and vision.',
                    views: '1M',
                    time: '4 Year ago',
                    scale: scale,
                  ),
                  _buildLargeCard(
                    image: 'assets/images/bannar02.png',
                    title: 'Elon Musk: A Bold Innovator and Risk-Taker',
                    subtitle: 'Drive into the future with Elon Musk\'s SpaceX and Tesla.',
                    views: '2M',
                    time: '1 Year ago',
                    scale: scale,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double scale, {bool showViewAll = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {
                Widget screen;
                if (title == 'Recommended For You') {
                  screen = RecommendViewScreen(title: title);
                } else {
                  screen = PopularViewScreen(title: title);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  color: const Color(0xFF7C348D),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF7C348D),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularCard({
    required String image,
    required String title,
    required double rating,
    required String views,
    required bool isPremium,
    required double scale,
  }) {
    final Map<String, dynamic> storyData = {
      'image': image,
      'title': title,
      'rating': rating,
      'views': views,
      'isPremium': isPremium,
      'overview': 'Explore the incredible journey of ${title.split(':')[0]}. This story covers the major milestones and the visionary thinking that led to global recognition and impact.',
    };

    return GestureDetector(
      onTap: () async {
        if (GuestManager().isGuest) {
          if (!GuestManager().canReadStory()) {
            _showGuestLimitDialog();
            return;
          }
          await GuestManager().incrementReadCount();
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(
              storyData: storyData,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12 * scale)),
                  child: Image.asset(
                    image,
                    height: 110 * scale,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8 * scale,
                  left: 8 * scale,
                  child: Container(
                    width: 18 * scale,
                    height: 18 * scale,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 8 * scale,
                  right: 8 * scale,
                  child: GestureDetector(
                    onTap: () => showStoryOptions(context, title, storyData),
                    child: Container(
                      padding: EdgeInsets.all(4 * scale),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.more_vert, color: Colors.black, size: 16 * scale),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 11 * scale,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined, 
                            size: 11 * scale, 
                            color: const Color(0xFF7C348D)
                          ),
                          SizedBox(width: 3 * scale),
                          Text(
                            views,
                            style: GoogleFonts.poppins(
                              fontSize: 9 * scale, 
                              color: const Color(0xFF7C348D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeCard({
    required String image,
    required String title,
    required String subtitle,
    required String views,
    required String time,
    required double scale,
  }) {
    final Map<String, dynamic> storyData = {
      'image': image,
      'title': title,
      'subtitle': subtitle,
      'views': views,
      'time': time,
      'overview': 'Detailed look at ${title.split(':')[0]}. This comprehensive overview dives into the innovation, challenges, and ultimate triumphs that defined this legendary figure.',
    };

    return GestureDetector(
      onTap: () async {
        if (GuestManager().isGuest) {
          if (!GuestManager().canReadStory()) {
            _showGuestLimitDialog();
            return;
          }
          await GuestManager().incrementReadCount();
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(
              storyData: storyData,
            ),
          ),
        );
      },
      child: Container(
        width: 260 * scale,
        margin: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scale)),
                  child: Image.asset(
                    image,
                    height: 140 * scale,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10 * scale,
                  left: 10 * scale,
                  child: Container(
                    width: 20 * scale,
                    height: 20 * scale,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 10 * scale,
                  right: 10 * scale,
                  child: GestureDetector(
                    onTap: () => showStoryOptions(context, title, storyData),
                    child: Container(
                      padding: EdgeInsets.all(4 * scale),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.more_vert, color: Colors.black, size: 18 * scale),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11 * scale,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined, 
                        size: 12 * scale, 
                        color: const Color(0xFF7C348D)
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        views,
                        style: GoogleFonts.poppins(
                          fontSize: 10 * scale, 
                          color: const Color(0xFF7C348D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showGuestLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Guest Limit Reached', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'You have read the limit of 3 stories as a guest. Please login to read more!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C348D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Login Now', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
