import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/like_manager.dart';

class LikeButton extends StatefulWidget {
  final String id;
  final double scale;
  final String? label;
  final Color? color;
  final bool showLabel;

  const LikeButton({
    super.key,
    required this.id,
    required this.scale,
    this.label = 'Like',
    this.color,
    this.showLabel = true,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    final manager = LikeManager();
    final wasLiked = manager.isLiked(widget.id);
    
    if (!wasLiked) {
      _controller.forward(from: 0.0);
    }
    
    manager.toggleLike(widget.id);
    _showFeedback(context, wasLiked);
  }

  void _showFeedback(BuildContext context, bool wasLiked) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasLiked ? 'Unliked' : 'Liked',
          style: GoogleFonts.poppins(fontSize: 12 * widget.scale),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF7C348D),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20 * widget.scale),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * widget.scale)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: LikeManager().likedStoryIds,
      builder: (context, likedIds, child) {
        final isLiked = likedIds.contains(widget.id);
        
        if (widget.showLabel) {
          return GestureDetector(
            onTap: () => _handleTap(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20 * widget.scale,
                    color: isLiked ? Colors.red : (widget.color ?? Colors.black54),
                  ),
                ),
                SizedBox(height: 2 * widget.scale),
                Text(
                  widget.label!,
                  style: GoogleFonts.poppins(
                    fontSize: 10 * widget.scale,
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else {
          return IconButton(
            icon: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 24 * widget.scale,
                color: isLiked ? Colors.red : (widget.color ?? Colors.white),
              ),
            ),
            onPressed: () => _handleTap(context),
          );
        }
      },
    );
  }
}
