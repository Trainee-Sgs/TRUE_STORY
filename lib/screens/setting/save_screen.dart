import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../homescreen/story_detail_screen.dart';
import '../../utils/save_manager.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

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
          'Saved Stories',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
        valueListenable: SaveManager().savedStories,
        builder: (context, savedStoriesMap, child) {
          final savedStoriesList = savedStoriesMap.values.toList();

          if (savedStoriesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 60 * scale, color: Colors.grey.shade300),
                  SizedBox(height: 16 * scale),
                  Text(
                    'No saved stories yet',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20 * scale),
            itemCount: savedStoriesList.length,
            itemBuilder: (context, index) {
              final story = savedStoriesList[index];
              final bool isLocalFile = story['isLocalFile'] ?? false;
              final String imagePath = story['image'] ?? 'assets/images/ratan_tata.png';

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
                  margin: EdgeInsets.only(bottom: 20 * scale),
                  height: 110 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16 * scale),
                    child: Row(
                      children: [
                        // Image on the Left
                        SizedBox(
                          width: 110 * scale,
                          height: 110 * scale,
                          child: isLocalFile 
                           ? Image.file(File(imagePath), fit: BoxFit.cover)
                           : Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                        // Content in the Middle
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story['title'] ?? 'Wonderful Story',
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
                                    Icon(Icons.visibility_outlined, size: 14 * scale, color: Colors.grey.shade400),
                                    SizedBox(width: 4 * scale),
                                    Text(
                                      story['views'] ?? '0',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11 * scale,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.favorite_border, size: 14 * scale, color: Colors.grey.shade400),
                                    SizedBox(width: 4 * scale),
                                    Text(
                                      story['likes'] ?? '0',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11 * scale,
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
                        // Remove Icon on the Right
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                SaveManager().toggleSave(story['title'] ?? '');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
