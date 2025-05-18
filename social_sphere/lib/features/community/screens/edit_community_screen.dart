import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  Future<void> selectBannerImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => bannerWebFile = bytes);
      } else {
        setState(() => bannerFile = File(pickedFile.path));
      }
    }
  }

  Future<void> selectProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => profileWebFile = bytes);
      } else {
        setState(() => profileFile = File(pickedFile.path));
      }
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
      profileFile: profileFile,
      bannerFile: bannerFile,
      context: context,
      community: community,
      profileWebFile: profileWebFile,
      bannerWebFile: bannerWebFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    return ref.watch(getCommunityByNameProvider(widget.name)).when(
      data: (community) => Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Edit Group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(
            color: currentTheme.iconTheme.color,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Banner Image Section
                  _buildBannerSection(community, isDark),
                  const SizedBox(height: 24),

                  // Profile Image Section
                  _buildProfileSection(community, isDark),
                  const SizedBox(height: 32),

                  // Community Info Section
                  _buildCommunityInfoSection(community, currentTheme),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),

            // Save Button at Bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
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
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => save(community),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
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
            ),
          ],
        ),
      ),
      loading: () => const Loader(),
      error: (error, stackTrace) => ErrorText(error: error.toString()),
    );
  }

  Widget _buildBannerSection(Community community, bool isDark) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildBannerImage(community),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            onPressed: selectBannerImage,
            backgroundColor: Colors.purple.shade600,
            elevation: 2,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(Community community, bool isDark) {
    return Center(
      child: Stack(
        children: [
          Container(
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
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                backgroundImage: _buildProfileImage(community),
                child: _buildProfileImage(community) == null
                    ? const Icon(Icons.group, size: 40)
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: selectProfileImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade400,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityInfoSection(Community community, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.people,
            label: 'Members',
            value: '${community.members.length}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.link,
            label: 'Group ID',
            value: community.name,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.iconTheme.color?.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget? _buildBannerImage(Community community) {
    if (bannerWebFile != null) {
      return Image.memory(bannerWebFile!, fit: BoxFit.cover);
    }
    if (bannerFile != null) {
      return Image.file(bannerFile!, fit: BoxFit.cover);
    }
    if (community.banner.isNotEmpty && community.banner != Constants.bannerDefault) {
      return Image.network(community.banner, fit: BoxFit.cover);
    }
    return Center(
      child: Icon(
        Icons.photo_library_outlined,
        size: 50,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
      ),
    );
  }

  ImageProvider? _buildProfileImage(Community community) {
    if (profileWebFile != null) return MemoryImage(profileWebFile!);
    if (profileFile != null) return FileImage(profileFile!);
    if (community.avatar.isNotEmpty && community.avatar != Constants.avatarDefault) {
      return NetworkImage(community.avatar);
    }
    return null;
  }
}