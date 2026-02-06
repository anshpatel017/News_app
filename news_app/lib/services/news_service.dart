import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/news_api_config.dart';
import '../models/article.dart';

class NewsService {
  // Get top headlines (latest 20 articles)
  static Future<List<Article>> getArticles() async {
    try {
      final url =
          '${NewsApiConfig.baseUrl}${NewsApiConfig.topHeadlines}'
          '?country=${NewsApiConfig.defaultCountry}'
          '&pageSize=20'
          '&apiKey=${NewsApiConfig.apiKey}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'] ?? [];

        return articles
            .where(
              (article) =>
                  article['title'] != null && article['title'] != '[Removed]',
            )
            .map((json) => Article.fromNewsApi(json, 'general'))
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch articles: $error');
    }
  }

  // Get articles by category
  static Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      if (category.toLowerCase() == 'all') {
        return await getArticles();
      }

      String apiCategory = category.toLowerCase();

      // Map our categories to NewsAPI categories
      switch (category.toLowerCase()) {
        case 'tech':
        case 'technology':
          apiCategory = 'technology';
          break;
        case 'sports':
          apiCategory = 'sports';
          break;
        case 'health':
          apiCategory = 'health';
          break;
        case 'business':
          apiCategory = 'business';
          break;
        case 'entertainment':
          apiCategory = 'entertainment';
          break;
        case 'science':
          apiCategory = 'science';
          break;
        default:
          apiCategory = 'general';
      }

      final url =
          '${NewsApiConfig.baseUrl}${NewsApiConfig.topHeadlines}'
          '?country=${NewsApiConfig.defaultCountry}'
          '&category=$apiCategory'
          '&pageSize=20'
          '&apiKey=${NewsApiConfig.apiKey}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'] ?? [];

        return articles
            .where(
              (article) =>
                  article['title'] != null && article['title'] != '[Removed]',
            )
            .map((json) => Article.fromNewsApi(json, category))
            .toList();
      } else {
        throw Exception(
          'Failed to load news for category $category: ${response.statusCode}',
        );
      }
    } catch (error) {
      throw Exception('Failed to fetch articles by category: $error');
    }
  }

  // Search articles by title and description
  static Future<List<Article>> searchArticles(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return [];
      }

      final url =
          '${NewsApiConfig.baseUrl}${NewsApiConfig.everything}'
          '?q=${Uri.encodeComponent(searchTerm)}'
          '&sortBy=publishedAt'
          '&pageSize=20'
          '&language=en'
          '&apiKey=${NewsApiConfig.apiKey}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'] ?? [];

        return articles
            .where(
              (article) =>
                  article['title'] != null && article['title'] != '[Removed]',
            )
            .map((json) => Article.fromNewsApi(json, 'search'))
            .toList();
      } else {
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to search articles: $error');
    }
  }
}
