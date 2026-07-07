import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/OnboardingScreen/logo.dart';
import 'utils/guest_manager.dart';
import 'utils/history_manager.dart';
import 'utils/post_manager.dart';
import 'utils/save_manager.dart';
import 'utils/download_manager.dart';
import 'utils/like_manager.dart';
import 'utils/feedback_manager.dart';
import 'package:google_sign_in/google_sign_in.dart' as auth;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GuestManager().init();
  await HistoryManager().init();
  await PostManager().init();
  await SaveManager().init();
  await DownloadManager().init();
  await LikeManager().init();
  await FeedbackManager().init();
  await auth.GoogleSignIn.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(                                  
      debugShowCheckedModeBanner: false,
      title: 'True Story',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.deepPurple,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const Logo(),
    );
  }
}
