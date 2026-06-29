import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/share_helper.dart';
import '../../utils/save_manager.dart';
import '../../utils/history_manager.dart';
import '../../utils/download_manager.dart';
import '../homescreen/story_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  
  // Selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedStoryIds = {};

  @override
  void initState() {
    super.initState();
    // Listen to history changes if needed
    HistoryManager().addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    HistoryManager().removeListener(_onHistoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _filteredHistoryItems {
    final items = HistoryManager().historyItems;
    if (_searchQuery.isEmpty) return items;
    return items
        .where((item) => item['title']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleSelection(String title) {
    setState(() {
      if (_selectedStoryIds.contains(title)) {
        _selectedStoryIds.remove(title);
        if (_selectedStoryIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedStoryIds.add(title);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll() {
    final items = _filteredHistoryItems;
    setState(() {
      if (_selectedStoryIds.length == items.length) {
        _selectedStoryIds.clear();
        _isSelectionMode = false;
      } else {
        for (var item in items) {
          _selectedStoryIds.add(item['title']);
        }
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: Text('Remove ${_selectedStoryIds.length} items from history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryManager().removeFromHistory(_selectedStoryIds.toList());
      setState(() {
        _selectedStoryIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);
    final historyItems = _filteredHistoryItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C348D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isSelectionMode ? Icons.close : Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isSelectionMode) {
              setState(() {
                _isSelectionMode = false;
                _selectedStoryIds.clear();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: _isSelectionMode
            ? Text('${_selectedStoryIds.length} Selected', style: GoogleFonts.poppins(color: Colors.white))
            : (_isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Search history...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 16 * scale),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  )
                : Text(
                    'History',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _selectAll,
              child: Text(
                _selectedStoryIds.length == historyItems.length ? 'Unselect All' : 'Select All',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12 * scale),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _deleteSelected,
            ),
          ] else ...[
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white, size: 22 * scale),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
        ],
      ),
      body: historyItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60 * scale, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? 'Your history is empty' : 'No matches found',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14 * scale),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16 * scale),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                final String id = item['title'];
                final isSelected = _selectedStoryIds.contains(id);

                return Stack(
                  children: [
                    GestureDetector(
                      onLongPress: () => _toggleSelection(id),
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelection(id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoryDetailScreen(storyData: item),
                              ),
                            );
                          }
                        },
                        child: _buildHistoryCard(item, scale, context, isSelected),
                      ),
                    if (_isSelectionMode)
                      Positioned(
                        right: 18 * scale,
                        top: 10 * scale,
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFF7C348D) : Colors.grey.shade400,
                          size: 20 * scale,
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, double scale, BuildContext context, bool isSelected) {
    final bool isLocalFile = item['isLocalFile'] ?? false;
    final String imagePath = item['image'] ?? 'assets/images/placeholder.png';

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      height: 100 * scale,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDEFFF) : Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(
          color: isSelected ? const Color(0xFF7C348D).withOpacity(0.5) : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(15 * scale)),
            child: isLocalFile 
              ? Image.file(
                  File(imagePath),
                  width: 100 * scale,
                  height: 100 * scale,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  imagePath,
                  width: 100 * scale,
                  height: 100 * scale,
                  fit: BoxFit.cover,
                ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (!_isSelectionMode)
                        GestureDetector(
                          onTap: () => _showMoreOptions(context, scale, item),
                          child: Icon(Icons.more_vert, size: 18 * scale, color: Colors.black54),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 12 * scale, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            item['views'] ?? '0',
                            style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.black45),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.favorite_border, size: 12 * scale, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            item['likes'] ?? '0',
                            style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.black45),
                          ),
                        ],
                      ),
                      Text(
                        item['readTime'] ?? '2 min read',
                        style: GoogleFonts.poppins(fontSize: 10 * scale, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context, double scale, Map<String, dynamic> storyData) {
    String storyId = storyData['title'] ?? 'unknown';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
        ),
        padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 16 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<Set<String>>(
              valueListenable: SaveManager().savedStoryIds,
              builder: (context, savedIds, child) {
                final isSaved = savedIds.contains(storyId);
                return _buildOptionItem(
                  context,
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  isSaved ? 'Saved' : 'Save to Playlist',
                  scale,
                  () => SaveManager().toggleSave(storyId, storyData),
                );
              },
            ),
            _buildDivider(),
            _buildOptionItem(context, Icons.share_outlined, 'Share', scale, () {
               ShareHelper.shareStory(storyId, 'Found this interesting story!');
            }),
            _buildDivider(),
            _buildOptionItem(context, Icons.file_download_outlined, 'Download Story', scale, () {
              DownloadManager().downloadStory(storyId, storyData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Story downloaded successfully!', style: GoogleFonts.poppins(fontSize: 12 * scale)),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(20 * scale),
                ),
              );
            }),
            _buildDivider(),
            _buildOptionItem(context, Icons.delete_outline, 'Remove from History', scale, () {
              HistoryManager().removeFromHistory([storyId]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed from history', style: GoogleFonts.poppins(fontSize: 12 * scale)),
                  backgroundColor: const Color(0xFF7C348D),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(20 * scale),
                  duration: const Duration(seconds: 1),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String label, double scale, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 8 * scale),
        child: Row(
          children: [
            Icon(icon, size: 24 * scale, color: Colors.black87),
            SizedBox(width: 16 * scale),
            Text(label, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Colors.black12);
  }
}
