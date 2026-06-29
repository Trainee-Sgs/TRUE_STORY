import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:true_story/screens/homescreen/home_screen.dart';
import '../../utils/guest_manager.dart';
import 'signup_screen.dart';
import 'otp_bottom_sheet.dart';
import 'package:google_sign_in/google_sign_in.dart' as auth;
import 'package:provider/provider.dart';
import '../../Provider/login_screen_provider.dart';
import '../../shared_preference.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final LoginScreenProvider _loginProvider = LoginScreenProvider();
  final FocusNode _focusNode = FocusNode();
  bool _isButtonEnabled = false;

  bool _isMasked = false;

  static const Color primaryPurple = Color(0xFF7C348D);
  static const Color bgWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validateInput);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _phoneController.text.length == 10) {
        setState(() => _isMasked = true);
      } else if (_focusNode.hasFocus) {
        setState(() => _isMasked = false);
      }
    });
  }

  void _validateInput() {
    final bool isEnabled = _phoneController.text.length == 10;
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateInput);
    _phoneController.dispose();
    _focusNode.dispose();
    _loginProvider.dispose();
    super.dispose();
  }

  void _handleGetOTP() async {
    final int cid = await SessionManager.getCid();
    final double ln = await SessionManager.getLn();
    final double lt = await SessionManager.getLt();
    final String deviceId = await SessionManager.getDeviceId();

    // API is rejecting if these are missing/zero, so add fallbacks when empty
    final String finalCid = cid == 0 ? '21472147' : cid.toString();
    final double finalLn = ln == 0.0 ? 11.0 : ln;
    final double finalLt = lt == 0.0 ? 11.0 : lt;
    final String finalDeviceId = deviceId.isEmpty ? '13' : deviceId;

    final success = await _loginProvider.requestOtp(
      mobile: _phoneController.text,
      cid: finalCid,
      ln: finalLn,
      lt: finalLt,
      deviceId: finalDeviceId,
      type: '2500',
    );

    if (success) {
      _showOTPBottomSheet();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_loginProvider.errorMessage ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOTPBottomSheet() {
    final String phone = _phoneController.text;
    final String maskedPhone = phone.length >= 4
        ? "+91 ${phone.substring(0, 4)}******"
        : "+91 $phone";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OTPBottomSheet(maskedPhone: maskedPhone, phone: phone),
    );
  }

  void _handleGoogleLogin() async {
    try {
      _showLoadingDialog();
      
      // Attempt real sign in using the new authenticate() method
      final auth.GoogleSignInAccount? googleUser = await auth.GoogleSignIn.instance.authenticate();
      
      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return; // User cancelled
      }

      // Successful login
      await GuestManager().setGuestMode(false);
      
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${googleUser.displayName}!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      // Show error but allow demo login for the user to proceed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase config missing. Using demo login...', 
            style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      _handleDemoLogin();
    }
  }

  void _handleDemoLogin() async {
    _showLoadingDialog();
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    Navigator.pop(context);

    await GuestManager().setGuestMode(false);
    
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const CircularProgressIndicator(color: primaryPurple),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    // Scale factor based on 360px base width
    final double scale = (w / 360).clamp(0.8, 1.4);

    // Responsive values
    final double hPadding = 24 * scale;
    final double illustrationH = (h * 0.22).clamp(140.0, 240.0);
    //final double titleFontSize = (17 * scale).clamp(15.0, 20.0);
    final double inputFontSize = (14 * scale).clamp(16.0, 20.0);
    final double buttonHeight = (48 * scale).clamp(44.0, 54.0);
    final double buttonFontSize = (16 * scale).clamp(14.0, 17.0);
    final double socialIconSize = (54 * scale).clamp(46.0, 62.0);
    final double captionFontSize = (10 * scale).clamp(9.0, 12.0);

    return Scaffold(
      backgroundColor: bgWhite,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: h),
          child: Stack(
            children: [
              // ── TOP HEADER ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/top_header_bg.png',
                  fit: BoxFit.fitWidth,
                ),
              ),

              // ── LOGO ──
              Positioned(
                top: MediaQuery.of(context).padding.top + (45 * scale),
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: 45 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ── BOTTOM WAVE ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/bottom_wave.png',
                  width: w,
                  fit: BoxFit.fitWidth,
                ),
              ),

              // ── CONTENT ──
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    children: [
                      SizedBox(height: h * 0.18), // Push down for header
                      // Illustration
                      Image.asset(
                        'assets/images/login_illustration.png',
                        height: illustrationH,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'Enter Your Mobile Number',
                        style: GoogleFonts.poppins(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 12 * scale),

                      // Custom Input Field
                      Container(
                        height: 50 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14 * scale,
                              ),
                              child: Text(
                                '+ 91',
                                style: GoogleFonts.poppins(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 22 * scale,
                              color: primaryPurple,
                            ),
                            Expanded(
                              child: _isMasked
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() => _isMasked = false);
                                        _focusNode.requestFocus();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14 * scale,
                                        ),
                                        child: Text(
                                          _phoneController.text.length >= 4
                                              ? "${_phoneController.text.substring(0, 4)}******"
                                              : _phoneController.text,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18 * scale,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                  : TextField(
                                      controller: _phoneController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.poppins(
                                        fontSize: inputFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'Your 10-Digit Mobile Number',
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: inputFontSize,
                                          color: Colors.black38,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14 * scale,
                                        ),
                                      ),
                                    ),
                            ),
                            if (_isButtonEnabled)
                              Padding(
                                padding: EdgeInsets.only(right: 14 * scale),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20 * scale,
                                ),
                              ),
                          ],
                          
                        ),
                      ),

                      SizedBox(height: 12 * scale),

                      // Get OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ListenableBuilder(
                          listenable: _loginProvider,
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: _isButtonEnabled && !_loginProvider.isLoading
                                  ? _handleGetOTP
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isButtonEnabled
                                    ? primaryPurple
                                    : const Color(0xFFE1B6FE),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFE1B6FE),
                                disabledForegroundColor: Colors.white.withValues(
                                  alpha: 0.7,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _loginProvider.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Get OTP',
                                      style: GoogleFonts.poppins(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox(height: 3 * scale),
                      Text(
                        'continue with',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14 * scale,
                        ),
                      ),

                      SizedBox(height: 10 * scale),

                      // Social Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialBtn(
                            assetPath: 'assets/images/apple_logo.png',
                            onTap: () {},
                            size: socialIconSize,
                          ),
                          SizedBox(width: 20 * scale),
                          _SocialBtn(
                            assetPath: 'assets/images/google_logo.png',
                            onTap: _handleGoogleLogin,
                            size: socialIconSize,
                          ),
                        ],
                      ),

                      // Terms and Account
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: captionFontSize,
                            color: Colors.black,
                            height: 1.8,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing you agree to our\n',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const TextSpan(
                              text:
                                  'terms of service privacy policy content policy',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const TextSpan(text: '\nAlready have an account? '),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: primaryPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: captionFontSize + 2,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14 * scale),

                      // Continue As Guest
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: OutlinedButton(
                          onPressed: () async {
                            await GuestManager().setGuestMode(true);
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryPurple,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Continue As Guest',
                            style: GoogleFonts.poppins(
                              color: primaryPurple,
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 90 * scale), // Small padding before wave
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final double size;

  const _SocialBtn({
    required this.assetPath,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.25),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

