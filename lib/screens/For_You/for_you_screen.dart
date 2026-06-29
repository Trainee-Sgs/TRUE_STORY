import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart';
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

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
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
            // ── Profile Header ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image
                      Column(
                        children: [
                          Container(
                            width: 80 * scale,
                            height: 80 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 2),
                              image: const DecorationImage(
                                image: NetworkImage('https://i.pravatar.cc/150?u=sowmiya'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            'Sowmiya',
                            style: GoogleFonts.poppins(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(width: 20 * scale),
                      
                      // Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sowmi_222',
                              style: GoogleFonts.poppins(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const FollowersFollowingScreen(title: 'Followers'),
                                      ),
                                    );
                                  },
                                  child: _buildStatItem('Followers', '50k', scale),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const FollowersFollowingScreen(title: 'Following'),
                                      ),
                                    );
                                  },
                                  child: _buildStatItem('Following', '15k', scale),
                                ),
                                ValueListenableBuilder<List<Map<String, dynamic>>>(
                                  valueListenable: PostManager().uploadedPosts,
                                  builder: (context, posts, child) {
                                    return _buildStatItem('Story', (10 + posts.length).toString(), scale);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 15 * scale),
                  // Bio
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌟 Storyteller | Dreamer | Achiever',
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '📍 Tamil Nadu, India',
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20 * scale),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildProfileButton(
                          'Edit Profile', 
                          scale, 
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: _buildProfileButton('Share Profile', scale, () {
                          ShareHelper.shareProfile('Sowmiya', 'Sowmi_222');
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 1, height: 1),
            
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
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: PostManager().uploadedPosts,
              builder: (context, posts, child) {
                return Column(
                  children: [
                    ...posts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final post = entry.value;
                      return _buildPostCard(
                        context: context,
                        scale: scale,
                        index: 100 + index, // Offset index for new posts
                        title: post['title'],
                        views: post['views'] ?? '0',
                        likes: post['likes'] ?? '0',
                        image: post['image'] ?? 'assets/images/ratan_tata.png',
                        isLocalFile: post['isLocalFile'] ?? false,
                        pdfPath: post['pdfPath'],
                        isLocalPdf: post['isLocalPdf'] ?? false,
                        fullData: post,
                      );
                    }).toList().reversed.toList(), // Show newest first
                  ],
                );
              },
            ),

            // _buildPostCard(
            //   context: context,
            //   scale: scale,
            //   index: 0,
            //   title: '"Ratan Tata – A Great Life Shaped by Values."',
            //   views: '3M',
            //   likes: '1M',
            //   image: 'assets/images/ratan_tata.png',
            // ),
            // _buildPostCard(
            //   context: context,
            //   scale: scale,
            //   index: 1,
            //   title: '"Ratan Tata – A Great Life Shaped by Values."',
            //   views: '3M',
            //   likes: '1M',
            //   image: 'assets/images/ratan_tata.png',
            // ),
            
            SizedBox(height: 80 * scale),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10 * scale),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadStoryScreen()),
            );
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

  Widget _buildStatItem(String label, String count, double scale) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13 * scale, // ← increased from 11 to 13
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
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
