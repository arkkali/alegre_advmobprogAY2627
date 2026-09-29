import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';

class ChatDetailScreen extends StatefulWidget {
  final User currentUser;
  final User otherUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  bool _isSending = false;

  String get _currentUserId => widget.currentUser.firebaseUid;
  String get _otherUserId => widget.otherUser.firebaseUid;

  @override
  void initState() {
    super.initState();
    if (_currentUserId.isNotEmpty && _otherUserId.isNotEmpty) {
      _chatService.markMessagesSeen(
        currentUserId: _currentUserId,
        otherUserId: _otherUserId,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    if (_currentUserId.isEmpty || _otherUserId.isEmpty) return;
    setState(() => _isSending = true);
    _messageController.clear();
    try {
      await _chatService.sendMessage(
        currentUserId: _currentUserId,
        otherUserId: _otherUserId,
        text: text,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${widget.otherUser.firstName} ${widget.otherUser.lastName}'.trim();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          displayName.isEmpty ? widget.otherUser.username : displayName,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentUserId.isEmpty || _otherUserId.isEmpty
                ? const Center(child: Text('Chat requires Firebase accounts.'))
                : StreamBuilder<List<Message>>(
                    stream: _chatService.watchMessages(
                      _currentUserId,
                      _otherUserId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load messages: ${snapshot.error}',
                          ),
                        );
                      }
                      final messages = snapshot.data ?? const <Message>[];
                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('Start the conversation'),
                        );
                      }
                      return ListView.builder(
                        reverse: false,
                        padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
                        itemCount: messages.length,
                        itemBuilder: (context, index) =>
                            _messageBubble(messages[index]),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _isSending ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Message message) {
    final isMine = message.senderId == _currentUserId;
    final colors = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(message.sentAt).format(context);
    final status = message.status == 'sending'
        ? 'sending...'
        : message.status == 'seen'
        ? '✓✓ seen'
        : '✓ delivered';
    final bubble = Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 290.w),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMine ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
            bottomRight: Radius.circular(isMine ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            CustomText(
              text: message.text,
              fontSize: 14.sp,
              color: isMine ? colors.onPrimary : colors.onSurface,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMine
                        ? colors.onPrimary.withValues(alpha: 0.75)
                        : colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                if (isMine) ...[
                  SizedBox(width: 6.w),
                  Text(
                    status,
                    style: TextStyle(
                      color: colors.onPrimary.withValues(alpha: 0.8),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
    // Activity 6 Enhancement 3: Animate bubbles and show sending, delivered, and seen states.
    return TweenAnimationBuilder<Offset>(
      key: ValueKey(message.id),
      tween: Tween(begin: const Offset(0, 0.08), end: Offset.zero),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * 40.w, offset.dy * 40.h),
          child: Opacity(opacity: 1 - offset.dy.clamp(0, 1), child: child),
        );
      },
      child: bubble,
    );
  }
}
