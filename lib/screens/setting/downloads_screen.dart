import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../homescreen/story_detail_screen.dart';
import '../../utils/post_manager.dart';
import '../../utils/download_manager.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

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
          'Downloads',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: PostManager().uploadedPosts,
        builder: (context, uploadedPosts, child) {
          return ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
            valueListenable: DownloadManager().downloadedStories,
            builder: (context, downloadedMap, child) {
              final List<Map<String, dynamic>> allDownloads = [];
              
              // Add uploaded PDF stories
              allDownloads.addAll(uploadedPosts.where((p) => p['pdfPath'] != null));
              
              // Add stories downloaded via DownloadManager
              allDownloads.addAll(downloadedMap.values);
              
              // Remove duplicates (by title)
              final uniqueDownloads = <String, Map<String, dynamic>>{};
              for (var story in allDownloads) {
                String title = story['title'] ?? 'Unknown';
                uniqueDownloads[title] = story;
              }
              final displayList = uniqueDownloads.values.toList();

              if (displayList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_for_offline_outlined, size: 60 * scale, color: Colors.grey.shade300),
                      SizedBox(height: 16 * scale),
                      Text(
                        'No downloaded stories yet',
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
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final story = displayList[index];
                  final bool isLocalFile = story['isLocalFile'] ?? false;
                  final bool isPdf = story['pdfPath'] != null;

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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16 * scale),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image on the Left
                              isLocalFile 
                                ? Image.file(
                                    File(story['image']),
                                    width: 110 * scale,
                                    height: 110 * scale,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    story['image'] ?? 'assets/images/ratan_tata.png',
                                    width: 110 * scale,
                                    height: 110 * scale,
                                    fit: BoxFit.cover,
                                  ),
                              // Content in the Middle
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      SizedBox(height: 8 * scale),
                                      Row(
                                        children: [
                                          Icon(
                                            isPdf ? Icons.picture_as_pdf : Icons.file_download_done, 
                                            size: 14 * scale, 
                                            color: const Color(0xFF7C348D)
                                          ),
                                          SizedBox(width: 4 * scale),
                                          Text(
                                            isPdf ? 'PDF Document' : 'Downloaded Story',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11 * scale,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Arrow on the Right
                              Padding(
                                padding: EdgeInsets.only(right: 12 * scale),
                                child: Center(
                                  child: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
