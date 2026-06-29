import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../setting/settings_screen.dart';
import '../Category/category_screen.dart';

import 'for_you_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../utils/post_manager.dart';
import '../../utils/chapter_helper.dart';

class UploadStoryScreen extends StatefulWidget {
  const UploadStoryScreen({super.key});

  @override
  State<UploadStoryScreen> createState() => _UploadStoryScreenState();
}

class _UploadStoryScreenState extends State<UploadStoryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedLanguage;
  String? _selectedCategory;
  bool _isExpanded = false;
  bool _isCategoryExpanded = false;
  
  File? _headerImage;
  File? _thumbnailFile;
  String? _thumbnailName;

  final List<String> _languages = ['Tamil', 'English', 'Malayalam', 'Hindi', 'Telugu', 'Kanada'];
  final List<String> _categories = ['Startup', 'General', 'Business', 'Education', 'Sports', 'Artists'];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _titleController.text.isNotEmpty &&
           _descriptionController.text.isNotEmpty &&
           _headerImage != null &&
           _thumbnailFile != null &&
           _selectedLanguage != null &&
           _selectedCategory != null;
  }

  Future<void> _pickHeaderImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _headerImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickThumbnailFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String fileName = result.files.single.name;
        if (fileName.toLowerCase().endsWith('.pdf')) {
          setState(() {
            _thumbnailFile = File(result.files.single.path!);
            _thumbnailName = fileName;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a valid PDF file.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<List<String>> _extractTextFromPdf() async {
    if (_thumbnailFile == null) return [];
    try {
      final PdfDocument document = PdfDocument(inputBytes: await _thumbnailFile!.readAsBytes());
      List<String> pagesText = [];
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        if (pageText.trim().isNotEmpty) {
          pagesText.add(pageText);
        }
      }
      document.dispose();
      return pagesText;
    } catch (e) {
      debugPrint("Error extracting text: $e");
      return ["Error reading document content."];
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
          'Upload',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Title
            _buildLabel('Story Title:', scale),
            _buildTextField(
              'Enter story title', 
              scale, 
              maxLines: 1, 
              controller: _titleController,
              onChanged: (_) => setState(() {}),
            ),
            
            SizedBox(height: 20 * scale),
            
            // Story Description
            _buildLabel('Story Description:', scale),
            _buildTextField(
              'Enter Description', 
              scale, 
              maxLines: 5, 
              controller: _descriptionController,
              onChanged: (_) => setState(() {}),
            ),
            
            SizedBox(height: 20 * scale),
            
            // Upload Header Image
            _buildLabel('Upload Header Image (Gallery):', scale),
            _buildUploadBox(
              icon: _headerImage != null ? Icons.image : Icons.add_photo_alternate_outlined,
              title: _headerImage != null ? 'Image Selected' : 'Select from Gallery',
              subtitle: _headerImage != null 
                  ? 'File: ${_headerImage!.path.split(Platform.pathSeparator).last}' 
                  : 'PNG, JPG (Max 5MB)', 
              scale: scale,
              isUploaded: _headerImage != null,
              onTap: _pickHeaderImage,
              preview: _headerImage != null ? Image.file(_headerImage!, fit: BoxFit.cover) : null,
            ),
            
            SizedBox(height: 20 * scale),
            
            // Upload Thumbnail Label
            _buildLabel('Upload PDF Document (Source):', scale),
            _buildUploadBox(
              icon: _thumbnailFile != null ? Icons.picture_as_pdf : Icons.upload_file_outlined,
              title: _thumbnailFile != null ? 'PDF Selected' : 'Select PDF Document',
              subtitle: _thumbnailFile == null ? 'Extract story content from PDF' : null,
              scale: scale,
              isUploaded: _thumbnailFile != null,
              onTap: _pickThumbnailFile,
            ),
            
            if (_thumbnailName != null) ...[
              SizedBox(height: 8 * scale),
              Row(
                children: [
                   Icon(Icons.check_circle, color: Color(0xFF7C348D), size: 16 * scale),
                   SizedBox(width: 8 * scale),
                   Expanded(
                     child: Text(
                       'Selected File: $_thumbnailName',
                       style: GoogleFonts.poppins(
                         fontSize: 12 * scale,
                         color: Colors.black87,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ),
                   IconButton(
                     onPressed: () => setState(() {
                       _thumbnailFile = null;
                       _thumbnailName = null;
                     }),
                     icon: Icon(Icons.close, size: 18 * scale, color: Colors.red),
                   ),
                ],
              ),
            ],
            
            SizedBox(height: 20 * scale),
            
            // Category Selector
            _buildLabel('Select Category:', scale),
            Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isCategoryExpanded = !_isCategoryExpanded),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(color: Colors.grey.shade500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory ?? 'Choose category',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: _selectedCategory != null ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                        Icon(
                          _isCategoryExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.black87,
                          size: 20 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isCategoryExpanded) ...[
                  SizedBox(height: 8 * scale),
                  Wrap(
                    spacing: 8 * scale,
                    runSpacing: 8 * scale,
                    children: _categories.map((cat) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                          _isCategoryExpanded = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
                        decoration: BoxDecoration(
                          color: _selectedCategory == cat ? const Color(0xFF7C348D) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            color: _selectedCategory == cat ? Colors.white : Colors.black87,
                            fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),

            SizedBox(height: 20 * scale),
            
            // Language Selector
            _buildLabel('Select Language:', scale),
            Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(color: Colors.grey.shade500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedLanguage ?? 'Select language',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: _selectedLanguage != null ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.black87,
                          size: 20 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  SizedBox(height: 8 * scale),
                  ..._languages.map((lang) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                        _isExpanded = false;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8 * scale),
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Text(
                        lang,
                        style: GoogleFonts.poppins(
                          fontSize: 14 * scale,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )).toList(),
                ],
              ],
            ),
            
            SizedBox(height: 40 * scale),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      side: const BorderSide(color: Color(0xFF7C348D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                    ),
                    child: Text(
                      'Save as Draft',
                      style: GoogleFonts.poppins(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C348D),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isFormValid 
                      ? () async {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: Color(0xFF7C348D)),
                            ),
                          );

                          // Extract text from PDF
                          final List<String> extractedPages = await _extractTextFromPdf();
                          final String fullText = extractedPages.join('\n\n');
                          
                          // Split into chapters
                          final chapters = ChapterHelper.splitIntoChapters(fullText);
                          final chapterTitles = chapters.map((c) => c['title']!).toList();
                          
                          if (mounted) Navigator.pop(context); // Close loading indicator

                          // Add to PostManager
                          PostManager().addPost({
                            'title': _titleController.text,
                            'description': _descriptionController.text,
                            'overview': _descriptionController.text, // Added for detail screen
                            'language': _selectedLanguage,
                            'category': _selectedCategory,
                            'image': _headerImage?.path ?? 'assets/images/ratan_tata.png',
                            'pdfPath': null, 
                            'originalPdfPath': _thumbnailFile?.path,
                            'fullText': fullText,
                            'extractedPages': extractedPages,
                            'views': '0',
                            'likes': '0',
                            'isLocalFile': _headerImage != null,
                            'isUploadedStory': true,
                            'rating': 4.5,
                            'bannerTitle': _titleController.text.split(' ')[0].toUpperCase(),
                            'chapters': chapters,
                            'chapterTitles': chapterTitles,
                          });
                          _showSuccessDialog(scale);
                        } 
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid ? const Color(0xFF7C348D) : Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                    ),
                    child: Text(
                      'Publish Story',
                      style: GoogleFonts.poppins(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, // Part of For You flow
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(child: const CategoryScreen()),
            );
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

  void _showSuccessDialog(double scale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24 * scale),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset( 
                'assets/images/upload.gif',
                height: 150 * scale,
                width: 150 * scale,
              ),
              //SizedBox(height: 10 * scale),
              Text(
                'Your Story Has been \nUploaded Successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3BA935), // Green color from the image
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20 * scale),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to For You screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C348D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, double scale, {int maxLines = 1, TextEditingController? controller, Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: Colors.grey.shade500),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13 * scale, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUploadBox({
    required IconData icon,
    required String title,
    String? subtitle,
    required double scale,
    bool isUploaded = false,
    VoidCallback? onTap,
    Widget? preview,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: isUploaded ? const Color(0xFF7C348D) : Colors.grey.shade600,
          strokeWidth: 1.5,
          gap: 5,
        ),
        child: Container(
          width: double.infinity,
          height: preview != null ? 150 * scale : null, // Fixed height for preview
          padding: EdgeInsets.symmetric(vertical: preview != null ? 0 : 24 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (preview != null) 
                ClipRRect(
                  borderRadius: BorderRadius.circular(12 * scale),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: preview,
                  ),
                ),
              if (preview != null) 
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon, 
                    size: 28 * scale, 
                    color: isUploaded ? (preview != null ? Colors.white : const Color(0xFF7C348D)) : Colors.grey
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      color: isUploaded ? (preview != null ? Colors.white : const Color(0xFF7C348D)) : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11 * scale,
                          color: isUploaded && preview != null ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double cornerRadius = 12.0;
    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(cornerRadius));
    final Path path = Path()..addRRect(rrect);

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
