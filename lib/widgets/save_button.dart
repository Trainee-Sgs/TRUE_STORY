import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/save_manager.dart';

class SaveButton extends StatelessWidget {
  final String id;
  final double scale;
  final String? label;
  final Color? color;
  final bool showLabel;
  final Map<String, dynamic>? storyData;

  const SaveButton({
    super.key,
    required this.id,
    required this.scale,
    this.label = 'Save',
    this.color,
    this.showLabel = true,
    this.storyData,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SaveManager().savedStoryIds,
      builder: (context, savedIds, child) {
        final isSaved = savedIds.contains(id);
        
        if (showLabel) {
          return GestureDetector(
            onTap: () {
              SaveManager().toggleSave(id, storyData);
              _showFeedback(context, isSaved);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 20 * scale,
                  color: isSaved ? const Color(0xFF7C348D) : (color ?? Colors.black54),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  label!,
                  style: GoogleFonts.poppins(
                    fontSize: 10 * scale,
                    color: isSaved ? const Color(0xFF7C348D) : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else {
          return IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 24 * scale,
              color: isSaved ? const Color(0xFF7C348D) : (color ?? Colors.white),
            ),
            onPressed: () {
              SaveManager().toggleSave(id, storyData);
              _showFeedback(context, isSaved);
            },
          );
        }
      },
    );
  }

  void _showFeedback(BuildContext context, bool wasSaved) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved ? 'Unsaved' : 'Saved',
          style: GoogleFonts.poppins(fontSize: 12 * scale),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF7C348D),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20 * scale),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
      ),
    );
  }
}
