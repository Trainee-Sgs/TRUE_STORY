import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../Category/category_screen.dart';
import '../setting/settings_screen.dart';
import '../../Provider/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key}); 
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  
  final ProfileProvider _profileProvider = ProfileProvider();

  @override
  void initState() {
    super.initState();
    _fetchAndPopulateProfile();
  }

  Future<void> _fetchAndPopulateProfile() async {
    await _profileProvider.fetchProfile();
    final data = _profileProvider.profileData;
    if (data != null) {
      if (mounted) {
        setState(() {
          _nameController.text = data['name']?.toString() ?? _nameController.text;
          _usernameController.text = data['username']?.toString() ?? _usernameController.text;
          _mobileNumberController.text = data['mobile_number']?.toString() ?? _mobileNumberController.text;
          _bioController.text = data['bio']?.toString() ?? _bioController.text;
          _linkController.text = data['link']?.toString() ?? _linkController.text;
          _genderController.text = data['gender']?.toString() ?? _genderController.text;
        });
      }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.check, color: Colors.white, size: 24 * scale),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20 * scale),
          child: Column(
            children: [
              // Input Fields
              ListenableBuilder(
                listenable: _profileProvider,
                builder: (context, child) {
                  if (_profileProvider.isLoading) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 40 * scale),
                      child: const CircularProgressIndicator(color: Color(0xFF7C348D)),
                    );
                  }
                  return Column(
                    children: [
                      if (_profileProvider.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 20 * scale),
                          child: Text(
                            _profileProvider.errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 13 * scale),
                          ),
                        ),
                      _buildInputField('Name :', _nameController, scale),
                      _buildInputField('Username :', _usernameController, scale),
                      _buildInputField('Mobile Number :', _mobileNumberController, scale),
                      _buildInputField('Bio :', _bioController, scale),
                      _buildInputField('Add Link :', _linkController, scale),
                      _buildInputField('Gender :', _genderController, scale),
                    ],
                  );
                },
              ),
              
              SizedBox(height: 40 * scale),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, // Highlight "For You"
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: const CategoryScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13 * scale,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
            height: 45 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(
                fontSize: 14 * scale,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
