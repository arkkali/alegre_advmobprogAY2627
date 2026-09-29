import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../models/user.dart';
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final User? user;

  const HomeScreen({super.key, this.username = '', this.user});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser =
        widget.user ??
        const User(
          id: 0,
          username: 'arkkali',
          email: 'arkkali@email.com',
          firstName: 'Arkkali',
          lastName: '',
          gender: 'Female',
          image: '',
          accessToken: '',
          refreshToken: '',
        );
  }

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
                      ? (_currentUser.username.isNotEmpty
                            ? _currentUser.username
                            : 'Profile')
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
          children: <Widget>[
            ProductScreen(),
            CartScreen(userId: _currentUser.id > 0 ? _currentUser.id : 1),
            ProfileScreen(
              user: _currentUser,
              onUserChanged: (user) {
                setState(() => _currentUser = user);
              },
            ),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                tooltip: 'Open chat',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(currentUser: _currentUser),
                    ),
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
