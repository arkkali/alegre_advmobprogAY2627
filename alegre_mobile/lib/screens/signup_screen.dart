import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Activity 5: Validate registration fields before creating the Firebase account.
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _userService.createAccount(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        age: int.parse(_ageController.text.trim()),
        contactNo: _contactController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        (_) => false,
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
            appBar: AppBar(title: const Text('Create account')),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    _textField('First Name', _firstNameController),
                    SizedBox(height: 12.h),
                    _textField('Last Name', _lastNameController),
                    SizedBox(height: 12.h),
                    _textField(
                      'Age',
                      _ageController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final age = int.tryParse(value?.trim() ?? '');
                        return age == null || age < 1 || age > 120
                            ? 'Enter an age from 1 to 120'
                            : null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _textField(
                      'Contact Number',
                      _contactController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final digits = (value ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        return digits.length < 7 || digits.length > 15
                            ? 'Enter a valid contact number'
                            : null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _textField('Username', _usernameController),
                    SizedBox(height: 12.h),
                    _textField(
                      'Email Address',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(email)
                            ? null
                            : 'Enter a valid email address';
                      },
                    ),
                    SizedBox(height: 12.h),
                    _textField(
                      'Password',
                      _passwordController,
                      obscureText: !_passwordVisible,
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                      suffixIcon: IconButton(
                        tooltip: _passwordVisible
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/signin',
                              (_) => false,
                            ),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty
              ? '$label is required'
              : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
        ),
        floatingLabelStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
