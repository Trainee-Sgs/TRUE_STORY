import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime? _selectedDate;
  
  // Mock data for notifications with DateTime
  final List<Map<String, dynamic>> _allNotifications = [
    {
      'type': 'basic',
      'date': DateTime.now(),
      'icon': Icons.logout,
      'iconBgColor': Colors.orange.shade100,
      'iconColor': Colors.orange,
      'title': 'Your Premium trial ends tomorrow',
      'subtitle': 'Continue uninterrupted access.',
      'timeLabel': '8m ago',
    },
    {
      'type': 'basic',
      'date': DateTime.now(),
      'icon': Icons.trending_up,
      'iconBgColor': Colors.green.shade100,
      'iconColor': Colors.green,
      'title': 'Premium unlocked!',
      'subtitle': 'Enjoy all story ad-free.',
      'timeLabel': '2hrs ago',
    },
    {
      'type': 'story',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'thumbnail': 'assets/images/ratan_tata.png',
      'title': 'New inspiring Story is live now ✨',
      'timeLabel': '1 Day ago',
    },
    {
      'type': 'banner',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'bannerImage': 'assets/images/ratan_tata.png',
      'icon': Icons.favorite,
      'iconColor': Colors.red,
      'title': 'A Story you saved is waiting for you✨',
      'timeLabel': '1 Day ago',
    },
    {
      'type': 'banner',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'bannerImage': 'assets/images/sridhar.png',
      'icon': Icons.flash_on,
      'iconColor': Colors.blue,
      'title': 'Continue watching you left off✨',
      'timeLabel': '2 Day ago',
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedDate == null) return _allNotifications;
    return _allNotifications.where((n) {
      final notificationDate = n['date'] as DateTime;
      return notificationDate.year == _selectedDate!.year &&
             notificationDate.month == _selectedDate!.month &&
             notificationDate.day == _selectedDate!.day;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C348D),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);
    final notifications = _filteredNotifications;

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
          'Notification',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null 
                          ? 'Latest Notification' 
                          : 'Notifications for ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 6 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C348D),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.white, size: 16),
                          SizedBox(width: 4 * scale),
                          Text(
                            'Sort by',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () => setState(() => _selectedDate = null),
                    child: Text(
                      'Clear Filter',
                      style: GoogleFonts.poppins(color: const Color(0xFF7C348D), fontSize: 12 * scale),
                    ),
                  ),
                ),
              SizedBox(height: 20 * scale),
              
              if (notifications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none, size: 60 * scale, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications for this date.',
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14 * scale),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(notifications.length, (index) {
                  final n = notifications[index];
                  Widget item;
                  if (n['type'] == 'basic') {
                    item = _buildNotificationItem(
                      scale: scale,
                      icon: n['icon'],
                      iconBgColor: n['iconBgColor'],
                      iconColor: n['iconColor'],
                      title: n['title'],
                      subtitle: n['subtitle'],
                      time: n['timeLabel'],
                    );
                  } else if (n['type'] == 'story') {
                    item = _buildStoryNotificationItem(
                      scale: scale,
                      thumbnail: n['thumbnail'],
                      title: n['title'],
                      time: n['timeLabel'],
                    );
                  } else {
                    item = _buildBannerNotificationItem(
                      scale: scale,
                      bannerImage: n['bannerImage'],
                      icon: n['icon'],
                      iconColor: n['iconColor'],
                      title: n['title'],
                      time: n['timeLabel'],
                    );
                  }
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12 * scale),
                    child: item,
                  );
                }),
              
              SizedBox(height: 30 * scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required double scale,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24 * scale),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11 * scale,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 9 * scale,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryNotificationItem({
    required double scale,
    required String thumbnail,
    required String title,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8 * scale),
            child: Image.asset(
              thumbnail,
              width: 50 * scale,
              height: 50 * scale,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 9 * scale,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerNotificationItem({
    required double scale,
    required String bannerImage,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * scale),
            child: Image.asset(
              bannerImage,
              width: double.infinity,
              height: 150 * scale,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6 * scale),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16 * scale),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 9 * scale,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
