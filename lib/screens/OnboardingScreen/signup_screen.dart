import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../shared_preference.dart';
import '../../Provider/signup_provider.dart';
import 'otp_bottom_sheet.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isButtonEnabled = false;
  final SignUpProvider _signUpProvider = SignUpProvider();

  Future<void> _performSignUp() async {
    final success = await _signUpProvider.performSignUp(
      name: _nameController.text,
      email: _emailController.text,
      mobileNumber: _mobileNumberController.text,
    );

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_signUpProvider.errorMessage ?? 'Signup failed')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Registered Successfully!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // go back to login screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C348D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Go to Login',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
    _emailController.addListener(_validateInput);
    _mobileNumberController.addListener(_validateInput);
  }

  void _validateInput() {
    final bool isEnabled = _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _mobileNumberController.text.length == 10;
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  static const Color primaryPurple = Color(0xFF7C348D);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  void _showOTPBottomSheet() {
    final String phone = _mobileNumberController.text;
    final String maskedPhone = phone.length >= 4
        ? "+91 ${phone.substring(0, 4)}******"
        : "+91 $phone";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OTPBottomSheet(
        maskedPhone: maskedPhone, 
        phone: phone,
        authorName: _nameController.text,
      ),
    );
  }

  //bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    // Scale factor based on 360px base width
    final double scale = (w / 360).clamp(0.8, 1.4);

    // Responsive values
    final double hPadding = 24 * scale;
    final double illustrationH = (h * 0.20).clamp(130.0, 230.0);
    final double titleFontSize = 20 * scale;
   // final double labelFontSize = 13 * scale;
   // final double inputFontSize = 13 * scale;
    final double buttonHeight = 46 * scale;
    final double captionFontSize = 10 * scale;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30 * scale),
                // Illustration
                Center(
                  child: Image.asset(
                    'assets/images/signup_illustration.png',
                    height: illustrationH,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20 * scale),
                // Title
                Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12 * scale),

                // Form Fields
                _buildInputField(
                  label: 'Name',
                  hint: 'Enter Your name',
                  controller: _nameController,
                  scale: scale,
                  labelFontSize: 14 * scale,
                  inputFontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10 * scale),
                _buildInputField(
                  label: 'Email',
                  hint: 'Enter your mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  scale: scale,
                  labelFontSize: 14 * scale,
                  inputFontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10 * scale),
                _buildInputField(
                  label: 'Mobile Number',
                  hint: 'Enter Your Mobile Number',
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                  scale: scale,
                  labelFontSize: 14 * scale,
                  inputFontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  maxLength: 10,
                ),
                SizedBox(height: 16 * scale),

                // Sign Up Button
                ListenableBuilder(
                  listenable: _signUpProvider,
                  builder: (context, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled && !_signUpProvider.isLoading ? _performSignUp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled ? primaryPurple : const Color(0xFFE1B6FE),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE1B6FE),
                          disabledForegroundColor: Colors.white.withAlpha(180),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _signUpProvider.isLoading 
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 12 * scale),


                // Back to Login
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: captionFontSize + 2,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: captionFontSize + 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    required double scale,
    required double labelFontSize,
    required double inputFontSize,
    FontWeight fontWeight = FontWeight.w500,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: labelFontSize,
            fontWeight: fontWeight,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6 * scale),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: GoogleFonts.poppins(fontSize: inputFontSize),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: inputFontSize,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20 * scale,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 12 * scale,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
