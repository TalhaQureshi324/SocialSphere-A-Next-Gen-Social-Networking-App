// notification_model.dart
// Add this in notification_model.dart
enum NotificationType { post, chat }

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type; // NEW
  final String? communityId; // Make nullable
  final String? communityName;
  final String? communityAvatar;
  final String? postId;
  final String? postTitle;
  final String? authorName;
  // NEW CHAT FIELDS
  final String? senderId;
  final String? senderName;
  final String? messageText;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.communityId,
    this.communityName,
    this.communityAvatar,
    this.postId,
    this.postTitle,
    this.authorName,
    this.senderId,
    this.senderName,
    this.messageText,
    required this.createdAt,
    required this.isRead,
  });

  // Update copyWith method
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? communityId,
    String? communityName,
    String? communityAvatar,
    String? postId,
    String? postTitle,
    String? authorName,
    String? senderId,
    String? senderName,
    String? messageText,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      communityAvatar: communityAvatar ?? this.communityAvatar,
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      authorName: authorName ?? this.authorName,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      messageText: messageText ?? this.messageText,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  // Update toMap
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'type': type.index, // Store enum index
      'communityId': communityId,
      'communityName': communityName,
      'communityAvatar': communityAvatar,
      'postId': postId,
      'postTitle': postTitle,
      'authorName': authorName,
      'senderId': senderId,
      'senderName': senderName,
      'messageText': messageText,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  // Update fromMap
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: NotificationType.values[(map['type'] as int?) ?? 0], // Handle null

      communityId: map['communityId'] as String?,
      communityName: map['communityName'] as String?,
      communityAvatar: map['communityAvatar'] as String?,
      postId: map['postId'] as String?,
      postTitle: map['postTitle'] as String?,
      authorName: map['authorName'] as String?,
      senderId: map['senderId'] as String?,
      senderName: map['senderName'] as String?,
      messageText: map['messageText'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isRead: map['isRead'] as bool,
    );
  }
}
