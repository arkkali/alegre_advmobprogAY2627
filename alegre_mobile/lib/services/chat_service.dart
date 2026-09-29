import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';
import '../models/user.dart';

class ChatService {
  static const _profilesCollection = 'userProfiles';
  static const _chatsCollection = 'chats';

  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<User>> getRegisteredUsers(String currentUserId) async {
    final snapshot = await _firestore.collection(_profilesCollection).get();
    return snapshot.docs
        .where((document) => document.id != currentUserId)
        .map((document) => _userFromProfile(document.id, document.data()))
        .toList();
  }

  Stream<List<Message>> watchMessages(
    String currentUserId,
    String otherUserId,
  ) {
    return _messagesReference(currentUserId, otherUserId)
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Message.fromFirestore).toList());
  }

  Future<void> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String text,
  }) async {
    if (currentUserId.isEmpty ||
        otherUserId.isEmpty ||
        currentUserId == otherUserId) {
      return;
    }
    final message = await _messagesReference(currentUserId, otherUserId).add({
      'senderId': currentUserId,
      'receiverId': otherUserId,
      'text': text.trim(),
      'sentAt': FieldValue.serverTimestamp(),
      'status': 'sending',
    });
    await message.update({'status': 'delivered'});
  }

  Future<void> markMessagesSeen({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final snapshot = await _messagesReference(currentUserId, otherUserId).get();
    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      final data = document.data();
      if (data['receiverId'] == currentUserId && data['status'] != 'seen') {
        batch.update(document.reference, {'status': 'seen'});
      }
    }
    await batch.commit();
  }

  DocumentReference<Map<String, dynamic>> _chatReference(
    String currentUserId,
    String otherUserId,
  ) {
    final ids = [currentUserId, otherUserId]..sort();
    return _firestore.collection(_chatsCollection).doc('${ids[0]}_${ids[1]}');
  }

  CollectionReference<Map<String, dynamic>> _messagesReference(
    String currentUserId,
    String otherUserId,
  ) {
    return _chatReference(currentUserId, otherUserId).collection('messages');
  }

  User _userFromProfile(String uid, Map<String, dynamic> data) {
    return User(
      id: 0,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      age: data['age'] as int?,
      contactNo: data['contactNo'] as String? ?? '',
      gender: '',
      image: data['image'] as String? ?? '',
      accessToken: '',
      refreshToken: '',
      loginType: LoginType.firebase,
      firebaseUid: uid,
    );
  }
}
