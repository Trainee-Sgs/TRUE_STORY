import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_detail_screen.dart';
import '../../widgets/story_options_sheet.dart';

class PopularViewScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>>? categoryStories;
  const PopularViewScreen({super.key, required this.title, this.categoryStories});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);
    final List<Map<String, dynamic>> displayStories = categoryStories ?? [];

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
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(12 * scale),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12 * scale,
          mainAxisSpacing: 12 * scale,
        ),
        itemCount: displayStories.length,
        itemBuilder: (context, index) {
          final story = displayStories[index];
          return _buildGridCard(context, story, scale);
        },
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, dynamic> story, double scale) {
    final String title = story['title'] ?? '';
    final String views = story['views']?.toString() ?? '0';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(
              storyData: story,
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
                    child: Image.asset(
                      story['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
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
                      onTap: () => showStoryOptions(context, title, story),
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
}
