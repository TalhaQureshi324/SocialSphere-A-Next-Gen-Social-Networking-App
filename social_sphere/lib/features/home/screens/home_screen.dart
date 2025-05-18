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
  bool _isAppBarElevated = false;

  void displayProfileDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
  void displayCommunityDrawer(BuildContext context) => Scaffold.of(context).openEndDrawer();
  void onPageChanged(int page) => setState(() => _page = page);

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? index,
    VoidCallback? onTap,
    int? badgeCount,
  }) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isActive = index != null && _page == index;

    return GestureDetector(
      onTap: onTap ?? () => onPageChanged(index!),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isActive
                  ? LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.purple.shade700,
                ],
              )
                  : null,
              color: isActive ? null : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? Colors.white : currentTheme.iconTheme.color?.withOpacity(0.7),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : currentTheme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: 2,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
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
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   gradient: LinearGradient(
        //     colors: [
        //       Colors.blue.shade400,
        //       Colors.purple.shade600,
        //     ],
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.blue.shade400.withOpacity(0.3),
        //       blurRadius: 8,
        //       spreadRadius: 2,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
        child: Image.asset(
          Constants.logopath2,
          height: 50,
          width: 50,
        ),
      ),
    );
  }

  Widget _buildNotificationItem() {
    return Consumer(
      builder: (context, ref, _) {
        final notifications = ref.watch(userNotificationsProvider).value ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return _buildNavItem(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications_active_outlined,
          label: "Alerts",
          onTap: () => Routemaster.of(context).push('/notifications'),
          badgeCount: unreadCount,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    // Modern color scheme
    final appBarColor = isDark
        ? Color.lerp(currentTheme.colorScheme.surface, Colors.black, 0.2)!
        : Color.lerp(currentTheme.colorScheme.surface, Colors.white, 0.96)!;

    final navBarColor = isDark
        ? Color.lerp(currentTheme.colorScheme.surface, Colors.black, 0.15)!
        : Color.lerp(currentTheme.colorScheme.surface, Colors.white, 0.98)!;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final shouldElevate = notification.metrics.pixels > 10;
          if (shouldElevate != _isAppBarElevated) {
            setState(() => _isAppBarElevated = shouldElevate);
          }
        }
        return false;
      },
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: const Text(
            'Social Sphere',
            style: TextStyle(
              fontSize: 22,
              //fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
          centerTitle: false,
          elevation: _isAppBarElevated ? 2 : 0,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: Builder(
            builder: (context) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade600,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0), // Small padding
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(), // Remove minimum size constraint
                    icon: Icon(Icons.person, size: 26),
                    onPressed: () => displayProfileDrawer(context),
                  ),
                ),
              ),
            ),
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.forum_outlined, size: 28),
              onPressed: () => Routemaster.of(context).push('/chats'),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.groups_outlined, size: 34),
                onPressed: () => displayCommunityDrawer(context),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Constants.tabWidgets[_page],
        drawer: const ProfileDrawer(),
        endDrawer: isGuest ? null : const CommunityListDrawer(),
        bottomNavigationBar: isGuest || kIsWeb
            ? null
            : Container(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          decoration: BoxDecoration(
            color: navBarColor,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
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
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: "Explore",
                  onTap: () => showSearch(
                    context: context,
                    delegate: SearchCommunityDelegate(ref),
                  ),
                ),
                _buildCenterButton(),
                _buildNavItem(
                  icon: Icons.add_box_outlined,
                  activeIcon: Icons.add_box,
                  label: "Create",
                  index: 1,
                ),
                _buildNotificationItem(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}