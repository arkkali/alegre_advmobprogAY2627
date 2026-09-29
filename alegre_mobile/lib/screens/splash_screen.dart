import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
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
    await Future.wait([
      precacheImage(
        const AssetImage('assets/images/nubdexchange_logo.png'),
        context,
      ),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    final user = await _userService.getUserData();
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
    final lightTheme = context.read<ThemeProvider>().lightTheme;
    return Theme(
      data: lightTheme,
      child: Builder(
        builder: (context) {
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
        },
      ),
    );
  }
}
