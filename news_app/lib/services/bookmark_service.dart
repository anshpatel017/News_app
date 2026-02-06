import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';

class BookmarkService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add bookmark
  Future<void> addBookmark(String articleId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('user_bookmarks').insert({
        'user_id': user.id,
        'article_id': articleId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      throw Exception('Failed to add bookmark: $error');
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String articleId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('user_bookmarks')
          .delete()
          .eq('user_id', user.id)
          .eq('article_id', articleId);
    } catch (error) {
      throw Exception('Failed to remove bookmark: $error');
    }
  }

  // Check if article is bookmarked
  Future<bool> isBookmarked(String articleId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final response = await _supabase
          .from('user_bookmarks')
          .select('id')
          .eq('user_id', user.id)
          .eq('article_id', articleId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  // Get all bookmarked articles for current user
  Future<List<Article>> getMyBookmarks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('user_bookmarks')
          .select('''
            articles (
              id,
              title,
              description,
              image_url,
              source,
              category,
              published_at
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((bookmarkData) => Article.fromJson(bookmarkData['articles']))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch bookmarks: $error');
    }
  }

  // Get bookmark count for user
  Future<int> getBookmarkCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('user_bookmarks')
          .select('id')
          .eq('user_id', user.id);

      return (response as List).length;
    } catch (error) {
      return 0;
    }
  }

  // Get list of bookmarked article IDs (for quick checking)
  Future<Set<String>> getBookmarkedArticleIds() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {};
      }

      final response = await _supabase
          .from('user_bookmarks')
          .select('article_id')
          .eq('user_id', user.id);

      return (response as List)
          .map((data) => data['article_id'] as String)
          .toSet();
    } catch (error) {
      return {};
    }
  }
}
