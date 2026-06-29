import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      builder: (context) => OTPBottomSheet(maskedPhone: maskedPhone, phone: phone),
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
    final double socialIconSize = 48 * scale;
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
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _showOTPBottomSheet : null,
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
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12 * scale),

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
                SizedBox(height: 6 * scale),
                Text(
                  'continue with',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 13 * scale,
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
                      onTap: () {},
                      size: socialIconSize,
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
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
