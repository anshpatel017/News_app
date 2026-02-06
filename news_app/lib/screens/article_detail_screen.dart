import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../utils/app_utils.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final isBookmarked = await _bookmarkService.isBookmarked(
        widget.article.id,
      );
      setState(() {
        _isBookmarked = isBookmarked;
      });
    } catch (error) {
      // Handle error silently
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isBookmarked) {
        await _bookmarkService.removeBookmark(widget.article.id);
        setState(() {
          _isBookmarked = false;
        });
        if (mounted) {
          AppUtils.showInfoMessage(context, 'Removed from bookmarks');
        }
      } else {
        await _bookmarkService.addBookmark(widget.article.id);
        setState(() {
          _isBookmarked = true;
        });
        if (mounted) {
          AppUtils.showSuccessMessage(context, 'Article saved!');
        }
      }
    } catch (error) {
      if (mounted) {
        AppUtils.showErrorMessage(context, 'Error updating bookmark');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.article.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.article.imageUrl,
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
                              Icons.article,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.article,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isBookmarked
                                ? const Color(0xFF2196F3)
                                : Colors.grey[600],
                          ),
                          onPressed: _toggleBookmark,
                        ),
                ),
              ),
            ],
          ),

          // Article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Source and date
                  Row(
                    children: [
                      Icon(Icons.source, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.source,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.timeAgo,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.article.category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.article.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Article content
                  Text(
                    widget.article.description.isNotEmpty
                        ? widget.article.description
                        : 'This is a detailed article about ${widget.article.title}. '
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
                              'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim '
                              'veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea '
                              'commodo consequat.\n\n'
                              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
                              'dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non '
                              'proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
                              'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium '
                              'doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore '
                              'veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
