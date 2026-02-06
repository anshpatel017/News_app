import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        key: _homeScreenKey,
        selectedCategory: _selectedCategory,
        onCategoryChanged: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
      CategoriesScreen(onCategorySelected: _onCategorySelectedFromCategories),
      const BookmarksScreen(),
      const ProfileScreen(),
    ];
  }

  void _onCategorySelectedFromCategories(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedIndex = 0; // Switch to home screen
    });

    // Update home screen with new category
    _homeScreenKey.currentState?.updateCategory(category);
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
