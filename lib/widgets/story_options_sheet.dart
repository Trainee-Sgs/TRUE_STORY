import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/save_manager.dart';
import '../utils/share_helper.dart';
import '../utils/download_manager.dart';
import '../utils/post_manager.dart';

/// Call this anywhere to show the 3-dot options bottom sheet.
void showStoryOptions(BuildContext context, String storyTitle, [Map<String, dynamic>? storyData]) {
  final double w = MediaQuery.of(context).size.width;
  final double scale = (w / 360).clamp(0.8, 1.4);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _StoryOptionsSheet(storyTitle: storyTitle, scale: scale, storyData: storyData),
  );
}

class _StoryOptionsSheet extends StatelessWidget {
  final String storyTitle;
  final double scale;
  final Map<String, dynamic>? storyData;
  const _StoryOptionsSheet({required this.storyTitle, required this.scale, this.storyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 16 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40 * scale,
            height: 4 * scale,
            margin: EdgeInsets.only(bottom: 16 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          // Save to Playlist
          ValueListenableBuilder<Set<String>>(
            valueListenable: SaveManager().savedStoryIds,
            builder: (context, savedIds, child) {
              final isSaved = savedIds.contains(storyTitle);
              return _OptionItem(
                ctx: context,
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                label: isSaved ? 'Saved' : 'Save to Playlist',
                scale: scale,
                onTap: () => SaveManager().toggleSave(storyTitle, storyData),
              );
            },
          ),
          _Divider(),
          _OptionItem(
            ctx: context,
            icon: Icons.share_outlined,
            label: 'Share',
            scale: scale,
            onTap: () => ShareHelper.shareStory(
              storyTitle,
              'I found this interesting story on True Story. Check it out!',
            ),
          ),
          _Divider(),
          ValueListenableBuilder<Set<String>>(
            valueListenable: DownloadManager().downloadedStoryIds,
            builder: (context, downloadedIds, child) {
              final isDownloaded = downloadedIds.contains(storyTitle);
              return _OptionItem(
                ctx: context,
                icon: isDownloaded ? Icons.file_download_done : Icons.file_download_outlined,
                label: isDownloaded ? 'Remove Download' : 'Download Story',
                scale: scale,
                onTap: () {
                  if (isDownloaded) {
                    DownloadManager().removeDownload(storyTitle);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download removed')),
                    );
                  } else {
                    DownloadManager().downloadStory(storyTitle, storyData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Downloading story...',
                          style: GoogleFonts.poppins(fontSize: 12 * scale),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF7C348D),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(20 * scale),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                      ),
                    );

                    // Simulate a slight delay for download "completion" feedback
                    Future.delayed(const Duration(seconds: 1), () {
                       if(context.mounted) {
                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Story downloaded successfully!',
                              style: GoogleFonts.poppins(fontSize: 12 * scale),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(20 * scale),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                          ),
                        );
                       }
                    });
                  }
                },
              );
            },
          ),
          if (storyData?['isUploadedStory'] == true) ...[
            _Divider(),
            _OptionItem(
              ctx: context,
              icon: Icons.delete_outline,
              label: 'Delete My Story',
              scale: scale,
              color: Colors.red,
              onTap: () => _showDeleteConfirmation(context, storyTitle, scale),
            ),
          ],
          SizedBox(height: 10 * scale),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String title, double scale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Story?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete this story? This action cannot be undone.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () {
              PostManager().deletePost(title);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story deleted successfully')),
              );
            }, 
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final BuildContext ctx;
  final IconData icon;
  final String label;
  final double scale;
  final VoidCallback onTap;
  final Color? color;
  const _OptionItem({
    required this.ctx,
    required this.icon,
    required this.label,
    required this.scale,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.black87;
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
      borderRadius: BorderRadius.circular(8 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 8 * scale),
        child: Row(
          children: [
            Icon(icon, size: 24 * scale, color: displayColor),
            SizedBox(width: 16 * scale),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: displayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 0.5, color: Colors.black12);
}
