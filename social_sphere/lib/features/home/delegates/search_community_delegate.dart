import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/user_profile/controller/user_profile_controller.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final communityStream = ref.watch(searchCommunityProvider(query));
    final userStream = ref.watch(searchUserProvider(query));

    return communityStream.when(
      data: (communities) {
        return userStream.when(
          data: (users) {
            // Filter out guest users
            final nonGuestUsers = users.where((user) => user.isAuthenticated).toList();
            
            if (communities.isEmpty && nonGuestUsers.isEmpty) {
              return const Center(child: Text('No results found'));
            }

            return ListView(
              children: [
                if (communities.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Communities',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ...communities.map(
                  (community) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(community.avatar),
                    ),
                    title: Text(community.name),
                    onTap: () => navigateToCommunity(context, community.name),
                  ),
                ),
                if (nonGuestUsers.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Users',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ...nonGuestUsers.map(
                  (user) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic),
                    ),
                    title: Text(user.name),
                    onTap: () => navigateToUserProfile(context, user.uid),
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
      },
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => const Loader(),
    );
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }
}