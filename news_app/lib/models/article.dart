import 'package:flutter/material.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedAt,
  });

  // Create an Article from JSON (for Supabase data)
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      source: json['source'] ?? '',
      category: json['category'] ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Create an Article from NewsAPI JSON
  factory Article.fromNewsApi(Map<String, dynamic> json, String category) {
    return Article(
      id: json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available',
      imageUrl:
          json['urlToImage'] ?? 'https://via.placeholder.com/300x200?text=News',
      source: json['source']?['name'] ?? 'Unknown Source',
      category: category,
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Convert Article to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'source': source,
      'category': category,
      'published_at': publishedAt.toIso8601String(),
    };
  }

  // Get formatted time difference (e.g., "2h ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 7) {
      // Show date for articles older than a week
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[publishedAt.month - 1]} ${publishedAt.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get category color
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'politics':
        return const Color(0xFFE53E3E); // Red
      case 'tech':
      case 'technology':
        return const Color(0xFF3182CE); // Blue
      case 'sports':
        return const Color(0xFF38A169); // Green
      case 'health':
        return const Color(0xFF805AD5); // Purple
      case 'entertainment':
        return const Color(0xFFDD6B20); // Orange
      case 'business':
        return const Color(0xFF319795); // Teal
      case 'science':
        return const Color(0xFF553C9A); // Indigo
      default:
        return const Color(0xFF718096); // Gray
    }
  }

  // Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'politics':
        return '🏛️';
      case 'tech':
      case 'technology':
        return '💻';
      case 'sports':
        return '⚽';
      case 'health':
        return '🏥';
      case 'entertainment':
        return '🎬';
      case 'business':
        return '💼';
      case 'science':
        return '🔬';
      default:
        return '📰';
    }
  }
}
