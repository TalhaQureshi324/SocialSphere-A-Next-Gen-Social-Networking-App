import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/models/user_model.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<AddModsScreen> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  final Set<String> _selectedMods = {};
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMods();
  }

  Future<void> _loadInitialMods() async {
    final community = ref.read(getCommunityByNameProvider(widget.name));
    if (community.value != null) {
      setState(() {
        _selectedMods.addAll(community.value!.mods);
      });
    }
  }

  void _toggleMod(String uid, Community community) {
    if (uid == community.creatorUid) return;

    setState(() {
      if (_selectedMods.contains(uid)) {
        _selectedMods.remove(uid);
      } else {
        _selectedMods.add(uid);
      }
      _hasChanges = _selectedMods.length != community.mods.length ||
          !_selectedMods.containsAll(community.mods);
    });
  }

  Future<void> _saveMods() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await Future(() => ref
          .read(communityControllerProvider.notifier)
          .addMods(widget.name, _selectedMods.toList(), context));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Pallete.redColor,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Manage Admins',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => _buildContent(community, theme, isDark),
        error: (error, _) => Center(child: ErrorText(error: error.toString())),
        loading: () => const Center(child: Loader()),
      ),
      bottomNavigationBar: _buildBottomSaveButton(theme),
    );
  }

  Widget _buildBottomSaveButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade600,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _hasChanges && !_isSaving ? _saveMods : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isSaving
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
              : const Text(
            'Save Changes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Community community, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Information Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Pallete.blueColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Management',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select members to grant admin privileges. '
                            'Community creator cannot be modified.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Current Admins Count
          Row(
            children: [
              Text(
                'Current Admins: ${_selectedMods.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Pallete.blueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Total Members: ${community.members.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Members List
          Expanded(
            child: ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (context, index) {
                final member = community.members[index];
                return ref.watch(getUserDataProvider(member)).when(
                  data: (user) => _MemberTile(
                    user: user,
                    community: community,
                    isSelected: _selectedMods.contains(user.uid),
                    onToggle: (uid) => _toggleMod(uid, community),
                    theme: theme,
                    isDark: isDark,
                  ),
                  error: (error, _) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserModel user;
  final Community community;
  final bool isSelected;
  final Function(String) onToggle;
  final ThemeData theme;
  final bool isDark;

  const _MemberTile({
    required this.user,
    required this.community,
    required this.isSelected,
    required this.onToggle,
    required this.theme,
    required this.isDark,
  });

  bool get _isCreator => user.uid == community.creatorUid;

  @override
  Widget build(BuildContext context) {
    final isMod = isSelected || _isCreator;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMod
            ? Pallete.blueColor.withOpacity(isDark ? 0.1 : 0.05)
            : isDark
            ? Colors.grey.shade900.withOpacity(0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMod
              ? Pallete.blueColor.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.profilePic),
          radius: 20,
          backgroundColor: theme.scaffoldBackgroundColor,
          child: _isCreator
              ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade600,
                ],
              ),
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 16,
              color: Colors.white,
            ),
          )
              : null,
        ),
        title: Text(
          user.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: _isCreator ? Pallete.blueColor : theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          _isCreator ? 'Creator' : 'Member',
          style: theme.textTheme.bodySmall?.copyWith(
            color: _isCreator
                ? Pallete.blueColor.withOpacity(0.8)
                : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        trailing: _isCreator
            ? Tooltip(
          message: 'Community creator',
          child: Icon(
            Icons.verified_rounded,
            color: Pallete.blueColor,
            size: 20,
          ),
        )
            : Switch.adaptive(
          value: isSelected,
          onChanged: (value) => onToggle(user.uid),
          activeColor: Pallete.blueColor,
          thumbColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.selected)
                ? Colors.white
                : Colors.grey.shade400,
          ),
        ),
        onTap: _isCreator ? null : () => onToggle(user.uid),
      ),
    );
  }
}