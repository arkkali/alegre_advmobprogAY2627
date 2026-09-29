import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'arkkali');
  final _passwordController = TextEditingController(text: 'arkkali123');
  final _userService = UserService();
  LoginType _loginType = LoginType.dummyJson;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Activity 5: Use Firebase email auth or retain the existing DummyJSON flow.
  Future<void> _login() async {
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = _loginType == LoginType.firebase
          ? await _userService.signIn(
              _usernameController.text.trim(),
              _passwordController.text,
            )
          : await _userService.loginUser(
              _usernameController.text.trim(),
              _passwordController.text,
            );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 26.w),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _hasSubmitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/nubdexchange_logo.png',
                          width: 110.w,
                        ),
                        SizedBox(height: 12.h),
                        CustomText(
                          text: 'Welcome back',
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 6.h),
                        CustomText(
                          text: 'Sign in to continue shopping',
                          fontSize: 13.sp,
                        ),
                        SizedBox(height: 30.h),
                        SegmentedButton<LoginType>(
                          segments: const [
                            ButtonSegment(
                              value: LoginType.dummyJson,
                              label: Text('DummyJSON'),
                            ),
                            ButtonSegment(
                              value: LoginType.firebase,
                              label: Text('Firebase'),
                            ),
                          ],
                          selected: {_loginType},
                          onSelectionChanged: _isLoading
                              ? null
                              : (selection) {
                                  setState(() {
                                    _loginType = selection.first;
                                    _usernameController.clear();
                                    _passwordController.clear();
                                    _hasSubmitted = false;
                                  });
                                },
                        ),
                        SizedBox(height: 16.h),
                        _field(
                          controller: _usernameController,
                          label: _loginType == LoginType.firebase
                              ? 'Email'
                              : 'Username',
                          icon: Icons.person_outline,
                          keyboardType: _loginType == LoginType.firebase
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                        ),
                        SizedBox(height: 14.h),
                        _field(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible
                                ? 'Hide password'
                                : 'Preview password',
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                        ),
                        if (_loginType == LoginType.firebase) ...[
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pushNamed(context, '/signup'),
                            child: const Text('Create an Account'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText && !_isPasswordVisible,
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
