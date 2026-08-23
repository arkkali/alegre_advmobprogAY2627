import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';
import 'home_screen.dart';
import 'signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkAuthentication();
    });
  }

  // Enhancement 1: Check the saved token and restore persistent authentication.
  Future<void> _checkAuthentication() async {
    final loggedInFuture = _userService.isLoggedIn();
    await Future.wait([
      loggedInFuture,
      precacheImage(const AssetImage('assets/images/nubdexchange_logo.png'), context),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    final loggedIn = await loggedInFuture;
    final user = loggedIn ? await _userService.getUser() : null;
    if (user != null && user.username != 'arkkali') {
      await _userService.logout();
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user == null || user.username != 'arkkali'
          ? const SignInScreen()
          : HomeScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 130.w,
              height: 130.w,
              child: Image.asset(
                'assets/images/nubdexchange_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported_outlined,
                  size: 64.sp,
                  color: colors.primary,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'NUBD Exchange',
              style: TextStyle(
                color: colors.primary,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 28.w,
              height: 28.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}