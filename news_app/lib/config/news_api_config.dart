class NewsApiConfig {
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey =
      'PASTE_YOUR_NEWSAPI_KEY_HERE'; // Get from https://newsapi.org/

  // Endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // Available categories
  static const List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Countries
  static const String defaultCountry = 'us';
}
