import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../Category/category_screen.dart';
import '../setting/settings_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key}); 
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Sowmiya');
  final TextEditingController _usernameController = TextEditingController(text: 'Sowmi_222');
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

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
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90 * scale,
                          height: 90 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/150?u=sowmiya'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Figma tick icon on the far right of the profile picture area
                        Positioned(
                          right: -w * 0.35,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.check, color: const Color(0xFF7C348D), size: 24 * scale),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Edit Picture',
                      style: GoogleFonts.poppins(
                        fontSize: 13 * scale,
                        color: const Color(0xFF7C348D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24 * scale),
              
              // Input Fields
              _buildInputField('Name :', _nameController, scale),
              _buildInputField('Username :', _usernameController, scale),
              _buildInputField('Bio :', _bioController, scale),
              _buildInputField('Add Link :', _linkController, scale),
              _buildInputField('Gender :', _genderController, scale),
              
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
