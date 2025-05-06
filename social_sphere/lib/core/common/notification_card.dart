// import 'package:flutter/material.dart';
// import 'package:social_sphere/core/constants/constants.dart';
// import 'package:social_sphere/models/notification_model.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationCard extends StatelessWidget {
//   final NotificationModel notification;
//   final bool isUnread;
//   const NotificationCard({
//     super.key,
//     required this.notification,
//     required this.isUnread,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildAvatar(),
//             const SizedBox(width: 12),
//             Expanded(child: _buildNotificationContent()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAvatar() {
//     return CircleAvatar(
//       radius: 24,
//       backgroundImage: NetworkImage(
//         Constants.avatarDefault,
//         //  notification.type == NotificationType.chat
//         //    ? (notification.senderAvatar ?? '')
//         //     : notification.communityAvatar,
//       ),
//     );
//   }

//   Widget _buildNotificationContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               notification.type == NotificationType.chat
//                   ? notification.senderName!
//                   : notification.communityName!,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               timeago.format(notification.createdAt),
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),
//             if (isUnread)
//               const Padding(
//                 padding: EdgeInsets.only(left: 4),
//                 child: Icon(
//                   Icons.circle,
//                   color: Colors.blue,
//                   size: 10,
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           notification.type == NotificationType.chat
//               ? notification.messageText!
//               : notification.postTitle!,
//           style: const TextStyle(fontSize: 14),
//         ),
//         if (notification.type == NotificationType.post)
//           Padding(
//             padding: const EdgeInsets.only(top: 2),
//             child: Text(
//               'by ${notification.authorName}',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sphere/core/constants/constants.dart';
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
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildNotificationContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(
        Constants.avatarDefault,
        // notification.type == NotificationType.chat
        //     ? (notification.senderAvatar ?? '')
        //     : notification.communityAvatar,
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                notification.type == NotificationType.chat
                    ? 'New message from ${notification.senderName!}'
                    : 'New post in ${notification.communityName!}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              timeago.format(notification.createdAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (isUnread)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.circle, color: Colors.blue, size: 10),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (notification.type == NotificationType.chat)
          Text(notification.messageText!, style: const TextStyle(fontSize: 14)),
        if (notification.type == NotificationType.post)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: notification.isAnonymous == true
                      ? 'by Anonymous user\n'
                      : 'by ${notification.authorName}\n', 
                  //'by ${notification.authorName}\n',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                TextSpan(
                  text: notification.postTitle!,
                  style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
