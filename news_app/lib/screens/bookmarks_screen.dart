import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../utils/app_utils.dart';
import 'article_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarks = await _bookmarkService.getMyBookmarks();
      setState(() {
        _bookmarkedArticles = bookmarks;
      });
    } catch (error) {
      if (mounted) {
        AppUtils.showErrorMessage(context, 'Failed to load bookmarks');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(Article article) async {
    try {
      await _bookmarkService.removeBookmark(article.id);

      setState(() {
        _bookmarkedArticles.removeWhere((a) => a.id == article.id);
      });

      if (mounted) {
        AppUtils.showInfoMessage(context, 'Removed from bookmarks');
      }
    } catch (error) {
      if (mounted) {
        AppUtils.showErrorMessage(context, 'Failed to remove bookmark');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'My Bookmarks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading bookmarks...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _bookmarkedArticles.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadBookmarks,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookmarkedArticles.length,
                itemBuilder: (context, index) {
                  final article = _bookmarkedArticles[index];
                  return _buildBookmarkCard(article);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save articles to read later',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home tab (this will be handled by main screen)
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.explore),
            label: const Text('Browse Articles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          ).then((_) {
            // Refresh bookmarks when returning from detail screen
            _loadBookmarks();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: article.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: article.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.article, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Article Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.source,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.timeAgo,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          article.category,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: TextStyle(
                          color: _getCategoryColor(article.category),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Remove bookmark button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeBookmark(article),
                tooltip: 'Remove bookmark',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'politics':
        return Colors.red[600]!;
      case 'tech':
        return Colors.blue[600]!;
      case 'sports':
        return Colors.green[600]!;
      case 'health':
        return Colors.purple[600]!;
      case 'entertainment':
        return Colors.orange[600]!;
      case 'business':
        return Colors.teal[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
