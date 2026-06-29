import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../homescreen/story_detail_screen.dart';
import '../../utils/guest_manager.dart';
import '../OnboardingScreen/login_screen.dart';
import '../../widgets/story_options_sheet.dart';
import '../../utils/post_manager.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getMergedStories() {
    final Map<String, List<Map<String, dynamic>>> categoryData = {
      'Startup': [
        {
          'type': 'popular',
          'image': 'assets/images/startup_office.png',
          'title': 'The Lean Startup: How Constant Innovation Creates Success',
          'rating': 4.7,
          'views': '250 k',
          'isPremium': true,
          'bannerTitle': 'STARTUP',
        },
        {
          'type': 'popular',
          'image': 'assets/images/ratan_tata.png',
          'title': 'The Journey of an Entrepreneur: From Idea to Exit',
          'rating': 4.8,
          'views': '100 k',
          'isPremium': false,
          'bannerTitle': 'FOUNDER',
        },
        {
          'type': 'popular',
          'image': 'assets/images/sundar.png',
          'title': 'Venture Capital: Funding Your Vision',
          'rating': 4.9,
          'views': '110 k',
          'isPremium': true,
          'bannerTitle': 'FUNDING',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar02.png',
          'title': 'SpaceX: Revolutionizing Space Exploration',
          'subtitle': 'Explore how boldness and risk-taking lead to historic achievements.',
          'views': '2M',
          'time': '1 Year ago',
          'bannerTitle': 'EXPAND',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar01.png',
          'title': 'The Future of AI Startups',
          'subtitle': 'Why artificial intelligence is the next major wave for global tech.',
          'views': '800 k',
          'time': '3 weeks ago',
          'bannerTitle': 'AI_TECH',
        },
      ],
      'General': [
        {
          'type': 'popular',
          'image': 'assets/images/general_people.png',
          'title': 'Diverse Perspectives in Modern Society',
          'rating': 4.5,
          'views': '45 k',
          'isPremium': false,
          'bannerTitle': 'GENERAL',
        },
        {
          'type': 'popular',
          'image': 'assets/images/ratan_tata.png',
          'title': 'The Importance of Integrity in Personal Growth',
          'rating': 4.7,
          'views': '85 k',
          'isPremium': false,
          'bannerTitle': 'GROWTH',
        },
        {
          'type': 'popular',
          'image': 'assets/images/collage.png',
          'title': 'Stories That Shape Our Collective Heritage',
          'rating': 4.6,
          'views': '60 k',
          'isPremium': true,
          'bannerTitle': 'HERITAGE',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar01.png',
          'title': 'Daily Habits for Success and Happiness',
          'subtitle': 'Learn the routine of the world\'s most successful individuals.',
          'views': '500 k',
          'time': '2 months ago',
          'bannerTitle': 'HABITS',
        },
      ],
      'Business': [
        {
          'type': 'popular',
          'image': 'assets/images/business_meeting.png',
          'title': 'Mastering the Art of Global Negotiation',
          'rating': 4.8,
          'views': '125 k',
          'isPremium': true,
          'bannerTitle': 'STRATEGY',
        },
        {
          'type': 'popular',
          'image': 'assets/images/sundar.png',
          'title': 'Market Trends and Economic Analysis 2026',
          'rating': 4.9,
          'views': '200 k',
          'isPremium': true,
          'bannerTitle': 'MARKET',
        },
        {
          'type': 'popular',
          'image': 'assets/images/Rectangle.png',
          'title': 'Investment Strategies for Growth',
          'rating': 4.4,
          'views': '95 k',
          'isPremium': false,
          'bannerTitle': 'INVEST',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar02.png',
          'title': 'Scaling Small Business Internationally',
          'subtitle': 'How to expand your brand beyond local boundaries effectively.',
          'views': '1.5M',
          'time': '6 months ago',
          'bannerTitle': 'SCALE',
        },
      ],
      'Education': [
        {
          'type': 'popular',
          'image': 'assets/images/education_student.png',
          'title': 'Personalized Learning in the Digital Age',
          'rating': 4.8,
          'views': '180 k',
          'isPremium': false,
          'bannerTitle': 'LEARNING',
        },
        {
          'type': 'popular',
          'image': 'assets/images/ratan_tata.png',
          'title': 'The Journey of Lifelong Education',
          'rating': 4.6,
          'views': '150 k',
          'isPremium': false,
          'bannerTitle': 'EDU',
        },
        {
          'type': 'popular',
          'image': 'assets/images/narayan.png',
          'title': 'Technology in the Modern Classroom',
          'rating': 4.7,
          'views': '70 k',
          'isPremium': true,
          'bannerTitle': 'CLASSROOM',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar01.png',
          'title': 'STEM Education and the Global Future',
          'subtitle': 'Preparing the next generation for a science-driven world.',
          'views': '300 k',
          'time': '3 Year ago',
          'bannerTitle': 'FUTURE',
        },
      ],
      'Sports': [
        {
          'type': 'popular',
          'image': 'assets/images/sports_stadium.png',
          'title': 'The Science of High Performance Athletics',
          'rating': 4.9,
          'views': '220 k',
          'isPremium': true,
          'bannerTitle': 'PERFORM',
        },
        {
          'type': 'popular',
          'image': 'assets/images/sundar.png',
          'title': 'Data Analytics in Professional Sports',
          'rating': 4.8,
          'views': '90 k',
          'isPremium': false,
          'bannerTitle': 'ANALYTICS',
        },
        {
          'type': 'popular',
          'image': 'assets/images/sridhar.png',
          'title': 'Leadership Lessons from the Field',
          'rating': 4.5,
          'views': '55 k',
          'isPremium': false,
          'bannerTitle': 'LEAD',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar02.png',
          'title': 'Greatest Triumphs in Modern Sports',
          'subtitle': 'Moments that defined athletes and inspired billions.',
          'views': '700 k',
          'time': '5 months ago',
          'bannerTitle': 'TRIUMPH',
        },
      ],
      'Artists': [
        {
          'type': 'popular',
          'image': 'assets/images/artist_studio.png',
          'title': 'Unlocking Creative Mastery in Art',
          'rating': 4.9,
          'views': '140 k',
          'isPremium': true,
          'bannerTitle': 'CREATIVE',
        },
        {
          'type': 'popular',
          'image': 'assets/images/ratan_tata.png',
          'title': 'The Evolution of Digital Illustration',
          'rating': 4.9,
          'views': '120 k',
          'isPremium': true,
          'bannerTitle': 'DIGITAL',
        },
        {
          'type': 'popular',
          'image': 'assets/images/collage.png',
          'title': 'Exploring Contemporary Expressionism',
          'rating': 4.4,
          'views': '85 k',
          'isPremium': false,
          'bannerTitle': 'EXPRESS',
        },
        {
          'type': 'large',
          'image': 'assets/images/bannar01.png',
          'title': 'Traditional Artists in the Digital Age',
          'subtitle': 'Bridging the gap between canvas and screen successfully.',
          'views': '450 k',
          'time': '1 month ago',
          'bannerTitle': 'ART_TECH',
        },
      ],
    };

    // Get hardcoded stories
    List<Map<String, dynamic>> stories = List.from(categoryData[widget.categoryName] ?? []);
    
    // Add uploaded stories matching this category
    final uploaded = PostManager().uploadedPosts.value
        .where((p) => p['category'] == widget.categoryName)
        .map((p) => {
          ...p,
          'type': 'large', // Uploaded stories show in "Recently Upload" section
          'subtitle': p['description'] ?? '',
          'time': 'Just now',
          'rating': p['rating'] ?? 4.5,
          'views': p['views'] ?? '0',
          'isPremium': p['isPremium'] ?? false,
          'bannerTitle': p['bannerTitle'] ?? 'STORY',
        }).toList();
    
    stories.insertAll(0, uploaded);
    
    // Ensure all stories have at least a basic description/overview for the reader
    stories = stories.map((s) => {
      ...s,
      'overview': s['overview'] ?? s['subtitle'] ?? 'Read the inspiring journey of ${s['title']} in the ${widget.categoryName} category.',
    }).toList();

    if (stories.isEmpty) {
      stories = [
        {
          'type': 'popular',
          'image': 'assets/images/ratan_tata.png',
          'title': 'Interesting stories in ${widget.categoryName}',
          'rating': 4.5,
          'views': '50 k',
          'isPremium': false,
          'bannerTitle': 'STORY',
        }
      ];
    }

    if (_searchQuery.isEmpty) return stories;
    return stories.where((s) => s['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: PostManager().uploadedPosts,
      builder: (context, uploadedPosts, child) {
        final filteredStories = _getMergedStories();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7C348D),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: false,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Search in ${widget.categoryName}...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 16 * scale),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  )
                : Text(
                    widget.categoryName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white, size: 24 * scale),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
            ],
          ),
          body: filteredStories.isEmpty
              ? Center(
                  child: Text(
                    'No stories found',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14 * scale),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(12 * scale),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12 * scale,
                    mainAxisSpacing: 12 * scale,
                  ),
                  itemCount: filteredStories.length,
                  itemBuilder: (context, index) {
                    final s = filteredStories[index];
                    return _buildGridCard(
                      storyData: s,
                      scale: scale,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildGridCard({
    required Map<String, dynamic> storyData,
    required double scale,
  }) {
    final String image = storyData['image'] ?? 'assets/images/ratan_tata.png';
    final String title = storyData['title'] ?? '';
    final String views = storyData['views']?.toString() ?? '0';
    final bool isLocalFile = storyData['isLocalFile'] ?? false;

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
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12 * scale)),
                    child: isLocalFile 
                      ? Image.file(
                          File(image),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildErrorImage(110 * scale),
                        )
                      : Image.asset(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildErrorImage(110 * scale),
                        ),
                  ),
                  // White Circle Indicator (Top Left) - As seen in the image
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
                  // More options (Top Right)
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
                            color: Colors.amber, // All stars yellow as in user image
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


  Widget _buildErrorImage(double height) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
