import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowersFollowingScreen extends StatefulWidget {
  final String title;
  final bool isReadOnly;
  const FollowersFollowingScreen({super.key, required this.title, this.isReadOnly = false});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> {
  late List<Map<String, String>> users;

  @override
  void initState() {
    super.initState();
    users = [
      {'name': 'Arun Kumar', 'username': '@arun_k', 'image': 'https://i.pravatar.cc/150?u=arun'},
      {'name': 'Deepika S', 'username': '@deepi_s', 'image': 'https://i.pravatar.cc/150?u=deepi'},
      {'name': 'Vijay Raj', 'username': '@vijay_r', 'image': 'https://i.pravatar.cc/150?u=vijay'},
      {'name': 'Sneha Rao', 'username': '@sneha_r', 'image': 'https://i.pravatar.cc/150?u=sneha'},
      {'name': 'Manoj P', 'username': '@manoj_p', 'image': 'https://i.pravatar.cc/150?u=manoj'},
      {'name': 'Priya K', 'username': '@priya_k', 'image': 'https://i.pravatar.cc/150?u=priya'},
    ];
  }

  Future<void> _handleAction(int index) async {
    final user = users[index];
    final bool isFollowersTitle = widget.title == 'Followers';
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                isFollowersTitle ? 'Remove Follower?' : 'Unfollow User?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isFollowersTitle 
                  ? 'Are you sure you want to remove ${user['name']} from your followers?'
                  : 'Are you sure you want to unfollow ${user['name']}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52D27), // Red button for action
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() {
        users.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFollowersTitle ? '${user['name']} removed from followers' : 'Unfollowed ${user['name']}',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF7C348D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                'No ${widget.title.toLowerCase()} found',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14 * scale),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16 * scale),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 24 * scale),
              itemBuilder: (context, index) {
                final user = users[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 25 * scale,
                      backgroundImage: NetworkImage(user['image']!),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 15 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            user['username']!,
                            style: GoogleFonts.poppins(
                              fontSize: 12 * scale,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isReadOnly)
                      ElevatedButton(
                        onPressed: () => _handleAction(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.title == 'Followers' ? Colors.grey.shade200 : const Color(0xFF7C348D),
                          foregroundColor: widget.title == 'Followers' ? Colors.black87 : Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                        ),
                        child: Text(
                          widget.title == 'Followers' ? 'Remove' : 'Following',
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
