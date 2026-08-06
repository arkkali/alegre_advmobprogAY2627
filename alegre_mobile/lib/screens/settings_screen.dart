import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          SwitchListTile(
            title: CustomText(
              text: 'Dark Mode',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            subtitle: CustomText(
              text: 'Enable dark theme across the app',
              fontSize: 12.sp,
            ),
            value: themeProvider.isDark,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}