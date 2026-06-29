import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:true_story/screens/OnboardingScreen/login_screen.dart';

import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../shared_preference.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDeviceInfoAndLocation();
  }

  Future<void> _fetchDeviceInfoAndLocation() async {
    String deviceId = 'unknown';
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (_) {}

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services to proceed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied. Please allow location access.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied, please enable from settings.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await SessionManager.saveDeviceInfo(
          deviceId: deviceId,
          lt: position.latitude,
          ln: position.longitude,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    // Scale factor based on a 360px base width — clamped to avoid extremes
    final double scale = (w / 360).clamp(0.75, 1.6);

    // Responsive values
    final double hPadding = 24 * scale;
    final double imageHeight = h * 0.42;
    final double titleFontSize = (28 * scale).clamp(20.0, 40.0);
    final double subtitleFontSize = (15 * scale).clamp(12.0, 20.0);
    final double buttonHeight = (56 * scale).clamp(48.0, 70.0);
    final double buttonFontSize = (17 * scale).clamp(14.0, 22.0);
    final double buttonRadius = (14 * scale).clamp(10.0, 20.0);
    final double bottomPadding = (36 * scale).clamp(20.0, 60.0);
    final double subtitleSpacing = (10 * scale).clamp(6.0, 18.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Success Collage Image
              Center(
                child: Image.asset(
                  'assets/images/collage.png',
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 1),

              // Headline
              Text(
                'Every Great Success\nBegan From Zero',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.15,
                ),
              ),

              SizedBox(height: subtitleSpacing),

              // Subtitle
              Text(
                'Real people. Real struggles. Real success',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: subtitleFontSize,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 3),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C348D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                    ),
                    elevation: 4,
                    shadowColor: const Color.fromRGBO(124, 52, 141, 0.35),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.poppins(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}
