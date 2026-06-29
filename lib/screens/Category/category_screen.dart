import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:true_story/screens/setting/settings_screen.dart';
import 'category_detail_screen.dart';
import '../For_You/for_you_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../Provider/category_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryProvider _categoryProvider = CategoryProvider();

  @override
  void initState() {
    super.initState();
    _categoryProvider.fetchCategories();
  }

  @override
  void dispose() {
    _categoryProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);

    final List<Map<String, dynamic>> categories = [
      {'title': 'Startup', 'color': const Color(0xFFFFC1EB), 'icon': Icons.rocket_launch_outlined},
      {'title': 'General', 'color': const Color(0xFFC4F9FF), 'icon': Icons.grid_view_outlined},
      {'title': 'Business', 'color': const Color(0xFFFFEF9A), 'icon': Icons.business_center_outlined},
      {'title': 'Education', 'color': const Color(0xFFFFB2B4), 'icon': Icons.school_outlined},
      {'title': 'Sports', 'color': const Color(0xFFE995FD), 'icon': Icons.sports_basketball_outlined},
      {'title': 'Artists', 'color': const Color(0xFF8BFDAB), 'icon': Icons.palette_outlined},
    ];

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
          'Categories',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _categoryProvider,
        builder: (context, _) {
          if (_categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C348D)));
          }

          if (_categoryProvider.errorMessage != null && _categoryProvider.categories.isEmpty) {
            return Center(
              child: Text(
                _categoryProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final fetchedCats = _categoryProvider.categories;

          if (fetchedCats.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          return GridView.builder(
            padding: EdgeInsets.all(16 * scale),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16 * scale,
              mainAxisSpacing: 16 * scale,
              childAspectRatio: 2.2,
            ),
            itemCount: fetchedCats.length,
            itemBuilder: (context, index) {
              final cat = fetchedCats[index];
              final style = categories[index % categories.length]; // cycle through local colors/icons

              // Extract title from API, fallback to 'Unknown'
              String title = 'Unknown';
              if (cat is Map<String, dynamic>) {
                title = cat['title'] ?? cat['name'] ?? cat['CategoryName'] ?? cat['category_name'] ?? 'Unknown';
              } else if (cat is String) {
                title = cat;
              }

              return _buildCategoryCard(
                context: context,
                title: title,
                color: style['color'] as Color,
                icon: style['icon'] as IconData,
                scale: scale,
              );
            },
          );
        }
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1, // Highlight "Category"
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: const ForYouScreen()),
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

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required double scale,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(categoryName: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        padding: EdgeInsets.all(12 * scale),
        child: Stack(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                icon,
                size: 40 * scale,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
