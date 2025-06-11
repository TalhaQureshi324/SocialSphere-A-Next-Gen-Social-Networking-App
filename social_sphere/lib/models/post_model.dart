import 'package:flutter/foundation.dart';
class Post {
  final bool isAnonymous;
  final String id;
  final String title;
  final String? link; // For single link/video
  final List<String>? mediaUrls; // For multiple images
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String username;
  final String uid;
  final String type;
  final DateTime createdAt;
  final List<String> awards;

  Post({
    required this.isAnonymous,
    required this.id,
    required this.title,
    this.link,
    this.mediaUrls,
    this.description,
    required this.communityName,
    required this.communityProfilePic,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.username,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.awards,
  });

  // Update copyWith, toMap, fromMap, etc. to include mediaUrls
  Map<String, dynamic> toMap() {
    return {
      'isAnonymous': isAnonymous,
      'id': id,
      'title': title,
      'link': link,
      'mediaUrls': mediaUrls,
      'description': description,
      'communityName': communityName,
      'communityProfilePic': communityProfilePic,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'username': username,
      'uid': uid,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'awards': awards,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      isAnonymous: map['isAnonymous'] ?? false,
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      mediaUrls: map['mediaUrls'] != null ? List<String>.from(map['mediaUrls']) : null,
      description: map['description'],
      communityName: map['communityName'] ?? '',
      communityProfilePic: map['communityProfilePic'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      awards: List<String>.from(map['awards']),
    );
  }
}