import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/like_manager.dart';
import '../../widgets/story_options_sheet.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  // Mock data source for stories
  final List<Map<String, dynamic>> allStories = [
    {
      'image': 'assets/images/ratan_tata.png',
      'title': 'Ratan Tata is a visionary Indian business leader....',
      'views': '100 k',
      'likes': '1M',
      'time': '8 min read',
    },
    {
      'image': 'assets/images/sundar.png',
      'title': 'became Google\'s CEO and leads it with vision and....',
      'views': '110 k',
      'likes': '1M',
      'time': '10 min read',
    },
    {
      'image': 'assets/images/narayan.png',
      'title': 'Narayana Murthy founded Infosys and made it....',
      'views': '110 k',
      'likes': '1M',
      'time': '12 min read',
    },
    {
      'image': 'assets/images/sridhar.png',
      'title': 'Sridhar Vembu is the founder of Zoho, a glo...',
      'views': '110 k',
      'likes': '1M',
      'time': '15 min read',
    },
    {
      'image': 'assets/images/bannar01.png',
      'title': 'Ratan Tata: A Visionary Leader with Integrity',
      'views': '1M',
      'likes': '1M',
      'time': '20 min read',
    },
    {
      'image': 'assets/images/bannar02.png',
      'title': 'Elon Musk: A Bold Innovator and Risk-Taker',
      'views': '2M',
      'likes': '1M',
      'time': '25 min read',
    },
    {
      'image': 'assets/images/ratan_tata.png',
      'title': '“Ratan Tata – A Great Life Shaped by Values.”', // From the reference UI
      'views': '3M',
      'likes': '1M',
      'time': '8 min read',
    }
  ];

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
          'Like',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: LikeManager().likedStoryIds,
        builder: (context, likedIds, child) {
          final likedStories = allStories.where((s) => likedIds.contains(s['title'])).toList();

          if (likedStories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60 * scale, color: Colors.grey.shade300),
                  SizedBox(height: 16 * scale),
                  Text(
                    'No liked stories yet.',
                    style: GoogleFonts.poppins(
                      fontSize: 16 * scale,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20 * scale),
            itemCount: likedStories.length,
            itemBuilder: (context, index) {
              final story = likedStories[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16 * scale),
                child: Container(
                  height: 110 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15 * scale),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Story Image
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14 * scale),
                          bottomLeft: Radius.circular(14 * scale),
                        ),
                        child: Image.asset(
                          story['image'],
                          width: 100 * scale,
                          height: 110 * scale,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Story Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => LikeManager().toggleLike(story['title']),
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 20 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  GestureDetector(
                                    onTap: () => showStoryOptions(context, story['title']),
                                    child: Icon(
                                      Icons.more_vert,
                                      color: Colors.black,
                                      size: 20 * scale,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    story['title'],
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 12 * scale, color: Colors.grey),
                                      SizedBox(width: 4 * scale),
                                      Text(
                                        story['views'],
                                        style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.grey),
                                      ),
                                      SizedBox(width: 8 * scale),
                                      Icon(Icons.favorite_border, size: 12 * scale, color: Colors.grey),
                                      SizedBox(width: 4 * scale),
                                      Text(
                                        story['likes'],
                                        style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    story['time'],
                                    style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.grey),
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
        },
      ),
    );
  }
}
