import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
  // Activity 5: Refresh the displayed Firebase profile after an account change.
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final ValueChanged<User>? onUserChanged;

  const ProfileScreen({super.key, required this.user, this.onUserChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  late Future<User> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<User> _loadProfile() async =>
      await _userService.getUserData() ?? widget.user;

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return;
      final updatedUser = await _loadProfile();
      if (!mounted) return;
      setState(() {
        _profileFuture = Future.value(updatedUser);
      });
      widget.onUserChanged?.call(updatedUser);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account updated')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _updateUsername(User user) async {
    final controller = TextEditingController(text: user.username);
    final username = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (username == null || username.isEmpty) return;
    await _runAction(() => _userService.updateUsername(username));
  }

  Future<String?> _askPassword({required String title}) async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Current password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return password;
  }

  Future<void> _changePassword() async {
    final currentPassword = await _askPassword(title: 'Change password');
    if (!mounted || currentPassword == null || currentPassword.isEmpty) return;
    final newPasswordController = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New password'),
        content: TextField(
          controller: newPasswordController,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'At least 6 characters'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, newPasswordController.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    newPasswordController.dispose();
    if (newPassword == null || newPassword.length < 6) {
      if (newPassword != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 6 characters'),
          ),
        );
      }
      return;
    }
    await _runAction(
      () => _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your Firebase account and profile data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final password = await _askPassword(title: 'Confirm account deletion');
    if (!mounted || password == null || password.isEmpty) return;
    try {
      await _userService.deleteAccount(currentPassword: password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load profile: ${snapshot.error}'),
          );
        }
        final user = snapshot.data ?? widget.user;
        final isFirebaseUser = user.loginType == LoginType.firebase;
        final colors = Theme.of(context).colorScheme;
        final displayName = '${user.firstName} ${user.lastName}'.trim();
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
                      backgroundImage: user.image.isEmpty
                          ? null
                          : NetworkImage(user.image),
                      child: user.image.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 52.sp,
                              color: colors.primary,
                            )
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: displayName.isEmpty ? user.username : displayName,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    CustomText(text: '@${user.username}', fontSize: 13.sp),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Card(
              child: Column(
                children: [
                  _infoRow(context, Icons.email_outlined, 'Email', user.email),
                  if (user.age != null)
                    _infoRow(
                      context,
                      Icons.cake_outlined,
                      'Age',
                      '${user.age}',
                    ),
                  if (user.contactNo.isNotEmpty)
                    _infoRow(
                      context,
                      Icons.phone_outlined,
                      'Contact number',
                      user.contactNo,
                    ),
                  if (user.gender.isNotEmpty)
                    _infoRow(
                      context,
                      Icons.people_outline,
                      'Gender',
                      user.gender,
                    ),
                  _infoRow(
                    context,
                    Icons.badge_outlined,
                    isFirebaseUser ? 'Account type' : 'User ID',
                    isFirebaseUser ? 'Firebase' : '#${user.id}',
                  ),
                  if (isFirebaseUser) ...[
                    const Divider(height: 1),
                    _accountAction(
                      context,
                      icon: Icons.edit_outlined,
                      label: 'Update username',
                      onTap: () => _updateUsername(user),
                    ),
                    _accountAction(
                      context,
                      icon: Icons.lock_reset_outlined,
                      label: 'Change password',
                      onTap: _changePassword,
                    ),
                    _accountAction(
                      context,
                      icon: Icons.delete_outline,
                      label: 'Delete account',
                      color: colors.error,
                      onTap: _deleteAccount,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: CustomText(
        text: label,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      trailing: SizedBox(
        width: 190.w,
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _accountAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final actionColor = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: actionColor),
      title: CustomText(
        text: label,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: actionColor,
      ),
      onTap: onTap,
    );
  }
}
