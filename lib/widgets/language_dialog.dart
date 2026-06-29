import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Provider/language_provider.dart';

class LanguageDialog extends StatefulWidget {
  final double scale;
  const LanguageDialog({super.key, required this.scale});

  static void show(BuildContext context, double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageDialog(scale: scale),
    );
  }

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  int _selectedIndex = 0; 
  final LanguageProvider _languageProvider = LanguageProvider();

  // Hardcoded fallback list to map colors or if API has issues
  final List<Map<String, String>> _fallbackLanguages = [
    {'native': 'தமிழ்', 'english': 'Tamil'},
    {'native': 'తెలుగు', 'english': 'Telugu'},
    {'native': 'English', 'english': 'English'},
    {'native': 'ಕನ್ನಡ', 'english': 'Kannada'},
    {'native': 'മലയാളം', 'english': 'Malayalam'},
    {'native': 'française', 'english': 'French'},
    {'native': 'हिन्दी', 'english': 'Hindi'},
  ];

  @override
  void initState() {
    super.initState();
    _languageProvider.fetchLanguages();
  }

  @override
  void dispose() {
    _languageProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * widget.scale).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20 * widget.scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25 * widget.scale),
        ),
      ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Select audio language for your shows',
                    style: GoogleFonts.poppins(
                      fontSize: 17 * widget.scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 24 * widget.scale, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 25 * widget.scale),
            
            // Language Grid
            ListenableBuilder(
              listenable: _languageProvider,
              builder: (context, _) {
                if (_languageProvider.isLoading) {
                  return SizedBox(
                    height: 100 * widget.scale,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C348D)),
                    ),
                  );
                }

                if (_languageProvider.errorMessage != null && _languageProvider.languages.isEmpty) {
                  return SizedBox(
                    height: 100 * widget.scale,
                    child: Center(
                      child: Text(
                        _languageProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final fetchedLangs = _languageProvider.languages.isNotEmpty 
                    ? _languageProvider.languages 
                    : _fallbackLanguages;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10 * widget.scale,
                    mainAxisSpacing: 10 * widget.scale,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: fetchedLangs.length,
                  itemBuilder: (context, index) {
                    final lang = fetchedLangs[index];
                    
                    String nativeName = 'Unknown';
                    String englishName = 'Unknown';

                    if (lang is Map) {
                      nativeName = lang['native'] ?? lang['name'] ?? lang['language_name'] ?? lang['language'] ?? 'Unknown';
                      englishName = lang['english'] ?? lang['english_name'] ?? 'Language';
                    } else if (lang is String) {
                      nativeName = lang;
                      englishName = 'Language';
                    }

                    return _buildLanguageItem(index, nativeName, englishName);
                  },
                );
              },
            ),
            
            SizedBox(height: 30 * widget.scale),
            
            // Save Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C348D),
                minimumSize: Size(double.infinity, 45 * widget.scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * widget.scale),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 18 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildLanguageItem(int index, String nativeName, String englishName) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * widget.scale),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8 * widget.scale),
        ),
        child: Row(
          children: [
            Container(
              width: 20 * widget.scale,
              height: 20 * widget.scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C348D) : Colors.grey.shade400,
                  width: 1.5 * widget.scale,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10 * widget.scale,
                        height: 10 * widget.scale,
                        decoration: const BoxDecoration(
                          color: Color(0xFFffffff),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10 * widget.scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14 * widget.scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    englishName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11 * widget.scale,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
