import 'package:flutter/material.dart';
import 'package:social_sphere/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isUnread;
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Avatar
            CircleAvatar(
              backgroundImage: NetworkImage(notification.communityAvatar),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community Name & Time
                  Row(
                    children: [
                      Text(
                        notification.communityName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (isUnread)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.circle,
                            color: Colors.blue,
                            size: 10,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Post Title
                  Text(
                    notification.postTitle,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  // Author
                  Text(
                    'by ${notification.authorName}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}