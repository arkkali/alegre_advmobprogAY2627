import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime sentAt;
  final String status;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.sentAt,
    required this.status,
  });

  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final timestamp = data['sentAt'];
    return Message(
      id: document.id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      status: data['status'] as String? ?? 'delivered',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'sentAt': Timestamp.fromDate(sentAt),
    'status': status,
  };

  Message copyWith({String? status}) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      sentAt: sentAt,
      status: status ?? this.status,
    );
  }
}
