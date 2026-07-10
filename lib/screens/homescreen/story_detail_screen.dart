import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_reader_screen.dart';
import '../../widgets/comment_bottom_sheet.dart';
import '../../widgets/language_dialog.dart';
import '../../utils/share_helper.dart';
import '../../widgets/save_button.dart';
import '../../widgets/like_button.dart';
import '../OnboardingScreen/author_profile_screen.dart';
import '../../widgets/story_options_sheet.dart';

import '../../utils/history_manager.dart';

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> storyData;

  const StoryDetailScreen({super.key, required this.storyData});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Add to history when viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HistoryManager().addToHistory(widget.storyData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyData = widget.storyData;
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);
    final bool isLocalFile = storyData['isLocalFile'] ?? false;
    String imagePath = storyData['image']?.toString().trim() ?? storyData['header_image']?.toString().trim() ?? '';
    if (imagePath.isEmpty) {
      imagePath = 'assets/images/bannar01.png';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Image Section ────────────────────────────────────────
            Stack(
              children: [
                isLocalFile
                    ? Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 380 * scale,
                        fit: BoxFit.cover,
                      )
                    : (imagePath.startsWith('http') || imagePath.startsWith('https')
                        ? Image.network(
                            imagePath,
                            width: double.infinity,
                            height: 380 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 380 * scale,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              );
                            },
                          )
                        : Image.asset(
                            imagePath,
                            width: double.infinity,
                            height: 380 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 380 * scale,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              );
                            },
                          )),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Heading Text
                Positioned(
                  top: 40 * scale,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        (storyData['title'] ?? storyData['story_title'] ?? 'UNTITLED').toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          fontSize: 19 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC7E9E7),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom Text
                Positioned(
                  bottom: 20 * scale,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBannerFooterItem('VIEWS', storyData['views']?.toString() ?? '0', scale),
                      _buildBannerFooterItem('RATING', storyData['rating']?.toString() ?? '0.0', scale),
                      _buildBannerFooterItem('CATEGORY', storyData['category']?.toString().toUpperCase() ?? 'STORY', scale),
                    ],
                  ),
                ),
                // Back Button
                Positioned(
                  top: 40 * scale,
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Top Right Icons
                Positioned(
                  top: 40 * scale,
                  right: 10 * scale,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () => showStoryOptions(
                          context,
                          storyData['title'] ?? '',
                          storyData,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── InteractionBar ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                12 * scale,
                12 * scale,
                8 * scale,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => LanguageDialog.show(context, scale),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C348D),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.translate,
                        size: 14 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Icon(Icons.star, color: Colors.amber, size: 14 * scale),
                  SizedBox(width: 2 * scale),
                  Text(
                    '${storyData['rating'] ?? '0.0'}(${storyData['rating_count'] ?? '0'})',
                    style: GoogleFonts.poppins(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Icon(Icons.menu_book, color: Colors.grey, size: 14 * scale),
                  SizedBox(width: 2 * scale),
                  Text(
                    '${storyData['views'] ?? '0'}',
                    style: GoogleFonts.poppins(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => CommentBottomSheet.show(context, scale),
                    child: _buildActionButton(
                      Icons.comment_outlined,
                      'Comment',
                      scale,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ShareHelper.shareStory(
                      storyData['title'] ?? 'Wonderful Story',
                      storyData['overview'] ??
                          'Read this inspiring story on True Story.',
                    ),
                    child: _buildActionButton(
                      Icons.share_outlined,
                      'Share',
                      scale,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                    child: SaveButton(
                      id: storyData['title'] ?? 'unknown',
                      scale: 0.8 * scale,
                      storyData: storyData,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                    child: LikeButton(
                      id: storyData['title'] ?? 'unknown',
                      scale: 0.8 * scale,
                    ),
                  ),
                ],
              ),
            ),

            // ── Author Section ───────────────────────────────────────────
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8 * scale),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 13 * scale,
                    ),
                    children: [
                      const TextSpan(text: 'Posted by : '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  String name = storyData['author_name']?.toString() ?? '';
                                  if (name.isEmpty || name == 'User') name = storyData['name']?.toString() ?? name;
                                  if (name.isEmpty || name == 'User') name = storyData['user_name']?.toString() ?? name;
                                  if (name.isEmpty || name == 'User') name = storyData['author']?.toString() ?? name;
                                  if (name.isEmpty) name = 'Unknown';
                                  
                                  return AuthorProfileScreen(
                                    authorName: name,
                                  );
                                },
                              ),
                            );
                          },
                          child: Builder(
                            builder: (context) {
                                  String name = storyData['author_name']?.toString() ?? '';
                                  if (name.isEmpty || name == 'User') name = storyData['name']?.toString() ?? name;
                                  if (name.isEmpty || name == 'User') name = storyData['user_name']?.toString() ?? name;
                                  if (name.isEmpty || name == 'User') name = storyData['author']?.toString() ?? name;
                                  if (name.isEmpty) name = 'Unknown';
                                  
                              return Text(
                                name,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF008080),
                                  decoration: TextDecoration.underline,
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content Section ──────────────────────────────────────────
            Center(
              child: Text(
                (storyData['title'] ?? storyData['story_title'] ?? 'UNTITLED').toString().toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Story Overview :',
                    style: GoogleFonts.poppins(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    (storyData['overview']?.toString().trim().isNotEmpty == true ? storyData['overview'] : null) ?? 
                    (storyData['story_description']?.toString().trim().isNotEmpty == true ? storyData['story_description'] : null) ??
                        'No description available.',
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      color: Colors.black.withValues(alpha: 0.85),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StoryReaderScreen(storyData: storyData),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: Text(
                      'READ MORE',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00CED1),
                        fontWeight: FontWeight.bold,
                        fontSize: 13 * scale,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Button ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                24 * scale, 
                24 * scale, 
                24 * scale, 
                24 * scale + MediaQuery.of(context).padding.bottom
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoryReaderScreen(storyData: storyData),
                    ),
                  ).then((_) {
                    if (mounted) setState(() {});
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C348D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                ),
                child: Text(
                  'READ NOW',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerFooterItem(String top, String bottom, double scale) {
    return Column(
      children: [
        Text(
          top,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          bottom,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 8 * scale,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    double scale, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16 * scale, color: color ?? Colors.black54),
          SizedBox(height: 2 * scale),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8.5 * scale,
              color: color ?? Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
