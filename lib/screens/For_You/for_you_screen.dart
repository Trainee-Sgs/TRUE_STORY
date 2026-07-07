import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'edit_profile_screen.dart';
import 'upload_story_screen.dart';
import '../Category/category_screen.dart';
import '../../utils/guest_manager.dart';
import '../OnboardingScreen/login_screen.dart';
import '../setting/settings_screen.dart';
import '../homescreen/story_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../utils/share_helper.dart';
import '../../widgets/story_options_sheet.dart';
import '../../utils/post_manager.dart';
import '../setting/followers_following_screen.dart';
import '../../utils/like_manager.dart';
import '../../Provider/story_status_provider.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  final StoryStatusProvider _storyStatusProvider = StoryStatusProvider();

  @override
  void initState() {
    super.initState();
    _storyStatusProvider.fetchUserStories();
  }

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
          'For You',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Story Stats Section Removed ───────────────────────────────

            // ── My Posts Section ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 8 * scale),
              child: Text(
                'My Post',
                style: GoogleFonts.poppins(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // List of Posts
            ListenableBuilder(
              listenable: _storyStatusProvider,
              builder: (context, child) {
                if (_storyStatusProvider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40 * scale),
                      child: const CircularProgressIndicator(color: Color(0xFF7C348D)),
                    ),
                  );
                }
                
                if (_storyStatusProvider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20 * scale),
                      child: Text(_storyStatusProvider.errorMessage!, style: GoogleFonts.poppins(color: Colors.red)),
                    ),
                  );
                }

                final posts = _storyStatusProvider.userStories;
                if (posts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(20 * scale),
                    child: Center(child: Text('No stories yet.', style: GoogleFonts.poppins())),
                  );
                }

                return Column(
                  children: [
                    ...posts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final post = entry.value;
                      final String image = post['header_image']?.toString().trim() ?? '';
                      return _buildPostCard(
                        context: context,
                        scale: scale,
                        index: 100 + index, 
                        title: post['story_title'] ?? 'Untitled',
                        views: post['views']?.toString() ?? '0',
                        likes: post['likes']?.toString() ?? '0',
                        image: image.isEmpty ? 'assets/images/bannar01.png' : image,
                        isLocalFile: post['isLocalFile'] == true,
                        pdfPath: post['pdfPath'],
                        isLocalPdf: post['isLocalPdf'] == true,
                        fullData: post,
                      );
                    }).toList().reversed, // Show newest first
                  ],
                );
              },
            ),

            SizedBox(height: 80 * scale),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10 * scale),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadStoryScreen()),
            );
            // Refresh stories after returning from upload screen
            _storyStatusProvider.fetchUserStories();
          },
          backgroundColor: const Color(0xFF7C348D),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Story',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: const CategoryScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: SettingsScreen()),
            );
          }
        },
      ),
    );
  }



  Widget _buildProfileButton(String label, double scale, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38 * scale,
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13 * scale,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required double scale,
    required int index,
    required String title,
    required String views,
    required String likes,
    required String image,
    bool isLocalFile = false,
    String? pdfPath,
    bool isLocalPdf = false,
    Map<String, dynamic>? fullData,
  }) {
    String status = fullData?['status'] ?? 'pending';
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'draft':
        statusColor = Colors.blue;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }

    return ValueListenableBuilder<Set<String>>(
      valueListenable: LikeManager().likedStoryIds,
      builder: (context, likedIds, child) {
        final bool isLiked = likedIds.contains(title);

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
            
            // Use fullData if provided, otherwise reconstruct from arguments
            final Map<String, dynamic> storyToPass = fullData ?? {
              'image': image,
              'title': title,
              'bannerTitle': title.contains('Tata') ? 'RATAN' : 'SUNDAR',
              'isLocalFile': isLocalFile,
              'pdfPath': pdfPath,
              'isLocalPdf': isLocalPdf,
              'views': views,
              'likes': likes,
            };

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryDetailScreen(
                  storyData: storyToPass,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
            height: 100 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15 * scale),
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(15 * scale)),
                  child: isLocalFile 
                    ? Image.file(
                        File(image),
                        width: 100 * scale,
                        height: 100 * scale,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100 * scale,
                          height: 100 * scale,
                          color: Colors.grey[200],
                          child: Icon(Icons.person, size: 40 * scale, color: Colors.grey),
                        ),
                      )
                    : image.startsWith('http') || image.startsWith('https')
                        ? Image.network(
                            image,
                            width: 100 * scale,
                            height: 100 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100 * scale,
                              height: 100 * scale,
                              color: Colors.grey[200],
                              child: Icon(Icons.person, size: 40 * scale, color: Colors.grey),
                            ),
                          )
                        : Image.asset(
                        image,
                        width: 100 * scale,
                        height: 100 * scale,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100 * scale,
                          height: 100 * scale,
                          color: Colors.grey[200],
                          child: Icon(Icons.person, size: 40 * scale, color: Colors.grey),
                        ),
                      ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            // ── Like Button ──
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                LikeManager().toggleLike(title);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(scale: anim, child: child),
                                  child: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    key: ValueKey(isLiked),
                                    color: isLiked ? Colors.red : Colors.black45,
                                    size: 20 * scale,
                                  ),
                                ),
                              ),
                            ),
                            // ── 3-dot Menu ──
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => showStoryOptions(context, title, fullData ?? {
                                'image': image,
                                'title': title,
                                'views': views,
                                'likes': likes,
                                'isLocalFile': isLocalFile,
                                'pdfPath': pdfPath,
                                'isLocalPdf': isLocalPdf,
                              }),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Icon(Icons.more_vert, size: 20 * scale, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 12 * scale, color: Colors.black45),
                            SizedBox(width: 4 * scale),
                            Text(
                              views,
                              style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.black45),
                            ),
                            SizedBox(width: 10 * scale),
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 12 * scale,
                              color: isLiked ? Colors.red : Colors.black45,
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              likes,
                              style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.black45),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(8 * scale),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 9 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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