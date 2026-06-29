import 'dart:core';

class ChapterHelper {
  // Common patterns for chapter headings
  static final List<RegExp> _chapterPatterns = [
    RegExp(r'^Chapter\s+\d+\b', caseSensitive: false),
    RegExp(r'^CHAPTER\s+[A-Z\d]+\b', caseSensitive: false),
    RegExp(r'^Section\s+\d+\b', caseSensitive: false),
    RegExp(r'^\d+\.\s+[A-Z]', caseSensitive: true), // e.g., "1. Introduction"
  ];

  static List<Map<String, String>> splitIntoChapters(String text) {
    if (text.isEmpty) return [];

    final lines = text.split('\n');
    final List<Map<String, String>> chapters = [];
    
    String currentChapterTitle = "Introduction";
    StringBuffer currentChapterContent = StringBuffer();

    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      bool isHeading = false;

      // Check if line matches any chapter pattern
      for (var pattern in _chapterPatterns) {
        if (pattern.hasMatch(trimmedLine)) {
          isHeading = true;
          break;
        }
      }

      // If it looks like a heading (short and matches pattern)
      if (isHeading && trimmedLine.length < 100) {
        // Save previous chapter if it has content
        if (currentChapterContent.isNotEmpty) {
          chapters.add({
            'title': currentChapterTitle,
            'content': currentChapterContent.toString().trim(),
          });
        }
        
        currentChapterTitle = trimmedLine;
        currentChapterContent = StringBuffer();
      } else {
        currentChapterContent.writeln(line);
      }
    }

    // Add final chapter
    if (currentChapterContent.isNotEmpty) {
      chapters.add({
        'title': currentChapterTitle,
        'content': currentChapterContent.toString().trim(),
      });
    }

    // If only one "Introduction" chapter was made but we text, just name it "Full Story"
    if (chapters.length == 1 && chapters.first['title'] == 'Introduction' && text.length > 500) {
       chapters.first['title'] = "Story Content";
    }

    // If no chapters were detected at all
    if (chapters.isEmpty && text.isNotEmpty) {
      chapters.add({
        'title': 'Story Content',
        'content': text.trim(),
      });
    }

    return chapters;
  }
}
