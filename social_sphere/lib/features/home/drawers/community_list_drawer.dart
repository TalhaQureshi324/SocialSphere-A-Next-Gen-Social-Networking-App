import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/sign_button.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/theme/pallete.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final theme = ref.watch(themeNotifierProvider);
    final isDark = theme.brightness == Brightness.dark;
    final isGuest = !user.isAuthenticated;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Joined Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              isGuest
                  ? const SignInButton()
                  : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => navigateToCreateCommunity(context),
                    icon: const Icon(Icons.group_add_outlined, size: 30),
                    label: const Text("Create a Group"),
                  ),
              const SizedBox(height: 16),
              if (!isGuest)
                Expanded(
                  child: ref
                      .watch(userCommunitiesProvider)
                      .when(
                        data: (communities) {
                          if (communities.isEmpty) {
                            return const Center(
                              child: Text("You're not part of any group yet."),
                            );
                          }
                          return ListView.separated(
                            itemCount: communities.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final community = communities[index];
                              return InkWell(
                                onTap:
                                    () =>
                                        navigateToCommunity(context, community),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey.shade900
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          isDark
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          community.avatar,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${community.name}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        error: (error, _) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
