import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentBottomSheet extends StatefulWidget {
  final double scale;
  const CommentBottomSheet({super.key, required this.scale});

  static void show(BuildContext context, double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(scale: scale),
    );
  }

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isNewSelected = true;

  // Mock data for comments
  final List<Map<String, dynamic>> _comments = [
    {
      'name': 'Tamilarasi',
      'time': '4 minutes ago',
      'text': 'This video helped a lot, thank you',
      'likes': 6,
      'dislikes': 4,
      'replies': [],
    },
    {
      'name': 'Sowmiya',
      'time': '12 minutes ago',
      'text': 'This deserves more views \u{1F44C}',
      'likes': 6,
      'dislikes': 4,
      'replies': [
        {
          'name': 'Thanu sri',
          'time': '12 minutes ago',
          'text': 'This deserves more views \u{1F44C}',
          'likes': 6,
          'dislikes': 4,
        },
      ],
    },
  ];

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'name': 'You',
        'time': 'Just now',
        'text': _commentController.text.trim(),
        'likes': 0,
        'dislikes': 0,
        'replies': [],
      });
      _commentController.clear();
    });
    // Scroll to top or just show the new comment
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: h * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Sorting Tabs
          _buildSortingTabs(),

          // Comment Count
          _buildCommentCount(),

          // Comment List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16 * widget.scale),
              itemCount: _comments.length,
              itemBuilder: (context, index) =>
                  _buildCommentItem(_comments[index]),
            ),
          ),

          // Input Bar
          _buildInputBar(bottomInset),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20 * widget.scale,
        10 * widget.scale,
        10 * widget.scale,
        10 * widget.scale,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Comment',
            style: GoogleFonts.poppins(
              fontSize: 18 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.cancel_outlined,
              color: Colors.black,
              size: 28 * widget.scale,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSortingTabs() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15 * widget.scale,
        horizontal: 20 * widget.scale,
      ),
      color: Colors.grey[100],
      child: Row(
        children: [
          _buildTabButton('New', _isNewSelected),
          SizedBox(width: 15 * widget.scale),
          _buildTabButton('Top', !_isNewSelected),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isNewSelected = label == 'New';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 25 * widget.scale,
          vertical: 8 * widget.scale,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10 * widget.scale),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14 * widget.scale,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCount() {
    return Padding(
      padding: EdgeInsets.all(20 * widget.scale),
      child: Row(
        children: [
          Text(
            'Comment',
            style: GoogleFonts.poppins(
              fontSize: 18 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 10 * widget.scale),
          Text(
            '${_comments.length + 1}', // Mock count
            style: GoogleFonts.poppins(
              fontSize: 18 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    Map<String, dynamic> comment, {
    bool isReply = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20 * widget.scale,
        left: isReply ? 40 * widget.scale : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: (isReply ? 12 : 18) * widget.scale,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage(
              'assets/images/ratan_tata.png',
            ), // Default mock avatar
          ),
          SizedBox(width: 12 * widget.scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14 * widget.scale,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: '${comment['name']} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '• ${comment['time']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10 * widget.scale,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4 * widget.scale),
                Text(
                  comment['text'],
                  style: GoogleFonts.poppins(
                    fontSize: 13 * widget.scale,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8 * widget.scale),
                Row(
                  children: [
                    _buildInteractionButton(
                      Icons.thumb_up_alt_outlined,
                      comment['likes'].toString(),
                    ),
                    _buildInteractionButton(
                      Icons.thumb_down_alt_outlined,
                      comment['dislikes'].toString(),
                    ),
                    _buildInteractionButton(Icons.chat_bubble_outline, ''),
                  ],
                ),
                if (comment['replies'] != null && comment['replies'].isNotEmpty)
                  ...(comment['replies'] as List)
                      .map((reply) => _buildCommentItem(reply, isReply: true))
                      .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count) {
    return Padding(
      padding: EdgeInsets.only(right: 20 * widget.scale),
      child: Row(
        children: [
          Icon(icon, size: 16 * widget.scale, color: Colors.grey[600]),
          if (count.isNotEmpty) ...[
            SizedBox(width: 6 * widget.scale),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 12 * widget.scale,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16 * widget.scale,
        10 * widget.scale,
        16 * widget.scale,
        10 * widget.scale + bottomInset,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16 * widget.scale,
            backgroundColor: Colors.grey[300],
            backgroundImage: const AssetImage(
              'assets/images/ratan_tata.png',
            ), // User's avatar
          ),
          SizedBox(width: 12 * widget.scale),
          Expanded(
            child: Container(
              height: 45 * widget.scale,
              padding: EdgeInsets.symmetric(horizontal: 20 * widget.scale),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFFF0F1,
                ), // Light pinkish as in screenshot
                borderRadius: BorderRadius.circular(25 * widget.scale),
              ),
              child: TextField(
                controller: _commentController,
                style: GoogleFonts.poppins(fontSize: 13 * widget.scale),
                decoration: InputDecoration(
                  hintText: 'Drop Your Comment here....',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 13 * widget.scale,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10 * widget.scale,
                  ),
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),
          ),
          if (_commentController.text.isNotEmpty)
            IconButton(
              onPressed: _addComment,
              icon: Icon(
                Icons.send,
                color: const Color(0xFF7C348D),
                size: 24 * widget.scale,
              ),
            ),
        ],
      ),
    );
  }
}
