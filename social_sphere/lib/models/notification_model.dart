class NotificationModel {
  final String id;
  final String userId; // ADD THIS

  final String communityId;
  final String communityName;
  final String communityAvatar;
  final String postId;
  final String postTitle;
  final String authorName;
  final DateTime createdAt;
  final bool isRead;
  NotificationModel({
    required this.id,
    required this.userId, // ADD THIS
    required this.communityId,
    required this.communityName,
    required this.communityAvatar,
    required this.postId,
    required this.postTitle,
    required this.authorName,
    required this.createdAt,
    required this.isRead,
  });

  NotificationModel copyWith({
    String? id,
    String? userId, // ADD THIS
    String? communityId,
    String? communityName,
    String? communityAvatar,
    String? postId,
    String? postTitle,
    String? authorName,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId, // ADD THIS
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      communityAvatar: communityAvatar ?? this.communityAvatar,
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId, // ADD THIS
      'communityId': communityId,
      'communityName': communityName,
      'communityAvatar': communityAvatar,
      'postId': postId,
      'postTitle': postTitle,
      'authorName': authorName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String, // ADD THIS
      communityId: map['communityId'] as String,
      communityName: map['communityName'] as String,
      communityAvatar: map['communityAvatar'] as String,
      postId: map['postId'] as String,
      postTitle: map['postTitle'] as String,
      authorName: map['authorName'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isRead: map['isRead'] as bool,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id,userId: $userId , communityId: $communityId, communityName: $communityName, communityAvatar: $communityAvatar, postId: $postId, postTitle: $postTitle, authorName: $authorName, createdAt: $createdAt, isRead: $isRead)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId && // ADD THIS
        other.communityId == communityId &&
        other.communityName == communityName &&
        other.communityAvatar == communityAvatar &&
        other.postId == postId &&
        other.postTitle == postTitle &&
        other.authorName == authorName &&
        other.createdAt == createdAt &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^ // ADD THIS
        communityId.hashCode ^
        communityName.hashCode ^
        communityAvatar.hashCode ^
        postId.hashCode ^
        postTitle.hashCode ^
        authorName.hashCode ^
        createdAt.hashCode ^
        isRead.hashCode;
  }
}
