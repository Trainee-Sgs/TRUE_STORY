import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/pagination_helper.dart';
import '../../utils/save_manager.dart';
import '../../utils/share_helper.dart';
import '../../widgets/like_button.dart';
import '../../utils/feedback_manager.dart';
import '../../utils/history_manager.dart';

class StoryReaderScreen extends StatefulWidget {
  final Map<String, dynamic> storyData;
  const StoryReaderScreen({super.key, required this.storyData});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  // Reader Settings
  double _fontSize = 16.0;
  int _readerMode = 0; // 0: Light, 1: Sepia, 2: Dark
  List<_ReaderPage> _dynamicPages = [];
  bool _isPaginated = false;
  int _currentChapterIndex = 0;
  List<Map<String, dynamic>> _storyChapters = [];

  int _selectedFeedback = -1; // -1: None, 0: Sad, 1: Happy, 2: Love
  bool _feedbackSubmitted = false;
  late final String _storyId;

  @override
  void initState() {
    super.initState();
    _storyId = widget.storyData['title'] ?? 'unknown_story';
    _storyChapters = List<Map<String, dynamic>>.from(widget.storyData['chapters'] ?? []);
    _feedbackSubmitted = FeedbackManager().hasSubmitted(_storyId);
    
    // Add to History
    HistoryManager().addToHistory(widget.storyData);
  }

  void _calculatePages(double maxWidth, double maxHeight) {
    _dynamicPages = [];
    final List<String>? extractedPages = (widget.storyData['extractedPages'] as List?)?.cast<String>();
    
    if (_storyChapters.isNotEmpty) {
      // Logic for chapters
      final String fullText = _storyChapters[_currentChapterIndex]['content'] ?? "";
      final pagedTexts = PaginationHelper.paginateText(
        text: fullText,
        fontSize: _fontSize,
        lineHeight: 1.6,
        textStyle: GoogleFonts.poppins(color: _getTextColor()),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      );
      _dynamicPages = pagedTexts.map((t) => _ReaderPage(text: t)).toList();
    } else if (extractedPages != null && extractedPages.isNotEmpty) {
      // Logic for PDF page-wise calculation
      for (int i = 0; i < extractedPages.length; i++) {
        final List<String> pagedTexts = PaginationHelper.paginateText(
          text: extractedPages[i],
          fontSize: _fontSize,
          lineHeight: 1.6,
          textStyle: GoogleFonts.poppins(color: _getTextColor()),
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        );
        for (var t in pagedTexts) {
          _dynamicPages.add(_ReaderPage(text: t, originalPdfPage: i + 1));
        }
      }
    } else {
      // Fallback for overview or other content strings
      String fullText = widget.storyData['fullText'] ?? 
                             widget.storyData['content'] ??
                             widget.storyData['overview'] ??
                             widget.storyData['description'] ?? 
                             widget.storyData['story_description'] ??
                             "";
      if (fullText.trim().isEmpty) {
        fullText = "No story content available.";
      }
      final pagedTexts = PaginationHelper.paginateText(
        text: fullText,
        fontSize: _fontSize,
        lineHeight: 1.6,
        textStyle: GoogleFonts.poppins(color: _getTextColor()),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      );
      _dynamicPages = pagedTexts.map((t) => _ReaderPage(text: t)).toList();
    }
    
    setState(() => _isPaginated = true);
  }

  Color _getBackgroundColor() {
    switch (_readerMode) {
      case 1: return const Color(0xFFF4ECD8); // Sepia
      case 2: return const Color(0xFF121212); // Dark
      default: return Colors.white;
    }
  }

  Color _getTextColor() {
    return _readerMode == 2 ? Colors.white : Colors.black87;
  }

