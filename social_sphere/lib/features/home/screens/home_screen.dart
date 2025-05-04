// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/constants/constants.dart';
// import 'package:social_sphere/features/auth/controller/auth_controller.dart';
// import 'package:social_sphere/features/home/delegates/search_community_delegate.dart';
// import 'package:social_sphere/features/home/drawers/community_list_drawer.dart';
// import 'package:social_sphere/features/home/drawers/profile_drawer.dart';
// import 'package:social_sphere/theme/pallete.dart';
// import 'package:routemaster/routemaster.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _page = 0;

//   void displayDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
//   void displayEndDrawer(BuildContext context) =>
//       Scaffold.of(context).openEndDrawer();
//   void onPageChanged(int page) => setState(() => _page = page);

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider)!;
//     final isGuest = !user.isAuthenticated;
//     final currentTheme = ref.watch(themeNotifierProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: const [
//             SizedBox(width: 0),
//             Text(
//               'Social Sphere',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//           ],
//         ),
//         centerTitle: false,
//         leading: Builder(
//           builder:
//               (context) => IconButton(
//                 icon: Icon(Icons.menu, color: currentTheme.iconTheme.color),
//                 onPressed: () => displayDrawer(context),
//               ),
//         ),
//         actions: [
//           Consumer(
//             builder: (context, ref, child) {
//               return Builder(
//                 builder:
//                     (context) => IconButton(
//                       icon: Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Pallete.blueColor,
//                             width: 2,
//                           ),
//                         ),
//                         child: CircleAvatar(
//                           radius: 14,
//                           backgroundImage: NetworkImage(user.profilePic),
//                         ),
//                       ),
//                       onPressed: () => displayEndDrawer(context),
//                     ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Constants.tabWidgets[_page],
//       drawer: const CommunityListDrawer(),
//       endDrawer: isGuest ? null : const ProfileDrawer(),
//       bottomNavigationBar:
//           isGuest || kIsWeb
//               ? null
//               : Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                   color: currentTheme.scaffoldBackgroundColor,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, -2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildNavItem(
//                       icon: Icons.home_outlined,
//                       activeIcon: Icons.home_filled,
//                       label: "Home",
//                       index: 0,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.search_rounded,
//                       label: "Search",
//                       onTap:
//                           () => showSearch(
//                             context: context,
//                             delegate: SearchCommunityDelegate(ref),
//                           ),
//                     ),
//                     GestureDetector(
//                       onTap: () {}, // Optional: Action for logo tap
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Image.asset(
//                             Constants.logopath2,
//                             height: 40,
//                             width: 40,
//                           ),
//                           const SizedBox(height: 10),
//                           // Text(
//                           //   "Logo",
//                           //   style: TextStyle(
//                           //     fontSize: 12,
//                           //     color: currentTheme.textTheme.bodyMedium?.color,
//                           //   ),
//                           //),
//                         ],
//                       ),
//                     ),
//                     _buildNavItem(
//                       icon: Icons.add_circle_outline,
//                       activeIcon: Icons.add_circle,
//                       label: "Create",
//                       index: 1,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.notifications,
//                       label: "Alerts",
//                       onTap:
//                           () => Routemaster.of(context).push('/notifications'),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     IconData? activeIcon,
//     required String label,
//     int? index,
//     VoidCallback? onTap,
//   }) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final isActive = index != null && _page == index;

//     return GestureDetector(
//       onTap: onTap ?? () => onPageChanged(index!),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isActive ? (activeIcon ?? icon) : icon,
//               color:
//                   isActive
//                       ? Pallete.blueColor
//                       : currentTheme.iconTheme.color?.withOpacity(0.6),
//               size: isActive ? 28 : 24,
//             ),
//             const SizedBox(height: 4),
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 200),
//               style: TextStyle(
//                 color:
//                     isActive
//                         ? Pallete.blueColor
//                         : currentTheme.iconTheme.color?.withOpacity(0.6),
//                 fontSize: 12,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//               ),
//               child: Text(label),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/home/delegates/search_community_delegate.dart';
import 'package:social_sphere/features/home/drawers/community_list_drawer.dart';
import 'package:social_sphere/features/home/drawers/profile_drawer.dart';
import 'package:social_sphere/features/notification/screens/notification_screen.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
  void displayEndDrawer(BuildContext context) =>
      Scaffold.of(context).openEndDrawer();
  void onPageChanged(int page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 0),
            Text(
              'Social Sphere',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () => Routemaster.of(context).push('/chats'),
            ),
          ],
        ),
        centerTitle: false,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: currentTheme.iconTheme.color),
                onPressed: () => displayDrawer(context),
              ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return Builder(
                builder:
                    (context) => IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Pallete.blueColor,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(user.profilePic),
                        ),
                      ),
                      onPressed: () => displayEndDrawer(context),
                    ),
              );
            },
          ),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      bottomNavigationBar:
          isGuest || kIsWeb
              ? null
              : Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: currentTheme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_filled,
                      label: "Home",
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.search_rounded,
                      label: "Search",
                      onTap:
                          () => showSearch(
                            context: context,
                            delegate: SearchCommunityDelegate(ref),
                          ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            Constants.logopath2,
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    _buildNavItem(
                      icon: Icons.add_circle_outline,
                      activeIcon: Icons.add_circle,
                      label: "Create",
                      index: 1,
                    ),
                    // Modified Alerts item with badge
                    Consumer(
                      builder: (context, ref, _) {
                        final notifications =
                            ref.watch(userNotificationsProvider).value ?? [];
                        final unreadCount =
                            notifications.where((n) => !n.isRead).length;

                        return _buildNavItem(
                          icon: Icons.notifications_none,
                          activeIcon: Icons.notifications,
                          label: "Alerts",
                          onTap:
                              () => Routemaster.of(
                                context,
                              ).push('/notifications'),
                          badgeCount: unreadCount,
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    IconData? activeIcon,
    required String label,
    int? index,
    VoidCallback? onTap,
    int? badgeCount, // New parameter for badge
  }) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isActive = index != null && _page == index;

    return GestureDetector(
      onTap: onTap ?? () => onPageChanged(index!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  isActive ? (activeIcon ?? icon) : icon,
                  color:
                      isActive
                          ? Pallete.blueColor
                          : currentTheme.iconTheme.color?.withOpacity(0.6),
                  size: isActive ? 28 : 24,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color:
                    isActive
                        ? Pallete.blueColor
                        : currentTheme.iconTheme.color?.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
