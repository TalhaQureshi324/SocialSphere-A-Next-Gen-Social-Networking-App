import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/theme/pallete.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final community = ref.read(getCommunityByNameProvider(widget.name)).value;
      if (community != null) {
        setState(() {
          uids = community.mods.toSet();
        });
      }
    });
  }

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Admins',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
            tooltip: "Save Admins",
          ),
        ],
      ),
      body: ref
          .watch(getCommunityByNameProvider(widget.name))
          .when(
            data: (community) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: ListView.separated(
                itemCount: community.members.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final member = community.members[index];

                  return ref.watch(getUserDataProvider(member)).when(
                        data: (user) => Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: CheckboxListTile(
                            activeColor: Colors.blue,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            value: uids.contains(user.uid),
                            onChanged: (val) {
                              // Prevent changes for creator
                              if (user.uid == community.creatorUid) return;
                              
                              if (val!) {
                                addUid(user.uid);
                              } else {
                                removeUid(user.uid);
                              }
                            },
                            title: Text(
                              '${user.name}${user.uid == community.creatorUid ? ' (Creator)' : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            secondary: user.uid == community.creatorUid
                                ? Tooltip(
                                    message: 'Community Creator',
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          user.profilePic),
                                      child: const Icon(Icons.star,
                                          size: 16, color: Colors.amber),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.profilePic),
                                  ),
                          ),
                        ),
                        error: (error, _) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      );
                },
              ),
            ),
            error: (error, _) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}