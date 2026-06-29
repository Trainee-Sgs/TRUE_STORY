import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static Future<void> shareStory(String title, String overview) async {
    final String text = 'Check out this amazing story on True Story: $title\n\n$overview\n\nDownload True Story App now!';
    await Share.share(text);
  }

  static Future<void> shareProfile(String name, String username) async {
    final String text = 'Follow $name ($username) on True Story to read amazing real-life stories!';
    await Share.share(text);
  }
}
