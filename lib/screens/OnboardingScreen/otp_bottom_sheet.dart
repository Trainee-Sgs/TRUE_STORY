import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:true_story/screens/homescreen/home_screen.dart';
import '../../utils/guest_manager.dart';
import '../../Provider/login_screen_provider.dart';
import '../../shared_preference.dart';

class OTPBottomSheet extends StatefulWidget {
  final String maskedPhone;
  final String phone;
  const OTPBottomSheet({super.key, required this.maskedPhone, required this.phone});

  @override
  State<OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  int _counter = 30;
  Timer? _timer;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final LoginScreenProvider _otpProvider = LoginScreenProvider();

  bool _isVerifyEnabled = false;
  String? _localErrorMessage;

  void _checkInputCompletion() {
    bool allFilled = _controllers.every((c) => c.text.isNotEmpty);
    if (allFilled != _isVerifyEnabled) {
      setState(() => _isVerifyEnabled = allFilled);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (var controller in _controllers) {
      controller.addListener(_checkInputCompletion);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.removeListener(_checkInputCompletion);
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _otpProvider.dispose();
    super.dispose();
  }

  void _handleVerifyOTP() async {
    setState(() => _localErrorMessage = null);
    
    final int cid = await SessionManager.getCid();
    final double ln = await SessionManager.getLn();
    final double lt = await SessionManager.getLt();
    final String deviceId = await SessionManager.getDeviceId();
    final String otp = _controllers.map((c) => c.text).join();

    // API is rejecting if these are missing/zero, so add fallbacks when empty
    final String finalCid = cid == 0 ? '21472147' : cid.toString();
    final double finalLn = ln == 0.0 ? 11.0 : ln;
    final double finalLt = lt == 0.0 ? 11.0 : lt;
    final String finalDeviceId = deviceId.isEmpty ? '13' : deviceId;

    final success = await _otpProvider.verifyOtp(
      mobile: widget.phone,
      cid: finalCid,
      ln: finalLn,
      lt: finalLt,
      deviceId: finalDeviceId,
      type: '2501',
      otp: otp,
      token: '7e0cceaa8b95405150fa0f5b0c0c96f8',
    );

    if (success) {
      await SessionManager.saveLoginSession(
        cid: int.tryParse(finalCid) ?? 21472147,
        uid: widget.phone, // using phone as uid for now
        userName: 'User',
        authToken: 'dummy_token', // real token can be parsed from API if needed
      );
      
      await GuestManager().clearGuestData();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _localErrorMessage = _otpProvider.errorMessage ?? 'Invalid OTP';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 360).clamp(0.8, 1.4);
    const primaryPurple = Color(0xFF7C348D);
    const disabledPurple = Color(0xFFE1B6FE);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        12 * scale,
        24 * scale,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20 * scale,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle and close
          Stack(
            children: [
              Center(
                child: Container(
                  width: 40 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: primaryPurple.withAlpha(128),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 24 * scale),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),

          // Illustration
          Image.asset(
            'assets/images/otp.png',
            height: 120 * scale,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16 * scale),

          Text(
            'OTP Verification',
            style: GoogleFonts.poppins(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Enter the OTP sent to ${widget.maskedPhone}',
            style: GoogleFonts.poppins(
              fontSize: 14 * scale,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24 * scale),

          // OTP Inputs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => _OTPBox(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  _checkInputCompletion();
                },
              ),
            ),
          ),
          SizedBox(height: 16 * scale),

          // Resend Timer
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12 * scale,
                color: Colors.black,
              ),
              children: [
                const TextSpan(text: "Didn't Receive OTP? "),
                TextSpan(
                  text: 'Resend',
                  style: TextStyle(
                    color: _counter == 0 ? primaryPurple : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' OTP in 00:${_counter.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
          
          if (_localErrorMessage != null) ...[
            SizedBox(height: 12 * scale),
            Text(
              _localErrorMessage!,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          SizedBox(height: 16 * scale),

          // Verify Button
          SizedBox(
            width: double.infinity,
            height: 48 * scale,
            child: ListenableBuilder(
              listenable: _otpProvider,
              builder: (context, _) {
                return ElevatedButton(
                  onPressed: _isVerifyEnabled && !_otpProvider.isLoading
                      ? _handleVerifyOTP
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isVerifyEnabled
                        ? primaryPurple
                        : disabledPurple,
                    disabledBackgroundColor: disabledPurple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _otpProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'VERIFY & CONTINUE',
                          style: GoogleFonts.poppins(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OTPBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 360).clamp(0.8, 1.4);
    return SizedBox(
      width: 44 * scale,
      height: 48 * scale,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: 20 * scale,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7C348D), width: 1.5),
          ),
        ),
      ),
    );
  }
}
