import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'signin_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    await UserService().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayName = user.username == 'arkkali'
      ? 'Arkkali'
      : '${user.firstName} ${user.lastName}'.trim();
    final email = user.username == 'arkkali'
      ? 'arkkali@email.com'
      : user.email;
    final gender = user.username == 'arkkali' ? 'female' : user.gender;
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48.r,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: user.image.isEmpty ? null : NetworkImage(user.image),
                  child: user.image.isEmpty
                      ? Icon(Icons.person, size: 52.sp, color: colors.primary)
                      : null,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text: displayName.isEmpty ? user.username : displayName,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: '@${user.username}',
                  fontSize: 13.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Card(
          child: Column(
            children: [
              _infoRow(context, Icons.email_outlined, 'Email', email),
              _infoRow(context, Icons.people_outline, 'Gender', gender),
              _infoRow(context, Icons.badge_outlined, 'User ID', '#${user.id}'),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        SizedBox(
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: CustomText(text: label, fontSize: 13.sp, fontWeight: FontWeight.w600),
      trailing: SizedBox(
        width: 190.w,
        child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}