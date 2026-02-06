# NewsWatch - Flutter News App

A simple Flutter news application with user authentication and article browsing functionality using Supabase as the backend.

## Features

- ✅ User Registration and Login
- ✅ Secure Authentication with Supabase
- ✅ News Article Display
- ✅ Category-based Article Filtering
- ✅ Clean and Modern UI
- ✅ Pull-to-refresh functionality
- ✅ Cached Network Images

## Project Structure

```
lib/
├── main.dart                 # App entry point with Supabase initialization
├── models/
│   └── article.dart         # Article data model
├── screens/
│   ├── login_screen.dart    # User login interface
│   ├── register_screen.dart # User registration interface
│   └── home_screen.dart     # Main news feed with categories
└── services/
    ├── auth_service.dart    # Authentication service
    └── news_service.dart    # News data service
```

## Setup Instructions

### 1. Prerequisites
- Flutter SDK installed
- Supabase account and project

### 2. Supabase Configuration
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from project settings
3. Update the credentials in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Replace with your Supabase URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
);
```

### 3. Database Schema
Create the following table in your Supabase database:

```sql
CREATE TABLE articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  source TEXT,
  category TEXT,
  published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4. Sample Data (Optional)
Insert some sample articles for testing:

```sql
INSERT INTO articles (title, description, image_url, source, category) VALUES
('Flutter 3.0 Released', 'Latest version brings amazing new features', 'https://example.com/flutter.jpg', 'Tech News', 'tech'),
('Sports Update', 'Local team wins championship', 'https://example.com/sports.jpg', 'Sports Daily', 'sports'),
('Health Tips', 'Stay healthy with these simple tips', 'https://example.com/health.jpg', 'Health Magazine', 'health'),
('Political News', 'Latest political developments', 'https://example.com/politics.jpg', 'News Today', 'politics');
```

### 5. Run the App
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Authentication Flow

1. **App Launch**: Checks if user is already authenticated
2. **Login Screen**: Email/password authentication with validation
3. **Registration Screen**: New user signup with full name
4. **Home Screen**: Authenticated users see news feed

## News Features

- **Categories**: All, Politics, Tech, Sports, Health
- **Article Cards**: Image, title, source, and timestamp
- **Pull-to-Refresh**: Reload articles manually
- **Navigation**: Bottom navigation (Home active, others show "Coming soon")

## Dependencies

- `supabase_flutter: ^2.5.0` - Supabase integration for authentication and database
- `cached_network_image: ^3.3.0` - Network image caching for better performance

## UI Components

### Login Screen
- App branding with "NewsWatch" title
- Email and password input fields
- Show/hide password toggle
- Form validation
- Navigation to registration

### Register Screen
- Full name, email, and password fields
- Password length validation (minimum 6 characters)
- Account creation with user metadata
- Navigation to login

### Home Screen
- App bar with logout option
- Horizontal category filter chips
- Article list with cached images
- Bottom navigation bar
- Pull-to-refresh functionality

## Notes for Production

1. **Replace placeholder Supabase credentials** with your actual project credentials
2. **Add proper error handling** for network connectivity issues
3. **Implement article detail screen** (currently shows "Coming soon")
4. **Add bookmark functionality** (currently shows "Coming soon")
5. **Implement other navigation tabs** (currently show "Coming soon")
6. **Add image fallbacks** for articles without images
7. **Consider pagination** for large article lists
8. **Add search functionality**
9. **Implement push notifications** for breaking news
10. **Add user profile management**

## Testing

1. Register a new user account
2. Login with the created account
3. Browse articles by category
4. Test pull-to-refresh functionality
5. Try logout and login again

## Troubleshooting

- **Supabase connection issues**: Verify URL and anon key are correct
- **Authentication errors**: Check Supabase auth settings and email confirmation
- **No articles showing**: Ensure articles table exists and has data
- **Image loading issues**: Check network connectivity and image URLs

This app provides a solid foundation for a news application that can be extended with additional features as needed.