  Color _getCategoryThemeColor(String category) {
    switch (category.toLowerCase()) {
      case 'startup': return const Color(0xFFFFC1EB);
      case 'general': return const Color(0xFFC4F9FF);
      case 'business': return const Color(0xFFFFEF9A);
      case 'education': return const Color(0xFFFFB2B4);
      case 'sports': return const Color(0xFFE995FD);
      case 'artists': return const Color(0xFF8BFDAB);
      default: return const Color(0xFFF3E5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final double scale = (w / 360).clamp(0.8, 1.4);

    if (!_isPaginated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePages(w, h - 80));
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF7C348D))));
    }
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Stack(
        children: [
          Column(
            children: [
              // Fixed Header Section
              _buildFixedHeader(scale),
              
              // Scrollable Story Content
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _dynamicPages.length + 1, // Pages + Footer
                  itemBuilder: (context, index) {
                    if (index == _dynamicPages.length) {
                      // Footer
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'The End',
                                style: GoogleFonts.poppins(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF7C348D),
                                ),
                              ),
                            ),
                          ),
                          _buildFeedbackCard(scale),
                          const SizedBox(height: 60),
                        ],
                      );
                    }

                    // Story Paragraphs
                    final page = _dynamicPages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        page.text,
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize * scale,
                          color: _getTextColor(),
                          height: 1.8,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Actions Overlay (Already fixed at top)
          _buildReaderOverlay(scale),
        ],
      ),
    );
  }

  Widget _buildFixedHeader(double scale) {
    final category = widget.storyData['category'] ?? 'TRUE STORY';
    final title = widget.storyData['title'] ?? '';
    final author = widget.storyData['author'] ?? 'Anonymous';
    final String image = widget.storyData['image']?.toString().trim() ?? widget.storyData['header_image']?.toString().trim() ?? 'assets/images/ratan_tata.png';
    final bool isLocalFile = widget.storyData['isLocalFile'] ?? false;
    final themeColor = _getCategoryThemeColor(category);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Background Area
          Stack(
            children: [
              // Category Theme Background
              Container(
                height: 220 * scale,
                width: double.infinity,
                color: themeColor.withValues(alpha: 0.1),
              ),
              
              // Image on the right - "right fulla cover"
              Positioned(
                right: -40 * scale,
                top: 0,
                bottom: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(
                        opacity: 0.9 * value,
                        child: SizedBox(
                          width: 260 * scale,
                          child: Stack(
                            children: [
                              isLocalFile 
                                ? Image.file(
                                    File(image), fit: BoxFit.cover, height: double.infinity, width: double.infinity,
                                    errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
                                  )
                                : image.startsWith('http') || image.startsWith('https')
                                    ? Image.network(
                                        image, fit: BoxFit.cover, height: double.infinity, width: double.infinity,
                                        errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
                                      )
                                    : Image.asset(
                                        image, fit: BoxFit.cover, height: double.infinity, width: double.infinity,
                                        errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
                                      ),
                              // Gradient to blend the image into the theme color
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeColor.withValues(alpha: 0.0),
                                      themeColor.withValues(alpha: 0.0),
                                      themeColor.withValues(alpha: 0.0),
                                      themeColor.withValues(alpha: 1.0),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeColor.withValues(alpha: 1.0),
                                      themeColor.withValues(alpha: 0.0),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: const [0.0, 0.4],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content on top of background
              Padding(
                padding: EdgeInsets.fromLTRB(24 * scale, 100 * scale, 140 * scale, 30 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: themeColor, width: 1),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 24 * scale,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 2,
                          color: themeColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'By $author',
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor().withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
        ],
      ),
    );
  }


  Widget _buildReaderOverlay(double scale) {
    final String storyId = widget.storyData['title'] ?? 'unknown';
    final category = widget.storyData['category'] ?? 'TRUE STORY';
    final themeColor = _getCategoryThemeColor(category);

    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withValues(alpha: 0.9),
              themeColor.withValues(alpha: 0.0),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: 40 * scale, left: 10 * scale, right: 10 * scale, bottom: 20 * scale),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: _getTextColor()), 
              onPressed: () => Navigator.pop(context)
            ),
            if (_storyChapters.isNotEmpty)
              _buildChapterSelector(scale),
            Row(
              children: [
                // ── Like Button ──
                LikeButton(
                  id: storyId,
                  scale: scale,
                  showLabel: false,
                  color: _getTextColor(),
                ),
                // ── Save Button ──
                ValueListenableBuilder<Set<String>>(
                  valueListenable: SaveManager().savedStoryIds,
                  builder: (context, savedIds, child) {
                    final isSaved = savedIds.contains(storyId);
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border, 
                        color: isSaved ? const Color(0xFF7C348D) : _getTextColor()
                      ),
                      onPressed: () => SaveManager().toggleSave(storyId, widget.storyData),
                    );
                  },
                ),
                // ── Share Button ──
                IconButton(
                  icon: Icon(Icons.share_outlined, color: _getTextColor()),
                  onPressed: () => ShareHelper.shareStory(storyId, 'Check out this amazing story on True Story!'),
                ),
                // ── Settings ──
                IconButton(
                  icon: Icon(Icons.format_size, color: _getTextColor()), 
                  onPressed: () => _showSettingsSheet(scale)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterSelector(double scale) {
    return PopupMenuButton<int>(
      onSelected: (index) {
        setState(() {
          _currentChapterIndex = index;
          _isPaginated = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: _getTextColor().withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Text('CH ${_currentChapterIndex + 1}', style: GoogleFonts.poppins(fontSize: 12 * scale, color: _getTextColor())),
            Icon(Icons.arrow_drop_down, color: _getTextColor(), size: 16 * scale),
          ],
        ),
      ),
      itemBuilder: (context) => _storyChapters.asMap().entries.map((e) => PopupMenuItem(
        value: e.key,
        child: Text(e.value['title'] ?? 'Chapter ${e.key + 1}', style: GoogleFonts.poppins(fontSize: 12 * scale, fontWeight: e.key == _currentChapterIndex ? FontWeight.bold : FontWeight.normal)),
      )).toList(),
    );
  }

  Widget _buildFeedbackCard(double scale) {
    if (_feedbackSubmitted) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14), // Reduced from 20 to increase width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background as in image
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            'HOW WAS YOUR\nEXPERIENCE !',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmoji(0, Icons.sentiment_very_dissatisfied, scale),
              _buildEmoji(1, Icons.sentiment_neutral, scale),
              _buildEmoji(2, Icons.sentiment_very_satisfied, scale),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _selectedFeedback == -1 ? null : () async {
              setState(() => _feedbackSubmitted = true);
              await FeedbackManager().submitFeedback(_storyId);
              
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for your feedback!', style: GoogleFonts.poppins()),
                  backgroundColor: const Color(0xFF7C348D),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedFeedback == -1 
                    ? Colors.grey.withValues(alpha: 0.3) // Disabled color
                    : const Color(0xFF7C348D),     // Enabled color (consistent with theme)
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'SUBMIT',
                style: GoogleFonts.poppins(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: _selectedFeedback == -1 ? Colors.black26 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmoji(int index, IconData icon, double scale) {
    bool isSelected = _selectedFeedback == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFeedback = index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE1BEE7).withValues(alpha: 0.5) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 40 * scale,
          color: isSelected ? const Color(0xFF7C348D) : Colors.black38,
        ),
      ),
    );
  }

  void _showSettingsSheet(double scale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _getBackgroundColor(),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.all(24 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _getTextColor())),
              SizedBox(height: 20 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildThemeOption(0, 'Light', Colors.white, Colors.black, setModalState),
                  _buildThemeOption(1, 'Sepia', const Color(0xFFF4ECD8), Colors.black, setModalState),
                  _buildThemeOption(2, 'Dark', const Color(0xFF121212), Colors.white, setModalState),
                ],
              ),
              SizedBox(height: 30 * scale),
              Text('Font Size', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _getTextColor())),
              Slider(
                value: _fontSize, min: 12, max: 24, activeColor: const Color(0xFF7C348D),
                onChanged: (val) {
                  setModalState(() => _fontSize = val);
                  setState(() { _fontSize = val; _isPaginated = false; });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(int mode, String label, Color bg, Color text, Function setModalState) {
    bool isSelected = _readerMode == mode;
    return GestureDetector(
      onTap: () { setModalState(() => _readerMode = mode); setState(() => _readerMode = mode); },
      child: Column(
        children: [
          Container(
            width: 80 * MediaQuery.of(context).size.width / 360,
            height: 40,
            decoration: BoxDecoration(color: bg, border: Border.all(color: isSelected ? const Color(0xFF7C348D) : Colors.grey.shade300, width: 2), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('Aa', style: TextStyle(color: text, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: _getTextColor())),
        ],
      ),
    );
  }

}

class _ReaderPage {
  final String text;
  final int? originalPdfPage;
  _ReaderPage({required this.text, this.originalPdfPage});
}
