import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final User currentUser;

  const ChatScreen({super.key, required this.currentUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();
  final _chatService = ChatService();
  late Future<List<User>> _usersFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<User>> _loadUsers() {
    return _chatService.getRegisteredUsers(widget.currentUser.firebaseUid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load users: ${snapshot.error}'),
            );
          }
          final users = snapshot.data ?? const <User>[];
          // Activity 6 Enhancement 1: Show registered users except the current user.
          final filteredUsers = users.where((user) {
            // Activity 6 Enhancement 2: Filter chat contacts by name, username, or email.
            final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
            return fullName.contains(_searchQuery) ||
                user.username.toLowerCase().contains(_searchQuery) ||
                user.email.toLowerCase().contains(_searchQuery);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  },
                  decoration: InputDecoration(
                    labelText: 'Search by name or email',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredUsers.isEmpty
                    ? Center(
                        child: CustomText(
                          text: _searchQuery.isEmpty
                              ? 'No other users yet'
                              : 'No users found',
                          fontSize: 15.sp,
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final displayName =
                              '${user.firstName} ${user.lastName}'.trim();
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            tileColor: Theme.of(context).cardColor,
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: const Icon(Icons.person),
                            ),
                            title: CustomText(
                              text: displayName.isEmpty
                                  ? user.username
                                  : displayName,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            subtitle: Text(user.email),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    currentUser: widget.currentUser,
                                    otherUser: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
