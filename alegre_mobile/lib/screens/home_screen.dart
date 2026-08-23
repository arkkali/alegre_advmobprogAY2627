import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _selectedIndex == 1
            ? Theme.of(context).colorScheme.surface
            : null,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
            backgroundColor: _selectedIndex == 1
              ? Theme.of(context).colorScheme.primary
              : null,
            foregroundColor: _selectedIndex == 1
              ? Theme.of(context).colorScheme.onPrimary
              : null,
          title: (_selectedIndex == 0)
              ? Image.asset('assets/images/nubdexchange_logo.png', scale: 11.sp)
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                          ? 'Profile'
                          : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            ProductScreen(),
            CartScreen(),
            Center(child: Text('Profile')),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        // Enhancement 2: Chat is a floating action and is hidden on the Cart screen.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                tooltip: 'Open chat',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat is coming soon')),
                  );
                },
                child: const Icon(Icons.chat),
              ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: _selectedIndex == 1
              ? Theme.of(context).bottomNavigationBarTheme.backgroundColor
              : null,
            selectedItemColor: _selectedIndex == 1
              ? Theme.of(context).colorScheme.primary
              : null,
            unselectedItemColor: _selectedIndex == 1
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : null,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}