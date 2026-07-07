import 'dart:async';
import 'dart:io';
import 'package:true_story/utils/post_manager.dart';
import 'package:true_story/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:true_story/screens/setting/settings_screen.dart';
import 'search_screen.dart';
import 'popular_view.dart';
import 'recommend_view.dart';
import '../For_You/for_you_screen.dart';
import '../Category/category_screen.dart';
import '../menuscreens/app_drawer.dart';
import 'story_detail_screen.dart';
import '../../utils/guest_manager.dart';
import '../OnboardingScreen/login_screen.dart';
import '../setting/save_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/language_dialog.dart';
import '../../widgets/story_options_sheet.dart';
import '../../utils/history_manager.dart';
import '../../Provider/full_story_approval_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  final FullStoryApprovalProvider _fullStoryApprovalProvider = FullStoryApprovalProvider();

  // ── Banner slides ──────────────────────────────────────────────
  final List<_BannerSlide> _banners = const [
    _BannerSlide(
      image: 'assets/images/welcome.png',
      showOverlay: true,
      quote: '',
    ),
    _BannerSlide(
      image: 'assets/images/welcome01.png',
      showOverlay: false,
      quote: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fullStoryApprovalProvider.fetchApprovedStories();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      _bannerController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(scale),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Auto-Sliding Banner ──────────────────────────────
            _buildAutoSliderBanner(scale),

            if (GuestManager().isGuest) _buildGuestAccessBanner(scale),

            const SizedBox(height: 6),

            // ── Popular ─────────────────────────────────────────
            _buildSectionHeader('Popular', scale, showViewAll: true),
            _buildPopularList(scale),

            // ── Recently Watched ─────────────────────────────────
            _buildSectionHeader('Recently Watched', scale, showViewAll: true),
            ListenableBuilder(
              listenable: HistoryManager(),
              builder: (context, _) {
                final history = HistoryManager().historyItems.where((story) {
                  if (!story.containsKey('status')) return true;
                  final status = story['status']?.toString().toLowerCase() ?? '';
                  return status == 'approved' || status == '1';
                }).toList();
                final validHistory = history.where((h) {
                  final t = (h['title'] ?? h['story_title'] ?? '').toString();
                  return t.isNotEmpty && !t.toUpperCase().contains('UNKNOWN');
                }).toList();
                
                if (validHistory.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No stories watched yet.',
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13 * scale),
                      ),
                    ),
                  );
                }

                final List<_ContentCard> historyCards = validHistory.take(10).map((h) => _ContentCard(
                      image: h['image'] ?? h['header_image'] ?? 'assets/images/bannar01.png',
                      title: h['title'] ?? h['story_title'] ?? 'Unknown Story',
                      subtitle: h['overview'] ?? h['story_description'] ?? h['description'] ?? '',
                      views: h['views']?.toString() ?? '0',
                      time: DateUtil.getTimeAgo(h['timestamp']?.toString() ?? h['created_at']?.toString() ?? h['date']?.toString()),
                      overview: h['overview'] ?? h['story_description'] ?? '',
                      fullData: h,
                    )).toList();
                    
                return _buildBannerCardList(
                  cards: historyCards,
                  scale: scale,
                );
              },
            ),

            // ── Latest Upload ────────────────────────────────────
            _buildSectionHeader('Latest Upload', scale, showViewAll: true),
            ListenableBuilder(
              listenable: _fullStoryApprovalProvider,
              builder: (context, _) {
                if (_fullStoryApprovalProvider.isLoading) {
                  return Padding(
                    padding: EdgeInsets.all(40 * scale),
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFF7C348D))),
                  );
                }

                final approvedStories = _fullStoryApprovalProvider.approvedStories.where((story) {
                  final status = story['status']?.toString().toLowerCase() ?? '';
                  if (status != 'approved' && status != '1') return false;

                  final String dateStr = story['published_at']?.toString() ?? story['created_at']?.toString() ?? '';
                  if (dateStr.isNotEmpty) {
                    try {
                      final DateTime publishedDate = DateTime.parse(dateStr);
                      final Duration difference = DateTime.now().difference(publishedDate);
                      if (difference.inDays > 3) {
                        return false;
                      }
                    } catch (e) {
                      return false;
                    }
                  } else {
                    return false;
                  }

                  return true;
                }).toList();

                approvedStories.sort((a, b) {
                  final String dateStrA = a['published_at']?.toString() ?? a['created_at']?.toString() ?? '';
                  final String dateStrB = b['published_at']?.toString() ?? b['created_at']?.toString() ?? '';
                  DateTime dateA = DateTime.fromMillisecondsSinceEpoch(0);
                  DateTime dateB = DateTime.fromMillisecondsSinceEpoch(0);
                  try {
                    if (dateStrA.isNotEmpty) dateA = DateTime.parse(dateStrA);
                  } catch (_) {}
                  try {
                    if (dateStrB.isNotEmpty) dateB = DateTime.parse(dateStrB);
                  } catch (_) {}
                  return dateB.compareTo(dateA);
                });
                if (approvedStories.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(20 * scale),
                    child: Center(
                      child: Text(
                        'No latest uploads.',
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13 * scale),
                      ),
                    ),
                  );
                }

                final List<_ContentCard> latestCards = approvedStories.take(10).map((p) {
                  String imageUrl = p['header_image']?.toString() ?? '';
                  if (imageUrl.isEmpty) {
                    imageUrl = 'assets/images/bannar01.png'; // fallback image
                  }
                  final String dateStr = p['published_at']?.toString() ?? p['created_at']?.toString() ?? '';
                  return _ContentCard(
                    image: imageUrl,
                    title: p['story_title']?.toString() ?? 'Untitled',
                    subtitle: p['story_description']?.toString() ?? '',
                    views: p['views']?.toString() ?? '0',
                    time: DateUtil.getTimeAgo(dateStr),
                    overview: p['story_description']?.toString() ?? 'No content.',
                    fullData: p,
                  );
                }).toList();
                
                return _buildBannerCardList(
                  cards: latestCards,
                  scale: scale,
                );
              },
            ),

            // ── TRUE STORY Quote Banner ──────────────────────────
            _buildQuoteBanner(scale),

            // ── Recommended For You ──────────────────────────────
            _buildSectionHeader('Recommended For You', scale, showViewAll: true),
            _buildPopularList(scale),

            SizedBox(height: 24 * scale),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to Category screen
            Navigator.push(
              context,
              FadePageRoute(child: const CategoryScreen()),
            );
          } else if (index == 2) {
            // Navigate to For You screen
            Navigator.push(
              context,
              FadePageRoute(child: const ForYouScreen()),
            );
          } else if (index == 3) {
            // Navigate to Settings screen
            Navigator.push(
              context,
              FadePageRoute(child: SettingsScreen()),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }

 
  // ─────────────────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(double scale) {
    return AppBar(
      backgroundColor: const Color(0xFF7C348D),
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 28 * scale),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(top: 2 * scale),
        child: Image.asset(
          'assets/images/Trustory logo horizontal home screen.png',
          height: 34 * scale,
          fit: BoxFit.contain,
        ),
      ),              
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white, size: 24 * scale),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.bookmark_outline,
            color: Colors.white,
            size: 24 * scale,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SaveScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.translate, color: Colors.white, size: 24 * scale),
          onPressed: () => LanguageDialog.show(context, scale),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Auto-Sliding Banner
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAutoSliderBanner(double scale) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 210 * scale,
          child: PageView.builder(
            controller: _bannerController,
            // Infinite scrolling
            itemBuilder: (context, index) {
              final slide = _banners[index % _banners.length];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    slide.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                     // color: const Color(0xFF7C348D).withOpacity(0.3),
                      child: const Center(
                       // child: Icon(Icons.image, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                 // if (slide.showOverlay)
                    // Container(
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       begin: Alignment.centerLeft,
                    //       end: Alignment.centerRight,
                    //       colors: [
                    //         Colors.black.withOpacity(0.65),
                    //         Colors.transparent,
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  if (slide.showOverlay)
                    Positioned(
                      left: 20 * scale,
                      bottom: 30 * scale,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.quote,
                            style: GoogleFonts.poppins(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          // OutlinedButton(
                          //   onPressed: () {},
                          //   style: OutlinedButton.styleFrom(
                          //     side: const BorderSide(color: Colors.white),
                          //     padding: EdgeInsets.symmetric(
                          //       horizontal: 18 * scale,
                          //       vertical: 6 * scale,
                          //     ),
                          //     minimumSize: Size.zero,
                          //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          //   ),
                          //   child: Text(
                          //     'Read NOW',
                          //     style: GoogleFonts.poppins(
                          //       fontSize: 12 * scale,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Dot Indicators
        // Positioned(
        //   bottom: 10 * scale,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: List.generate(_banners.length, (i) {
        //       final active = i == _currentBannerPage;
        //       return AnimatedContainer(
        //         duration: const Duration(milliseconds: 300),
        //         margin: EdgeInsets.symmetric(horizontal: 3 * scale),
        //         width: active ? 20 * scale : 7 * scale,
        //         height: 7 * scale,
        //         decoration: BoxDecoration(
        //           color: active ? Colors.white : Colors.white54,
        //           borderRadius: BorderRadius.circular(4 * scale),
        //         ),
        //       );
        //     }),
        //   ),
        // ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, double scale, {bool showViewAll = true}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 6 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {
                Widget screen;
                List<Map<String, dynamic>> storiesToPass = [];
                
                if (title == 'Popular' || title == 'Recommended For You' || title == 'Latest Upload') {
                  final approved = _fullStoryApprovalProvider.approvedStories.where((story) {
                    final status = story['status']?.toString().toLowerCase() ?? '';
                    return status == 'approved' || status == '1';
                  }).toList();

                  if (title == 'Latest Upload') {
                    approved.sort((a, b) {
                      final String dateStrA = a['published_at']?.toString() ?? a['created_at']?.toString() ?? '';
                      final String dateStrB = b['published_at']?.toString() ?? b['created_at']?.toString() ?? '';
                      DateTime dateA = DateTime.fromMillisecondsSinceEpoch(0);
                      DateTime dateB = DateTime.fromMillisecondsSinceEpoch(0);
                      try {
                        if (dateStrA.isNotEmpty) dateA = DateTime.parse(dateStrA);
                      } catch (_) {}
                      try {
                        if (dateStrB.isNotEmpty) dateB = DateTime.parse(dateStrB);
                      } catch (_) {}
                      return dateB.compareTo(dateA);
                    });
                  }

                  
                  storiesToPass = approved.map((p) {
                    String img = p['header_image']?.toString() ?? '';
                    if (img.isEmpty) img = 'assets/images/bannar01.png';
                    return {
                      'image': img,
                      'title': p['story_title']?.toString() ?? 'Untitled',
                      'rating': double.tryParse(p['rating']?.toString() ?? '4.5') ?? 4.5,
                      'views': p['views']?.toString() ?? '0',
                      'isPremium': p['is_premium'] == true || p['is_premium'] == 'true' || p['is_premium'] == 1,
                      'overview': p['story_description']?.toString() ?? 'No content.',
                      ...p,
                    };
                  }).toList();
                } else if (title == 'Recently Watched') {
                  final history = HistoryManager().historyItems.where((story) {
                    if (!story.containsKey('status')) return true;
                    final status = story['status']?.toString().toLowerCase() ?? '';
                    return status == 'approved' || status == '1';
                  }).toList();
                  
                  storiesToPass = history.map((h) {
                    return {
                      'image': h['image'] ?? 'assets/images/bannar01.png',
                      'title': h['title'] ?? 'Unknown Story',
                      'views': h['views']?.toString() ?? '0',
                      'rating': h['rating'] ?? 4.5,
                      'overview': h['overview'] ?? '',
                      ...h,
                    };
                  }).toList();
                }

                if (title == 'Popular' || title == 'Latest Upload' || title == 'Recently Watched') {
                  screen = PopularViewScreen(title: title, categoryStories: storiesToPass);
                } else {
                  screen = RecommendViewScreen(title: title, categoryStories: storiesToPass);
                }
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 13 * scale,
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

  // ─────────────────────────────────────────────────────────────────────────
  // Popular / Recommended List
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPopularList(double scale) {
    return ListenableBuilder(
      listenable: _fullStoryApprovalProvider,
      builder: (context, _) {
        if (_fullStoryApprovalProvider.isLoading) {
          return SizedBox(
            height: 240 * scale,
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF7C348D))),
          );
        }

        final approvedStories = _fullStoryApprovalProvider.approvedStories.where((story) {
          final status = story['status']?.toString().toLowerCase() ?? '';
          return status == 'approved' || status == '1';
        }).toList();

        if (approvedStories.isEmpty) {
          return SizedBox(
            height: 240 * scale,
            child: Center(
              child: Text(
                'No stories available.',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13 * scale),
              ),
            ),
          );
        }

        final cards = approvedStories.take(10).map((p) {
          String imageUrl = p['header_image']?.toString() ?? '';
          if (imageUrl.isEmpty) {
            imageUrl = 'assets/images/bannar01.png'; // fallback image
          }
          return _PopularCard(
            image: imageUrl,
            title: p['story_title']?.toString() ?? 'Untitled',
            rating: double.tryParse(p['rating']?.toString() ?? '4.5') ?? 4.5,
            views: p['views']?.toString() ?? '0',
            isPremium: p['is_premium'] == true || p['is_premium'] == 'true' || p['is_premium'] == 1,
            overview: p['story_description']?.toString() ?? 'No content.',
            fullData: p,
          );
        }).toList();

        return SizedBox(
          height: 240 * scale,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            itemCount: cards.length,
            itemBuilder: (context, index) =>
                _buildPopularCard(cards[index], scale),
          ),
        );
      },
    );
  }

  Widget _buildPopularCard(_PopularCard card, double scale) {
    return GestureDetector(
      onTap: () async {
        if (GuestManager().isGuest) {
          if (!GuestManager().canReadStory()) {
            _showGuestLimitDialog();
            return;
          }
          await GuestManager().incrementReadCount();
          setState(() {}); // Refresh banner count
        }
        if (!mounted) return;
        final bool isLocal = !card.image.startsWith('assets/');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(
              storyData: card.fullData ?? {
                'image': card.image,
                'title': card.title,
                'bannerTitle': card.title.split(' ')[0],
                'overview': card.overview,
                'isLocalFile': isLocal,
              },
            ),
          ),
        );
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 158 * scale,
          margin: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 4 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12 * scale)),
                  child: card.image.isEmpty
                    ? Container(
                        height: 160 * scale,
                        color: Colors.grey[200],
                        child: Icon(Icons.person, size: 48 * scale, color: Colors.grey),
                      )
                    : card.image.startsWith('http')
                        ? Image.network(
                            card.image,
                            height: 160 * scale,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 160 * scale,
                              color: Colors.grey[200],
                              child: Icon(Icons.person, size: 48 * scale, color: Colors.grey),
                            ),
                          )
                        : card.image.startsWith('assets/')
                            ? Image.asset(
                                card.image,
                                height: 160 * scale,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 160 * scale,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.person, size: 48 * scale, color: Colors.grey),
                                ),
                              )
                            : Image.file(
                                File(card.image),
                                height: 160 * scale,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 160 * scale,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.person, size: 48 * scale, color: Colors.grey),
                                ),
                              ),
                ),
                if (card.isPremium)
                  Positioned(
                    top: 8 * scale,
                    left: 8 * scale,
                    child: Container(
                      padding: EdgeInsets.all(4 * scale),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        size: 13 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                Positioned(
                  top: 6 * scale,
                  right: 6 * scale,
                  child: GestureDetector(
                    onTap: () => showStoryOptions(context, card.title, {
                      'image': card.image,
                      'title': card.title,
                      'rating': card.rating,
                      'views': card.views,
                      'isPremium': card.isPremium,
                    }),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20 * scale,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  8 * scale, 6 * scale, 8 * scale, 6 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11 * scale,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      // Star rating
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < card.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 11 * scale,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.visibility,
                          color: Colors.grey, size: 11 * scale),
                      SizedBox(width: 2 * scale),
                      Text(
                        card.views,
                        style: GoogleFonts.poppins(
                          fontSize: 9 * scale,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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

  Widget _buildBannerCardList({
    required List<_ContentCard> cards,
    required double scale,
  }) {
    return SizedBox(
      height: 290 * scale,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
        itemCount: cards.length,
        itemBuilder: (context, index) =>
            _buildBannerCard(cards[index], scale),
      ),
    );
  }

  Widget _buildBannerCard(_ContentCard card, double scale) {
    return GestureDetector(
      onTap: () async {
        if (GuestManager().isGuest) {
          if (!GuestManager().canReadStory()) {
            _showGuestLimitDialog();
            return;
          }
          await GuestManager().incrementReadCount();
          setState(() {}); // Refresh banner
        }
        if (!mounted) return;
        final bool isLocal = !card.image.startsWith('assets/');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(
              storyData: card.fullData ?? {
                'image': card.image,
                'title': card.title,
                'bannerTitle': card.title.contains('Tata') ? 'RATAN' : 'ELON',
                'overview': card.overview,
                'isLocalFile': isLocal,
              },
            ),
          ),
        );
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 300 * scale,
          margin: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 4 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(14 * scale)),
                  child: card.image.startsWith('http')
                    ? Image.network(
                        card.image,
                        height: 165 * scale,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 165 * scale,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 48 * scale, color: Colors.grey),
                        ),
                      )
                    : card.image.startsWith('assets/')
                      ? Image.asset(
                          card.image,
                          height: 165 * scale,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 165 * scale,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 48 * scale, color: Colors.grey),
                          ),
                        )
                      : Image.file(
                          File(card.image),
                          height: 165 * scale,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 165 * scale,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 48 * scale, color: Colors.grey),
                          ),
                        ),
                ),
                Positioned(
                  top: 8 * scale,
                  right: 8 * scale,
                  child: GestureDetector(
                    onTap: () => showStoryOptions(context, card.title, {
                      'image': card.image,
                      'title': card.title,
                      'subtitle': card.subtitle,
                      'views': card.views,
                      'time': card.time,
                    }),
                    child: Icon(Icons.more_vert,
                        color: Colors.white, size: 22 * scale),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale, vertical: 8 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    card.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11 * scale,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.visibility_outlined,
                          color: Colors.grey, size: 13 * scale),
                      SizedBox(width: 4 * scale),
                      Text(
                        card.views,
                        style: GoogleFonts.poppins(
                            fontSize: 11 * scale, color: Colors.grey),
                      ),
                      SizedBox(width: 16 * scale),
                      Text(
                        card.time,
                        style: GoogleFonts.poppins(
                            fontSize: 11 * scale, color: Colors.grey),
                      ),
                    ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // TRUE STORY Quote Banner
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuoteBanner(double scale) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 24 * scale),
      padding: EdgeInsets.symmetric(
          vertical: 180 * scale, horizontal: 55 * scale),
      decoration: BoxDecoration(
        //color: const Color(0xFF3F2B63),
        image: DecorationImage(
          image: const AssetImage('assets/images/add.png'),
         // fit: BoxFit.cover,
          // colorFilter: ColorFilter.mode(
          //   Colors.black.withOpacity(0.55),
          //   BlendMode.darken,
          // ),
        ),
      ),
    );
  }

  // Removed _showLanguageDialog as it is now replaced by LanguageDialog.show


  Widget _buildGuestAccessBanner(double scale) {
    int read = GuestManager().readCount;
    int limit = GuestManager.maxGuestStories;
    int left = (limit - read).clamp(0, limit);
    bool isLimitReached = read >= limit;

    return Container(
      margin: EdgeInsets.all(16 * scale),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2FF), // Very light lavender
        borderRadius: BorderRadius.circular(15 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guest Access',
                style: GoogleFonts.poppins(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '$read/$limit Stories',
                style: GoogleFonts.poppins(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA669B0), // Soft purple
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          
          // Progress Bar Stack
          Stack(
            children: [
              Container(
                height: 4 * scale,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 4 * scale,
                    width: constraints.maxWidth * (read / limit),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C348D),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                  );
                },
              ),
            ],
          ),
          
          SizedBox(height: 14 * scale),
          Row(
            children: [
              Text(                   
                isLimitReached 
                    ? 'Limit Reached. Log in for unlimited access . '
                    : '$left More Story left . ',
                style: GoogleFonts.poppins(
                  fontSize: 10 * scale,
                  color: isLimitReached ? Colors.red : const Color(0xFFA669B0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 13 * scale,
                    color: const Color(0xFF008080),
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.alphabetic,
                    height: 1.4,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF008080),
                  ).copyWith(
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
            ],
          ),
        ],
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
class _BannerSlide {
  final String image;
  final bool showOverlay;
  final String quote;
  const _BannerSlide(
      {required this.image,
      required this.showOverlay,
      required this.quote});
}

class _PopularCard {
  final String image;
  final String title;
  final double rating;
  final String views;
  final bool isPremium;
  final String overview;
  final Map<String, dynamic>? fullData;
  const _PopularCard({
    required this.image,
    required this.title,
    required this.rating,
    required this.views,
    this.isPremium = false,
    required this.overview,
    this.fullData,
  });
}

class _ContentCard {
  final String image;
  final String title;
  final String subtitle;
  final String views;
  final String time;
  final String overview;
  final Map<String, dynamic>? fullData;
  const _ContentCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.views,
    required this.time,
    required this.overview,
    this.fullData,
  });
}
