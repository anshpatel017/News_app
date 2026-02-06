import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../utils/app_utils.dart';
import 'login_screen.dart';
import 'article_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final String selectedCategory;
  final Function(String)? onCategoryChanged;

  const HomeScreen({
    super.key,
    this.selectedCategory = 'All',
    this.onCategoryChanged,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  final AuthService _authService = AuthService();
  final BookmarkService _bookmarkService = BookmarkService();

  List<Article> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  Set<String> _bookmarkedArticleIds = {};

  final List<String> _categories = [
    'All',
    'Politics',
    'Tech',
    'Sports',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _loadArticles();
    _loadBookmarkedArticleIds();
  }

  void updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadArticles();
  }

  Future<void> _loadBookmarkedArticleIds() async {
    try {
      final bookmarkedIds = await _bookmarkService.getBookmarkedArticleIds();
      setState(() {
        _bookmarkedArticleIds = bookmarkedIds;
      });
    } catch (error) {
      // Handle error silently
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Article> articles;
      if (_selectedCategory == 'All') {
        articles = await NewsService.getArticles();
      } else {
        articles = await NewsService.getArticlesByCategory(_selectedCategory);
      }

      setState(() {
        _articles = articles;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load articles: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    if (widget.onCategoryChanged != null) {
      widget.onCategoryChanged!(category);
    }
    _loadArticles();
  }

  Future<void> _toggleBookmark(Article article) async {
    try {
      if (_bookmarkedArticleIds.contains(article.id)) {
        await _bookmarkService.removeBookmark(article.id);
        setState(() {
          _bookmarkedArticleIds.remove(article.id);
        });
        if (mounted) {
          AppUtils.showInfoMessage(context, 'Removed from bookmarks');
        }
      } else {
        await _bookmarkService.addBookmark(article.id);
        setState(() {
          _bookmarkedArticleIds.add(article.id);
        });
        if (mounted) {
          AppUtils.showSuccessMessage(context, 'Article saved!');
        }
      }
    } catch (error) {
      if (mounted) {
        AppUtils.showErrorMessage(context, 'Error updating bookmark');
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
          'NewsWatch',
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.grey),
            onSelected: (String result) {
              if (result == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories Bar
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => _onCategorySelected(category),
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF2196F3),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Articles List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading articles...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _articles.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadArticles();
                      await _loadBookmarkedArticleIds();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        final article = _articles[index];
                        return _buildArticleCard(article);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final isBookmarked = _bookmarkedArticleIds.contains(article.id);

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
            _loadBookmarkedArticleIds();
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
                  ],
                ),
              ),

              // Bookmark Icon
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? const Color(0xFF2196F3) : Colors.grey,
                ),
                onPressed: () => _toggleBookmark(article),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No articles available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your internet connection or try again later',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _loadArticles();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
}
