# Database Schema for NewsWatch App

This document describes the database schema needed for the NewsWatch Flutter app to work with Supabase.

## Required Supabase Tables

### 1. Articles Table
```sql
CREATE TABLE articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  source TEXT NOT NULL,
  category TEXT NOT NULL,
  published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. User Bookmarks Table (NEW - Required for bookmark functionality)
```sql
CREATE TABLE user_bookmarks (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, article_id)
);
```

### 3. Indexes for Better Performance
```sql
-- Index for faster bookmark queries
CREATE INDEX idx_user_bookmarks_user_id ON user_bookmarks(user_id);
CREATE INDEX idx_user_bookmarks_article_id ON user_bookmarks(article_id);

-- Index for faster article queries
CREATE INDEX idx_articles_category ON articles(category);
CREATE INDEX idx_articles_published_at ON articles(published_at DESC);
```

## Row Level Security (RLS) Policies

### Articles Table Policies
```sql
-- Enable RLS
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

-- Allow all users to read articles
CREATE POLICY "Articles are viewable by everyone" ON articles
  FOR SELECT USING (true);

-- Only allow authenticated users (you can modify this later)
CREATE POLICY "Articles are insertable by authenticated users" ON articles
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

### User Bookmarks Table Policies
```sql
-- Enable RLS
ALTER TABLE user_bookmarks ENABLE ROW LEVEL SECURITY;

-- Users can only see their own bookmarks
CREATE POLICY "Users can view own bookmarks" ON user_bookmarks
  FOR SELECT USING (auth.uid() = user_id);

-- Users can only insert their own bookmarks
CREATE POLICY "Users can insert own bookmarks" ON user_bookmarks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own bookmarks
CREATE POLICY "Users can delete own bookmarks" ON user_bookmarks
  FOR DELETE USING (auth.uid() = user_id);
```

## Sample Data for Testing

### Articles Sample Data
```sql
INSERT INTO articles (title, description, image_url, source, category) VALUES
('Flutter 3.0 Released with Amazing Features', 'The latest version of Flutter brings incredible new features for mobile development', 'https://picsum.photos/400/300?random=1', 'Tech News Daily', 'tech'),
('Local Sports Team Wins Championship', 'After a thrilling final match, the home team secured the championship title', 'https://picsum.photos/400/300?random=2', 'Sports Weekly', 'sports'),
('New Health Guidelines Released by WHO', 'World Health Organization releases updated guidelines for healthy living', 'https://picsum.photos/400/300?random=3', 'Health Today', 'health'),
('Political Updates from the Capital', 'Latest developments in government policy and political news', 'https://picsum.photos/400/300?random=4', 'Political Times', 'politics'),
('Breaking: Major Tech Company Announces Innovation', 'Revolutionary technology announced that will change the industry', 'https://picsum.photos/400/300?random=5', 'Innovation Hub', 'tech'),
('Science Discovery: New Research Published', 'Scientists make groundbreaking discovery in renewable energy', 'https://picsum.photos/400/300?random=6', 'Science Journal', 'tech'),
('Business Market Shows Strong Growth', 'Stock market reaches new heights amid positive economic indicators', 'https://picsum.photos/400/300?random=7', 'Business Daily', 'business'),
('Entertainment Industry News Update', 'Latest happenings in movies, music, and entertainment', 'https://picsum.photos/400/300?random=8', 'Entertainment Weekly', 'entertainment');
```

## Setup Instructions

1. **Run the table creation scripts** in your Supabase SQL editor
2. **Set up the RLS policies** for security
3. **Insert sample data** for testing (optional)
4. **Update your Flutter app** with your Supabase URL and anon key

## Notes

- The `user_bookmarks` table uses UUID references to the auth.users table
- RLS policies ensure users can only access their own bookmarks
- The unique constraint prevents duplicate bookmarks
- All timestamps use UTC timezone
- Cascade deletes ensure data integrity

## Troubleshooting

If you encounter issues:

1. **Check RLS policies**: Make sure they're properly configured
2. **Verify table permissions**: Ensure your app's role has proper access
3. **Test with sample data**: Use the provided sample data to verify functionality
4. **Check foreign key constraints**: Ensure referenced tables exist