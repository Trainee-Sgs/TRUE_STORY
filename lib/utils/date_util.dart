class DateUtil {
  static String getTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      final DateTime date = DateTime.parse(dateStr);
      final Duration diff = DateTime.now().difference(date);
      if (diff.inDays >= 365) {
        final years = (diff.inDays / 365).floor();
        return '$years Year ago';
      } else if (diff.inDays >= 30) {
        final months = (diff.inDays / 30).floor();
        return '$months Month ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} Day ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} Hour ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} Minute ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recent';
    }
  }
}
