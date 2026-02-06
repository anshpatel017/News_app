import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;

  const CategoriesScreen({super.key, this.onCategorySelected});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Politics',
      'emoji': '🏛️',
      'color': Colors.red[400]!,
      'description': 'Government & Politics',
    },
    {
      'name': 'Technology',
      'emoji': '💻',
      'color': Colors.blue[400]!,
      'description': 'Tech & Innovation',
    },
    {
      'name': 'Sports',
      'emoji': '⚽',
      'color': Colors.green[400]!,
      'description': 'Sports & Fitness',
    },
    {
      'name': 'Health',
      'emoji': '🏥',
      'color': Colors.purple[400]!,
      'description': 'Health & Wellness',
    },
    {
      'name': 'Entertainment',
      'emoji': '🎬',
      'color': Colors.orange[400]!,
      'description': 'Movies & Shows',
    },
    {
      'name': 'Business',
      'emoji': '💼',
      'color': Colors.teal[400]!,
      'description': 'Business & Finance',
    },
    {
      'name': 'Science',
      'emoji': '🔬',
      'color': Colors.indigo[400]!,
      'description': 'Science & Research',
    },
    {
      'name': 'Travel',
      'emoji': '✈️',
      'color': Colors.cyan[400]!,
      'description': 'Travel & Tourism',
    },
  ];

  void _onCategoryTap(String categoryName) {
    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(categoryName);
    } else {
      // Navigate back to home and filter
      Navigator.of(context).pop(categoryName);
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
          'Categories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            const Text(
              'Explore Topics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a category to browse news',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Categories Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(
                    name: category['name'],
                    emoji: category['emoji'],
                    color: category['color'],
                    description: category['description'],
                  );
                },
              ),
            ),

            // All News Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton.icon(
                onPressed: () => _onCategoryTap('All'),
                icon: const Icon(Icons.view_headline),
                label: const Text(
                  'All News',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required String emoji,
    required Color color,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _onCategoryTap(name),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),

                // Category Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
